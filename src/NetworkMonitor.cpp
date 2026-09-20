/**
 * ============================================================================
 * Nexus NOC - Enterprise Network Operations Center Appliance
 * Copyright (c) 2026 Sk Rehan Ahamed
 * Developer: Sk Rehan Ahamed (https://github.com/skrehanahamed)
 * Licensed under the MIT License
 * ============================================================================
 */

#include "NetworkMonitor.h"
#include <QRegularExpression>
#include <QDebug>
#include <QDateTime>
#include <QtMath>
#include <QFile>
#include <QTextStream>

#ifdef Q_OS_UNIX
#include <sys/types.h>
#include <sys/socket.h>
#include <ifaddrs.h>
#include <net/if.h>
#include <arpa/inet.h>
#ifdef Q_OS_MACOS
#include <net/if_var.h>
#include <net/if_dl.h>
#endif
#endif

NetworkMonitor::NetworkMonitor(QObject *parent)
    : QObject(parent)
    , m_timer(new QTimer(this))
    , m_pingTimer(new QTimer(this))
    , m_wifiTimer(new QTimer(this))
    , m_pingProcess(new QProcess(this))
    , m_wifiProcess(new QProcess(this))
{
    // Initialize buffers with real 0 values (not dummy fallbacks)
    for (int i = 0; i < 30; ++i) {
        m_trafficHistoryDl.append(0.0);
        m_trafficHistoryUl.append(0.0);
        m_latencyHistory.append(0.0);
    }

    // Immediately detect real network configuration
    sampleWifiInfoSync();
    detectEthernet();
    sampleThroughput();
    samplePing();
    sampleWifiInfo();

    connect(m_timer, &QTimer::timeout, this, &NetworkMonitor::tick);
    m_timer->start(250); // High-frequency 250ms real-time throughput

    connect(m_pingTimer, &QTimer::timeout, this, &NetworkMonitor::samplePing);
    m_pingTimer->start(1000); // Live ping every 1s

    connect(m_wifiTimer, &QTimer::timeout, this, &NetworkMonitor::sampleWifiInfo);
    m_wifiTimer->start(5000); // Wi-Fi info every 5s
}

void NetworkMonitor::sampleThroughput()
{
#ifdef Q_OS_MACOS
    struct ifaddrs *ifap = nullptr;
    if (getifaddrs(&ifap) == 0) {
        uint64_t totalRx = 0;
        uint64_t totalTx = 0;
        bool hasActiveIp = false;
        bool isLinkUp = false;

        for (struct ifaddrs *ifa = ifap; ifa != nullptr; ifa = ifa->ifa_next) {
            if (!ifa->ifa_addr) continue;
            QString name(ifa->ifa_name);
            if (name == "en0" || name.startsWith("en")) {
                if (ifa->ifa_addr->sa_family == AF_LINK) {
                    struct if_data *ifd = reinterpret_cast<struct if_data *>(ifa->ifa_data);
                    if (ifd) {
                        totalRx += ifd->ifi_ibytes;
                        totalTx += ifd->ifi_obytes;
                        m_primaryInterface = name;
                    }
                    if ((ifa->ifa_flags & IFF_UP) && (ifa->ifa_flags & IFF_RUNNING)) {
                        isLinkUp = true;
                    }
                } else if (ifa->ifa_addr->sa_family == AF_INET) {
                    struct sockaddr_in *sa = reinterpret_cast<struct sockaddr_in *>(ifa->ifa_addr);
                    if (sa && sa->sin_addr.s_addr != 0) {
                        hasActiveIp = true;
                    }
                }
            }
        }
        freeifaddrs(ifap);

        // Immediate 250ms disconnect/reconnect detection
        bool isCurrentlyConnected = hasActiveIp && isLinkUp;
        if (m_wifiConnected != isCurrentlyConnected) {
            m_wifiConnected = isCurrentlyConnected;
            if (!m_wifiConnected) {
                m_packetLoss = 100.0;
                m_latencyMs = 0.0;
                m_rxRateMbps = 0.0;
                m_txRateMbps = 0.0;
            }
            emit wifiChanged();
            emit latencyChanged();
            emit ratesChanged();
        }

        if (m_prevRxBytes > 0 && m_prevTxBytes > 0 && totalRx >= m_prevRxBytes && totalTx >= m_prevTxBytes) {
            uint64_t rxDelta = totalRx - m_prevRxBytes;
            uint64_t txDelta = totalTx - m_prevTxBytes;

            qint64 now = QDateTime::currentMSecsSinceEpoch();
            double elapsedSec = (m_prevSampleTime > 0) ? qMax(0.05, (now - m_prevSampleTime) / 1000.0) : 0.25;
            m_prevSampleTime = now;

            double rxMbps = (rxDelta * 8.0) / (elapsedSec * 1024.0 * 1024.0);
            double txMbps = (txDelta * 8.0) / (elapsedSec * 1024.0 * 1024.0);

            m_rxRateMbps = m_wifiConnected ? (qRound(rxMbps * 10.0) / 10.0) : 0.0;
            m_txRateMbps = m_wifiConnected ? (qRound(txMbps * 10.0) / 10.0) : 0.0;

            emit ratesChanged();

            m_trafficHistoryDl.removeFirst();
            m_trafficHistoryDl.append(m_rxRateMbps);

            m_trafficHistoryUl.removeFirst();
            m_trafficHistoryUl.append(m_txRateMbps);

            emit historyChanged();
        }

        m_prevRxBytes = totalRx;
        m_prevTxBytes = totalTx;
    }
#endif
}

void NetworkMonitor::samplePing()
{
    if (!m_wifiConnected) {
        if (m_packetLoss != 100.0 || m_latencyMs != 0.0) {
            m_packetLoss = 100.0;
            m_latencyMs = 0.0;
            m_latencyHistory.removeFirst();
            m_latencyHistory.append(0.0);
            emit latencyChanged();
        }
        return;
    }

    if (m_pingProcess->state() != QProcess::NotRunning) return;

    connect(m_pingProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this](int exitCode, QProcess::ExitStatus) {
        if (exitCode == 0) {
            QString out = QString::fromUtf8(m_pingProcess->readAllStandardOutput());
            QRegularExpression re("time=([0-9.]+) ms");
            QRegularExpressionMatch match = re.match(out);
            if (match.hasMatch()) {
                double newLatency = qRound(match.captured(1).toDouble() * 10.0) / 10.0;

                // Calculate jitter from rolling window
                if (m_latencyMs > 0 && newLatency > 0) {
                    double diff = qAbs(newLatency - m_latencyMs);
                    m_jitterMs = qRound((m_jitterMs * 0.75 + qMin(diff, 10.0) * 0.25) * 10.0) / 10.0;
                } else {
                    m_jitterMs = 1.8;
                }

                bool wasInitial = (m_latencyMs == 0.0);
                m_latencyMs = newLatency;
                m_packetLoss = 0.0;

                if (wasInitial) {
                    for (int h = 0; h < m_latencyHistory.size(); ++h) {
                        m_latencyHistory[h] = m_latencyMs;
                    }
                } else {
                    m_latencyHistory.removeFirst();
                    m_latencyHistory.append(m_latencyMs);
                }

                emit latencyChanged();
            }
        } else {
            m_packetLoss = 100.0;
            m_latencyMs = 0.0;
            m_latencyHistory.removeFirst();
            m_latencyHistory.append(0.0);
            emit latencyChanged();
        }
        m_pingProcess->disconnect(this);
    });

    m_pingProcess->start("ping", QStringList() << "-c" << "1" << "-W" << "600" << "1.1.1.1");
}

void NetworkMonitor::sampleWifiInfo()
{
#ifdef Q_OS_MACOS
    if (m_wifiProcess->state() != QProcess::NotRunning) return;

    m_wifiProcess->disconnect(this);
    connect(m_wifiProcess, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this](int exitCode, QProcess::ExitStatus) {
        if (exitCode == 0) {
            QString output = QString::fromUtf8(m_wifiProcess->readAllStandardOutput());
            QStringList lines = output.split('\n');

            bool inCurrentNet = false;
            QString detectedSsid;
            int detectedDbm = m_wifiSignalDbm;
            QString detectedSpeed = m_linkSpeed;

            for (const QString &line : lines) {
                QString trimmed = line.trimmed();
                if (trimmed.startsWith("Current Network Information:")) {
                    inCurrentNet = true;
                    continue;
                }

                if (inCurrentNet) {
                    if (detectedSsid.isEmpty() && trimmed.endsWith(":") && !trimmed.startsWith("Other Local")) {
                        detectedSsid = trimmed.left(trimmed.length() - 1);
                    }

                    if (trimmed.startsWith("Signal / Noise:") || trimmed.startsWith("Signal/Noise:")) {
                        QRegularExpression sigRe("(-?\\d+)\\s*dBm");
                        QRegularExpressionMatch sigMatch = sigRe.match(trimmed);
                        if (sigMatch.hasMatch()) {
                            detectedDbm = sigMatch.captured(1).toInt();
                        }
                    } else if (trimmed.startsWith("Transmit Rate:")) {
                        detectedSpeed = trimmed.section(':', 1).trimmed() + " Mbps";
                    } else if (trimmed.startsWith("Other Local")) {
                        break;
                    }
                }
            }

            if (!detectedSsid.isEmpty()) {
                m_wifiSsid = detectedSsid;
                m_wifiConnected = true;
                m_wifiSignalDbm = detectedDbm;
                if (m_wifiSignalDbm >= -55) m_wifiSignalBars = 4;
                else if (m_wifiSignalDbm >= -68) m_wifiSignalBars = 3;
                else if (m_wifiSignalDbm >= -78) m_wifiSignalBars = 2;
                else if (m_wifiSignalDbm >= -88) m_wifiSignalBars = 1;
                else m_wifiSignalBars = 0;

                if (!detectedSpeed.isEmpty()) {
                    m_linkSpeed = detectedSpeed;
                }
                emit wifiChanged();
            }
        }
    });

    m_wifiProcess->start("system_profiler", QStringList() << "SPAirPortDataType" << "-detailLevel" << "basic");
#elif defined(Q_OS_LINUX)
    // Linux Wi-Fi info
    QProcess process;
    process.start("iwgetid", QStringList() << "-r");
    if (process.waitForFinished(1000)) {
        QString ssid = QString::fromUtf8(process.readAllStandardOutput()).trimmed();
        if (!ssid.isEmpty()) {
            m_wifiSsid = ssid;
            m_wifiConnected = true;
        } else {
            m_wifiSsid = "Not Connected";
            m_wifiConnected = false;
        }
    }

    // Signal strength from /proc/net/wireless
    QFile wireless("/proc/net/wireless");
    if (wireless.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&wireless);
        while (!in.atEnd()) {
            QString line = in.readLine();
            if (line.contains("wlan0") || line.contains("wlp")) {
                QStringList tokens = line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);
                if (tokens.size() > 3) {
                    m_wifiSignalDbm = tokens[3].remove('.').toInt();
                    if (m_wifiSignalDbm >= -50) m_wifiSignalBars = 4;
                    else if (m_wifiSignalDbm >= -60) m_wifiSignalBars = 3;
                    else if (m_wifiSignalDbm >= -70) m_wifiSignalBars = 2;
                    else if (m_wifiSignalDbm >= -80) m_wifiSignalBars = 1;
                    else m_wifiSignalBars = 0;
                }
            }
        }
        wireless.close();
    }

    // Link speed from iwconfig
    process.start("iwconfig", QStringList() << "wlan0");
    if (process.waitForFinished(1000)) {
        QString output = QString::fromUtf8(process.readAllStandardOutput());
        QRegularExpression rateRe("Bit Rate[=:]([0-9.]+ [MG]b/s)");
        QRegularExpressionMatch rateMatch = rateRe.match(output);
        if (rateMatch.hasMatch()) {
            m_linkSpeed = rateMatch.captured(1);
        }
    }

    emit wifiChanged();
#endif
}

void NetworkMonitor::sampleWifiInfoSync()
{
#ifdef Q_OS_MACOS
    QProcess process;
    process.start("ipconfig", QStringList() << "getsummary" << "en0");
    if (process.waitForFinished(1000)) {
        QString output = QString::fromUtf8(process.readAllStandardOutput());
        QRegularExpression ssidRe("SSID\\s*:\\s*(.+)");
        QRegularExpressionMatch match = ssidRe.match(output);
        if (match.hasMatch()) {
            QString ssid = match.captured(1).trimmed();
            if (!ssid.isEmpty()) {
                m_wifiSsid = ssid;
                m_wifiConnected = true;
                emit wifiChanged();
            }
        }
    }
#elif defined(Q_OS_LINUX)
    QProcess process;
    process.start("iwgetid", QStringList() << "-r");
    if (process.waitForFinished(1000)) {
        QString ssid = QString::fromUtf8(process.readAllStandardOutput()).trimmed();
        if (!ssid.isEmpty()) {
            m_wifiSsid = ssid;
            m_wifiConnected = true;
            emit wifiChanged();
        }
    }
#endif
}

void NetworkMonitor::detectEthernet()
{
    bool found = false;
    QString ip = "Not Assigned";
    QString speed = "—";
    QString duplex = "—";

#ifdef Q_OS_UNIX
    struct ifaddrs *ifap = nullptr;
    if (getifaddrs(&ifap) == 0) {
        for (struct ifaddrs *ifa = ifap; ifa != nullptr; ifa = ifa->ifa_next) {
            if (!ifa->ifa_addr) continue;
            QString name(ifa->ifa_name);
            // Check non-loopback ethernet interfaces (excluding Wi-Fi en0)
            if (name != "en0" && (name.startsWith("en") || name.startsWith("eth"))) {
                if ((ifa->ifa_flags & IFF_UP) && (ifa->ifa_flags & IFF_RUNNING)) {
                    if (ifa->ifa_addr->sa_family == AF_INET) {
                        struct sockaddr_in *sa = reinterpret_cast<struct sockaddr_in *>(ifa->ifa_addr);
                        char addrStr[INET_ADDRSTRLEN];
                        if (inet_ntop(AF_INET, &(sa->sin_addr), addrStr, INET_ADDRSTRLEN)) {
                            QString ipStr = QString::fromLatin1(addrStr);
                            if (!ipStr.isEmpty() && !ipStr.startsWith("127.")) {
                                found = true;
                                ip = ipStr;
                                speed = "1 Gbps";
                                duplex = "Full";
                                break;
                            }
                        }
                    }
                }
            }
        }
        freeifaddrs(ifap);
    }
#endif

    if (m_ethernetConnected != found || m_ethernetIp != ip || m_ethernetSpeed != speed || m_ethernetDuplex != duplex) {
        m_ethernetConnected = found;
        m_ethernetIp = ip;
        m_ethernetSpeed = speed;
        m_ethernetDuplex = duplex;
        emit ethernetChanged();
    }
}

void NetworkMonitor::tick()
{
    sampleThroughput();
    m_tickCounter++;
    if (m_tickCounter % 8 == 0) {
        detectEthernet();
    }
}
