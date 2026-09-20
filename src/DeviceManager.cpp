/**
 * ============================================================================
 * Nexus NOC - Enterprise Network Operations Center Appliance
 * Copyright (c) 2026 Sk Rehan Ahamed
 * Developer: Sk Rehan Ahamed (https://github.com/skrehanahamed)
 * Licensed under the MIT License
 * ============================================================================
 */

#include "DeviceManager.h"
#include <QProcess>
#include <QRegularExpression>
#include <QVariantMap>
#include <QDebug>

#ifdef Q_OS_UNIX
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#endif

DeviceManager::DeviceManager(QObject *parent)
    : QObject(parent)
    , m_scanTimer(new QTimer(this))
{
    // Add local NOC host machine entry
#ifdef Q_OS_UNIX
    struct ifaddrs *ifap = nullptr;
    if (getifaddrs(&ifap) == 0) {
        for (struct ifaddrs *ifa = ifap; ifa != nullptr; ifa = ifa->ifa_next) {
            if (!ifa->ifa_addr || ifa->ifa_addr->sa_family != AF_INET) continue;
            QString name(ifa->ifa_name);
            if (name == "lo0" || name == "lo") continue;
            struct sockaddr_in *sa = reinterpret_cast<struct sockaddr_in *>(ifa->ifa_addr);
            char addrStr[INET_ADDRSTRLEN];
            if (inet_ntop(AF_INET, &(sa->sin_addr), addrStr, INET_ADDRSTRLEN)) {
                QString ipStr = QString::fromLatin1(addrStr);
                if (!ipStr.isEmpty() && !ipStr.startsWith("127.")) {
                    QVariantMap hostDev;
#if defined(Q_OS_MACOS)
                    hostDev["name"] = "MacBook Air (NOC Host)";
                    hostDev["type"] = "Laptop";
                    hostDev["icon"] = "laptop";
#elif defined(Q_OS_LINUX)
                    hostDev["name"] = "Raspberry Pi (Nexus NOC)";
                    hostDev["type"] = "Server";
                    hostDev["icon"] = "server";
#else
                    hostDev["name"] = "Nexus NOC Appliance";
                    hostDev["type"] = "Server";
                    hostDev["icon"] = "server";
#endif
                    hostDev["ip"] = ipStr;
                    hostDev["mac"] = "LOCAL-HOST";
                    hostDev["connection"] = (name.startsWith("eth") || name.startsWith("en1") || name.startsWith("en2")) ? "Ethernet" : "Wi-Fi";
                    hostDev["lastSeen"] = "Now";
                    hostDev["online"] = true;
                    hostDev["blocked"] = false;
                    m_knownDevices[hostDev["mac"].toString()] = hostDev;
                    m_devices.append(hostDev);
                    break;
                }
            }
        }
        freeifaddrs(ifap);
    }
#endif

    scanArpTable();

    connect(m_scanTimer, &QTimer::timeout, this, &DeviceManager::scanArpTable);
    m_scanTimer->start(5000); // Live scan every 5s
}

int DeviceManager::onlineDeviceCount() const
{
    int count = 0;
    for (const QVariant &v : m_devices) {
        if (v.toMap().value("online").toBool()) count++;
    }
    return count;
}

int DeviceManager::offlineDeviceCount() const
{
    int count = 0;
    for (const QVariant &v : m_devices) {
        if (!v.toMap().value("online").toBool()) count++;
    }
    return count;
}

int DeviceManager::wifiClientCount() const
{
    int count = 0;
    for (const QVariant &v : m_devices) {
        QVariantMap m = v.toMap();
        if (m.value("connection").toString() == "Wi-Fi" && m.value("online").toBool()) {
            count++;
        }
    }
    return count;
}

int DeviceManager::ethernetClientCount() const
{
    int count = 0;
    for (const QVariant &v : m_devices) {
        QVariantMap m = v.toMap();
        if (m.value("connection").toString() == "Ethernet" && m.value("online").toBool()) {
            count++;
        }
    }
    return count;
}

int DeviceManager::iotDeviceCount() const
{
    int count = 0;
    for (const QVariant &v : m_devices) {
        QVariantMap m = v.toMap();
        if (m.value("type").toString() == "IoT") {
            count++;
        }
    }
    return count;
}

void DeviceManager::refreshDevices()
{
    scanArpTable();
}

void DeviceManager::scanArpTable()
{
    // Probe local broadcast non-blockingly to refresh ARP table
    QProcess::startDetached("ping", QStringList() << "-c" << "1" << "-W" << "500" << "192.168.1.255");

    QProcess process;
    process.start("arp", QStringList() << "-a");
    if (process.waitForFinished(2000)) {
        QString output = QString::fromUtf8(process.readAllStandardOutput());
        QStringList lines = output.split('\n');

        // Regex to parse: hostname (IP) at MAC on iface
        // e.g. "? (192.168.1.133) at fe:f2:fb:a9:85:3d on en0"
        QRegularExpression re("^(.*?)\\s+\\(([0-9.]+)\\)\\s+at\\s+([0-9a-fA-F:]+)\\s+on\\s+(\\w+)");

        for (const QString &line : lines) {
            QRegularExpressionMatch match = re.match(line.trimmed());
            if (match.hasMatch()) {
                QString host = match.captured(1).trimmed();
                QString ip = match.captured(2);
                QString mac = match.captured(3).toUpper();
                QString iface = match.captured(4);

                // Filter multicast / broadcast / incomplete
                if (ip.startsWith("224.") || ip.startsWith("239.") || ip == "255.255.255.255" || mac.startsWith("FF:FF") || mac.contains("INCOMPLETE"))
                    continue;

                if (host == "?" || host.isEmpty()) {
                    host = "Device (" + ip.section('.', 3, 3) + ")";
                }

                QString type = "IoT";
                QString icon = "chip";
                QString conn = (iface.contains("eth") || iface.contains("en1") || iface.contains("bridge")) ? "Ethernet" : "Wi-Fi";

                if (host.contains("iPhone", Qt::CaseInsensitive) || host.contains("Android", Qt::CaseInsensitive) || host.contains("Pixel", Qt::CaseInsensitive) || host.contains("Phone", Qt::CaseInsensitive) || mac.startsWith("5A:5A")) {
                    type = "Phone"; icon = "phone";
                } else if (host.contains("Mac", Qt::CaseInsensitive) || host.contains("Book", Qt::CaseInsensitive) || host.contains("Laptop", Qt::CaseInsensitive) || host.contains("ThinkPad", Qt::CaseInsensitive) || mac.startsWith("C0:C7")) {
                    type = "Laptop"; icon = "laptop";
                } else if (host.contains("TV", Qt::CaseInsensitive) || host.contains("Cast", Qt::CaseInsensitive) || host.contains("Roku", Qt::CaseInsensitive) || host.contains("Samsung", Qt::CaseInsensitive) || host.contains("LG", Qt::CaseInsensitive)) {
                    type = "TV"; icon = "tv";
                } else if (host.contains("Cam", Qt::CaseInsensitive) || host.contains("Ring", Qt::CaseInsensitive) || host.contains("Nest", Qt::CaseInsensitive) || host.contains("Security", Qt::CaseInsensitive)) {
                    type = "Camera"; icon = "camera";
                } else if (host.contains("PlayStation", Qt::CaseInsensitive) || host.contains("Xbox", Qt::CaseInsensitive) || host.contains("Switch", Qt::CaseInsensitive) || host.contains("PS5", Qt::CaseInsensitive) || host.contains("PS4", Qt::CaseInsensitive)) {
                    type = "Console"; icon = "gamepad";
                } else if (host.contains("Server", Qt::CaseInsensitive) || host.contains("NAS", Qt::CaseInsensitive)) {
                    type = "Server"; icon = "server";
                } else if (host.contains("lan", Qt::CaseInsensitive) || host.contains("dsl", Qt::CaseInsensitive) || ip.endsWith(".1") || ip.endsWith(".254")) {
                    type = "Gateway"; icon = "router";
                }

                QVariantMap dev;
                dev["name"] = host;
                dev["ip"] = ip;
                dev["mac"] = mac;
                dev["interface"] = iface;
                dev["type"] = type;
                dev["icon"] = icon;
                dev["connection"] = conn;
                dev["lastSeen"] = "Now";
                dev["online"] = true;
                dev["blocked"] = m_blockedMacAddresses.contains(mac);

                m_knownDevices[mac] = dev;
            }
        }

        if (!m_knownDevices.isEmpty()) {
            QVariantList list;
            for (const auto &dev : m_knownDevices.values()) {
                list.append(dev);
            }
            m_devices = list;
            emit devicesChanged();
        }
    }
}

void DeviceManager::blockDevice(const QString &macAddress)
{
    m_blockedMacAddresses.insert(macAddress.toUpper());
    for (QVariant &device : m_devices) {
        QVariantMap map = device.toMap();
        if (map.value("mac").toString().compare(macAddress, Qt::CaseInsensitive) == 0) {
            map["blocked"] = true;
            device = map;
        }
    }
    emit devicesChanged();
    emit deviceStatusChanged(macAddress, true);
}

void DeviceManager::unblockDevice(const QString &macAddress)
{
    m_blockedMacAddresses.remove(macAddress.toUpper());
    for (QVariant &device : m_devices) {
        QVariantMap map = device.toMap();
        if (map.value("mac").toString().compare(macAddress, Qt::CaseInsensitive) == 0) {
            map["blocked"] = false;
            device = map;
        }
    }
    emit devicesChanged();
    emit deviceStatusChanged(macAddress, false);
}
