#pragma once

#include <QObject>
#include <QVariantList>
#include <QTimer>
#include <QSet>

class DeviceManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(int connectedDeviceCount READ connectedDeviceCount NOTIFY devicesChanged)
    Q_PROPERTY(int onlineDeviceCount READ onlineDeviceCount NOTIFY devicesChanged)
    Q_PROPERTY(int offlineDeviceCount READ offlineDeviceCount NOTIFY devicesChanged)
    Q_PROPERTY(QVariantList devices READ devices NOTIFY devicesChanged)

public:
    explicit DeviceManager(QObject *parent = nullptr);

    int connectedDeviceCount() const { return m_devices.size(); }
    int onlineDeviceCount() const { return m_devices.size(); }
    int offlineDeviceCount() const { return 0; }
    QVariantList devices() const { return m_devices; }

    Q_INVOKABLE void refreshDevices();
    Q_INVOKABLE void blockDevice(const QString &macAddress);
    Q_INVOKABLE void unblockDevice(const QString &macAddress);

signals:
    void devicesChanged();
    void deviceStatusChanged(const QString &macAddress, bool blocked);

private:
    void scanArpTable();

    QMap<QString, QVariantMap> m_knownDevices;
    QVariantList m_devices;
    QSet<QString> m_blockedMacAddresses;
    QTimer *m_scanTimer;
};
