#pragma once

#include <QObject>
#include <QVariantList>
#include <QTimer>
#include <QDateTime>

struct MonitoredService {
    QString name;
    QString desc;
    QString macProc;
    QString linuxSvc;
    bool isRunning = false;
    qint64 stoppedTimestamp = 0; // Epoch ms when it transitioned to stopped
    bool simulatedStopped = false;
};

class ServiceManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(int runningServiceCount READ runningServiceCount NOTIFY servicesChanged)
    Q_PROPERTY(int stoppedServiceCount READ stoppedServiceCount NOTIFY servicesChanged)
    Q_PROPERTY(QVariantList services READ services NOTIFY servicesChanged)
    Q_PROPERTY(QVariantList runningServices READ runningServices NOTIFY servicesChanged)
    Q_PROPERTY(bool dockerAvailable READ dockerAvailable NOTIFY dockerChanged)
    Q_PROPERTY(int dockerRunningCount READ dockerRunningCount NOTIFY dockerChanged)
    Q_PROPERTY(int dockerStoppedCount READ dockerStoppedCount NOTIFY dockerChanged)
    Q_PROPERTY(QVariantList dockerContainers READ dockerContainers NOTIFY dockerChanged)

public:
    explicit ServiceManager(QObject *parent = nullptr);

    int runningServiceCount() const { return m_runningCount; }
    int stoppedServiceCount() const { return m_stoppedCount; }
    QVariantList services() const { return m_services; }
    QVariantList runningServices() const { return m_runningServices; }

    bool dockerAvailable() const { return m_dockerAvailable; }
    int dockerRunningCount() const { return m_dockerRunningCount; }
    int dockerStoppedCount() const { return m_dockerStoppedCount; }
    QVariantList dockerContainers() const { return m_dockerContainers; }

    Q_INVOKABLE void refreshAll();
    Q_INVOKABLE void restartService(const QString &serviceName);
    Q_INVOKABLE void stopService(const QString &serviceName);
    Q_INVOKABLE void startService(const QString &serviceName);
    Q_INVOKABLE void toggleService(const QString &serviceName);

signals:
    void servicesChanged();
    void dockerChanged();
    void serviceRestarted(const QString &serviceName);

private:
    void querySystemServices();
    void queryDockerStatus();
    void updateRunningLists();

    QList<MonitoredService> m_serviceDefs;
    QVariantList m_services;
    QVariantList m_runningServices;
    int m_runningCount = 0;
    int m_stoppedCount = 0;

    bool m_dockerAvailable = false;
    int m_dockerRunningCount = 0;
    int m_dockerStoppedCount = 0;
    QVariantList m_dockerContainers;

    QTimer *m_timer;
    QTimer *m_vanishTimer;
};
