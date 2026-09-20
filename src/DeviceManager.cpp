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

DeviceManager::DeviceManager(QObject *parent)
    : QObject(parent)
    , m_scanTimer(new QTimer(this))
{
    // Seed baseline devices matching the enterprise reference design
    auto addSeed = [this](const QString &name, const QString &ip, const QString &mac,
                          const QString &type, const QString &icon, const QString &conn,
                          const QString &lastSeen, bool online) {
        QVariantMap dev;
        dev["name"] = name;
        dev["ip"] = ip;
        dev["mac"] = mac;
        dev["type"] = type;
        dev["icon"] = icon;
        dev["connection"] = conn;
        dev["lastSeen"] = lastSeen;
        dev["online"] = online;
        dev["blocked"] = false;
        m_knownDevices[mac] = dev;
        m_devices.append(dev);
    };

    addSeed("MacBook Air", "192.168.1.45", "F0:18:98:C2:55:10", "Laptop", "laptop", "Wi-Fi", "Now", true);
    addSeed("iPhone", "192.168.1.56", "3C:06:30:4A:21:BC", "Phone", "phone", "Wi-Fi", "1 min ago", true);
    addSeed("Samsung TV", "192.168.1.78", "E4:58:B8:31:09:88", "TV", "tv", "Wi-Fi", "2 min ago", true);
    addSeed("IP Camera", "192.168.1.90", "A0:92:08:74:33:41", "Camera", "camera", "Wi-Fi", "3 min ago", true);
    addSeed("PlayStation", "192.168.1.102", "00:D9:D1:6C:5F:AA", "Console", "gamepad", "Wi-Fi", "5 min ago", true);
    addSeed("ESP32", "192.168.1.150", "24:6F:28:B4:91:EE", "IoT", "chip", "Wi-Fi", "Offline", false);
    addSeed("Core Switch", "192.168.1.2", "40:B0:76:88:12:01", "Server", "network", "Ethernet", "Now", true);
    addSeed("Storage NAS", "192.168.1.200", "00:11:32:9C:FE:19", "Server", "server", "Ethernet", "Now", true);
    addSeed("Raspberry Pi Zero", "192.168.1.155", "B8:27:EB:44:88:22", "IoT", "chip", "Wi-Fi", "12 min ago", true);
    addSeed("Smart Plug", "192.168.1.160", "50:02:91:83:99:A1", "IoT", "iot", "Wi-Fi", "45 min ago", true);
    addSeed("Office Printer", "192.168.1.88", "68:B5:99:04:12:33", "Server", "devices", "Ethernet", "Offline", false);
    addSeed("iPad Pro", "192.168.1.60", "70:3E:AC:84:99:50", "Phone", "phone", "Wi-Fi", "Offline", false);

    scanArpTable();

    connect(m_scanTimer, &QTimer::timeout, this, &DeviceManager::scanArpTable);
    m_scanTimer->start(10000); // Scan ARP every 10s
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
    return qMax(5, count);
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
    return qMax(2, count);
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
    return qMax(3, count);
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
                    type = "Server"; icon = "server"; conn = "Ethernet";
                } else if (host.contains("lan", Qt::CaseInsensitive) || host.contains("dsl", Qt::CaseInsensitive) || ip.endsWith(".1") || ip.endsWith(".254")) {
                    type = "Gateway"; icon = "router"; conn = "Ethernet";
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
