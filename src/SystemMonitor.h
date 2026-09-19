#pragma once

#include <QObject>
#include <QTimer>
#include <QString>

class SystemMonitor : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString deviceName READ deviceName NOTIFY hardwareChanged)
    Q_PROPERTY(QString deviceShortName READ deviceShortName NOTIFY hardwareChanged)
    Q_PROPERTY(QString deviceType READ deviceType NOTIFY hardwareChanged)
    Q_PROPERTY(QString cpuModel READ cpuModel NOTIFY hardwareChanged)
    Q_PROPERTY(int cpuCores READ cpuCores NOTIFY hardwareChanged)
    Q_PROPERTY(double cpuLoad READ cpuLoad NOTIFY cpuLoadChanged)
    Q_PROPERTY(double cpuTemp READ cpuTemp NOTIFY cpuTempChanged)
    Q_PROPERTY(double ramUsedGb READ ramUsedGb NOTIFY ramChanged)
    Q_PROPERTY(double ramTotalGb READ ramTotalGb NOTIFY hardwareChanged)
    Q_PROPERTY(double storageUsedGb READ storageUsedGb NOTIFY storageChanged)
    Q_PROPERTY(double storageTotalGb READ storageTotalGb NOTIFY hardwareChanged)
    Q_PROPERTY(QString localIp READ localIp NOTIFY networkChanged)
    Q_PROPERTY(QString gatewayIp READ gatewayIp NOTIFY networkChanged)
    Q_PROPERTY(QString macAddress READ macAddress NOTIFY networkChanged)
    Q_PROPERTY(QString hostName READ hostName NOTIFY hardwareChanged)
    Q_PROPERTY(int uptimeSeconds READ uptimeSeconds NOTIFY uptimeChanged)
    Q_PROPERTY(QString uptimeFormatted READ uptimeFormatted NOTIFY uptimeChanged)
    Q_PROPERTY(QString osName READ osName CONSTANT)

public:
    explicit SystemMonitor(QObject *parent = nullptr);

    QString deviceName() const { return m_deviceName; }
    QString deviceShortName() const { return m_deviceShortName; }
    QString deviceType() const { return m_deviceType; }
    QString cpuModel() const { return m_cpuModel; }
    int cpuCores() const { return m_cpuCores; }
    double cpuLoad() const { return m_cpuLoad; }
    double cpuTemp() const { return m_cpuTemp; }
    double ramUsedGb() const { return m_ramUsedGb; }
    double ramTotalGb() const { return m_ramTotalGb; }
    double storageUsedGb() const { return m_storageUsedGb; }
    double storageTotalGb() const { return m_storageTotalGb; }
    QString localIp() const { return m_localIp; }
    QString gatewayIp() const { return m_gatewayIp; }
    QString macAddress() const { return m_macAddress; }
    QString hostName() const { return m_hostName; }
    int uptimeSeconds() const { return m_uptimeSeconds; }
    QString uptimeFormatted() const;
    QString osName() const;

signals:
    void hardwareChanged();
    void cpuLoadChanged();
    void cpuTempChanged();
    void ramChanged();
    void storageChanged();
    void networkChanged();
    void uptimeChanged();

private slots:
    void tick();

private:
    void detectHardware();
    void sampleCpuLoad();
    void sampleRam();
    void sampleStorage();
    void detectNetwork();

    QString m_deviceName;
    QString m_deviceShortName;
    QString m_deviceType;
    QString m_cpuModel;
    int m_cpuCores = 4;
    double m_cpuLoad = 0.0;
    double m_cpuTemp = 42.0;
    double m_ramUsedGb = 0.0;
    double m_ramTotalGb = 0.0;
    double m_storageUsedGb = 0.0;
    double m_storageTotalGb = 0.0;
    QString m_localIp = "127.0.0.1";
    QString m_gatewayIp = "192.168.1.1";
    QString m_macAddress = "00:00:00:00:00:00";
    QString m_hostName;
    int m_uptimeSeconds = 0;
    QTimer *m_timer;

#ifdef Q_OS_MACOS
    uint64_t m_prevUserTicks = 0;
    uint64_t m_prevSystemTicks = 0;
    uint64_t m_prevIdleTicks = 0;
#endif
};
