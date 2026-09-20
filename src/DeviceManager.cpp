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
    scanArpTable();

    connect(m_scanTimer, &QTimer::timeout, this, &DeviceManager::scanArpTable);
    m_scanTimer->start(10000); // Scan ARP every 10s
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

                QString type = "IoT Devices";
                QString icon = "devices";
                if (host.contains("iPhone", Qt::CaseInsensitive) || host.contains("Android", Qt::CaseInsensitive) || host.contains("Pixel", Qt::CaseInsensitive) || mac.startsWith("5A:5A")) {
                    type = "Phone"; icon = "phone";
                } else if (host.contains("Mac", Qt::CaseInsensitive) || host.contains("Book", Qt::CaseInsensitive) || host.contains("Laptop", Qt::CaseInsensitive) || mac.startsWith("C0:C7")) {
                    type = "Laptop"; icon = "laptop";
                } else if (host.contains("TV", Qt::CaseInsensitive) || host.contains("Cast", Qt::CaseInsensitive) || host.contains("Roku", Qt::CaseInsensitive)) {
                    type = "TV / Media"; icon = "tv";
                } else if (host.contains("lan", Qt::CaseInsensitive) || host.contains("dsl", Qt::CaseInsensitive) || ip.endsWith(".1") || ip.endsWith(".254")) {
                    type = "Gateway"; icon = "gateway";
                }

                QVariantMap dev;
                dev["name"] = host;
                dev["ip"] = ip;
                dev["mac"] = mac;
                dev["interface"] = iface;
                dev["type"] = type;
                dev["icon"] = icon;
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
