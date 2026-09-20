/**
 * ============================================================================
 * Nexus NOC - Enterprise Network Operations Center Appliance
 * Copyright (c) 2026 Sk Rehan Ahamed
 * Developer: Sk Rehan Ahamed (https://github.com/skrehanahamed)
 * Licensed under the MIT License
 * ============================================================================
 */

#include "ServiceManager.h"
#include <QProcess>
#include <QRegularExpression>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariantMap>
#include <QDebug>

ServiceManager::ServiceManager(QObject *parent)
    : QObject(parent)
    , m_timer(new QTimer(this))
    , m_vanishTimer(new QTimer(this))
{
    // Define real platform system daemons & services
    m_serviceDefs = {
        { "configd", "Network Configuration Daemon", "configd", "NetworkManager", false, 0, false },
        { "mDNSResponder", "Bonjour ZeroConf DNS Daemon", "mDNSResponder", "systemd-resolved", false, 0, false },
        { "bluetoothd", "Bluetooth Core Daemon", "bluetoothd", "bluetooth", false, 0, false },
        { "timed", "NTP Time Synchronization", "timed", "chronyd", false, 0, false },
        { "diskarbitrationd", "Disk Arbitration Subsystem", "diskarbitrationd", "udisks2", false, 0, false },
        { "coreaudiod", "Core Audio HAL Subsystem", "coreaudiod", "pipewire", false, 0, false },
        { "airportd", "AirPort Wi-Fi Core Service", "airportd", "wpa_supplicant", false, 0, false },
        { "logd", "Apple Unified Logging Daemon", "logd", "systemd-journald", false, 0, false },
        { "powerd", "System Power Management", "powerd", "systemd-logind", false, 0, false },
        { "nexus-noc", "NEXUS NOC Core Engine", "nexus-noc", "nexus-noc", true, 0, false },
        { "docker", "Docker Application Engine", "dockerd", "docker", false, 0, false },
        { "sshd", "OpenSSH Server Daemon", "sshd", "ssh", false, 0, false }
    };

    querySystemServices();
    queryDockerStatus();

    connect(m_timer, &QTimer::timeout, this, [this]() {
        querySystemServices();
        queryDockerStatus();
    });
    m_timer->start(5000); // Check services every 5s

    connect(m_vanishTimer, &QTimer::timeout, this, [this]() {
        qint64 now = QDateTime::currentMSecsSinceEpoch();
        bool changed = false;
        for (auto &svc : m_serviceDefs) {
            if (svc.stoppedTimestamp > 0 && (now - svc.stoppedTimestamp) >= 3500) {
                // Vanish duration expired
                svc.stoppedTimestamp = 0;
                changed = true;
            }
        }
        if (changed) {
            updateRunningLists();
        }
    });
    m_vanishTimer->start(500); // Check vanish queue every 500ms
}

void ServiceManager::refreshAll()
{
    querySystemServices();
    queryDockerStatus();
}

void ServiceManager::querySystemServices()
{
    qint64 now = QDateTime::currentMSecsSinceEpoch();

    for (auto &svc : m_serviceDefs) {
        bool wasRunning = svc.isRunning;
        bool isNowRunning = false;

        if (svc.simulatedStopped) {
            isNowRunning = false;
        } else if (svc.name == "nexus-noc") {
            isNowRunning = true; // This application itself is running
        } else if (svc.name == "docker") {
            isNowRunning = m_dockerAvailable;
        } else {
#if defined(Q_OS_MACOS)
            QProcess proc;
            proc.start("pgrep", QStringList() << "-x" << svc.macProc);
            if (proc.waitForFinished(300)) {
                isNowRunning = (proc.exitCode() == 0);
            }
#elif defined(Q_OS_LINUX)
            QProcess proc;
            proc.start("systemctl", QStringList() << "is-active" << svc.linuxSvc);
            if (proc.waitForFinished(600)) {
                isNowRunning = (proc.readAllStandardOutput().trimmed() == "active");
            }
#endif
        }

        // Detect transition from running -> stopped
        if (wasRunning && !isNowRunning) {
            svc.stoppedTimestamp = now;
        } else if (isNowRunning) {
            svc.stoppedTimestamp = 0;
            svc.simulatedStopped = false;
        }

        svc.isRunning = isNowRunning;
    }

    updateRunningLists();
}

void ServiceManager::updateRunningLists()
{
    qint64 now = QDateTime::currentMSecsSinceEpoch();
    QVariantList allList;
    QVariantList runningList;
    int activeCount = 0;
    int stoppedCount = 0;

    for (const auto &svc : m_serviceDefs) {
        bool active = svc.isRunning;
        bool recentlyStopped = (!active && svc.stoppedTimestamp > 0 && (now - svc.stoppedTimestamp) < 3500);

        QVariantMap s;
        s["name"] = svc.name;
        s["fullName"] = svc.desc;
        s["status"] = active ? "Running" : "Stopped";
        s["active"] = active;
        s["vanishing"] = recentlyStopped;

        allList.append(s);

        if (active) {
            activeCount++;
            runningList.append(s);
        } else if (recentlyStopped) {
            // Include temporarily so it displays "Stopped" with red indicator, then vanishes!
            runningList.append(s);
            stoppedCount++;
        } else {
            stoppedCount++;
        }
    }

    m_services = allList;
    m_runningServices = runningList;
    m_runningCount = activeCount;
    m_stoppedCount = (m_runningServices.size() > activeCount) ? (m_runningServices.size() - activeCount) : 0;
    emit servicesChanged();
}

void ServiceManager::stopService(const QString &serviceName)
{
    qint64 now = QDateTime::currentMSecsSinceEpoch();
    for (auto &svc : m_serviceDefs) {
        if (svc.name == serviceName || svc.macProc == serviceName) {
            svc.simulatedStopped = true;
            svc.isRunning = false;
            svc.stoppedTimestamp = now;
            qDebug() << "[ServiceManager] Service stopped:" << serviceName << "- will vanish in 3.5s";
            break;
        }
    }
    updateRunningLists();
}

void ServiceManager::startService(const QString &serviceName)
{
    for (auto &svc : m_serviceDefs) {
        if (svc.name == serviceName || svc.macProc == serviceName) {
            svc.simulatedStopped = false;
            svc.isRunning = true;
            svc.stoppedTimestamp = 0;
            qDebug() << "[ServiceManager] Service started:" << serviceName;
            break;
        }
    }
    updateRunningLists();
}

void ServiceManager::toggleService(const QString &serviceName)
{
    for (auto &svc : m_serviceDefs) {
        if (svc.name == serviceName || svc.macProc == serviceName) {
            if (svc.isRunning) {
                stopService(serviceName);
            } else {
                startService(serviceName);
            }
            return;
        }
    }
}

void ServiceManager::queryDockerStatus()
{
    QProcess process;
    process.start("docker", QStringList() << "ps" << "-a" << "--format" << "{{json .}}");
    if (process.waitForFinished(2000) && process.exitCode() == 0) {
        m_dockerAvailable = true;
        QString output = QString::fromUtf8(process.readAllStandardOutput());
        QStringList lines = output.split('\n', Qt::SkipEmptyParts);

        QVariantList containers;
        int running = 0;
        int stopped = 0;

        for (const QString &line : lines) {
            QJsonDocument doc = QJsonDocument::fromJson(line.toUtf8());
            if (doc.isObject()) {
                QJsonObject obj = doc.object();
                QVariantMap c;
                c["name"] = obj["Names"].toString();
                c["image"] = obj["Image"].toString();
                c["status"] = obj["Status"].toString();
                c["ports"] = obj["Ports"].toString();
                bool isUp = obj["Status"].toString().startsWith("Up");
                c["running"] = isUp;
                if (isUp) running++;
                else stopped++;
                containers.append(c);
            }
        }

        m_dockerContainers = containers;
        m_dockerRunningCount = running;
        m_dockerStoppedCount = stopped;
    } else {
        m_dockerAvailable = false;
        m_dockerRunningCount = 0;
        m_dockerStoppedCount = 0;
        m_dockerContainers.clear();
    }

    emit dockerChanged();
}

void ServiceManager::restartService(const QString &serviceName)
{
    qDebug() << "[ServiceManager] Restart requested for:" << serviceName;
    stopService(serviceName);
    // Auto re-start after 2s
    QTimer::singleShot(2000, this, [this, serviceName]() {
        startService(serviceName);
    });
    emit serviceRestarted(serviceName);
}
