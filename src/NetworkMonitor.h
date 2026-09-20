/**
 * ============================================================================
 * Nexus NOC - Enterprise Network Operations Center Appliance
 * Copyright (c) 2026 Sk Rehan Ahamed
 * Developer: Sk Rehan Ahamed (https://github.com/skrehanahamed)
 * Licensed under the MIT License
 * ============================================================================
 */

#pragma once

#include <QObject>
#include <QTimer>
#include <QProcess>
#include <QVariantList>

class NetworkMonitor : public QObject {
    Q_OBJECT
    Q_PROPERTY(double rxRateMbps READ rxRateMbps NOTIFY ratesChanged)
    Q_PROPERTY(double txRateMbps READ txRateMbps NOTIFY ratesChanged)
    Q_PROPERTY(double latencyMs READ latencyMs NOTIFY latencyChanged)
    Q_PROPERTY(double packetLoss READ packetLoss NOTIFY latencyChanged)
    Q_PROPERTY(double jitterMs READ jitterMs NOTIFY latencyChanged)
    Q_PROPERTY(QString primaryInterface READ primaryInterface CONSTANT)
    Q_PROPERTY(QVariantList trafficHistoryDl READ trafficHistoryDl NOTIFY historyChanged)
    Q_PROPERTY(QVariantList trafficHistoryUl READ trafficHistoryUl NOTIFY historyChanged)
    Q_PROPERTY(QVariantList latencyHistory READ latencyHistory NOTIFY latencyChanged)
    Q_PROPERTY(QString wifiSsid READ wifiSsid NOTIFY wifiChanged)
    Q_PROPERTY(int wifiSignalDbm READ wifiSignalDbm NOTIFY wifiChanged)
    Q_PROPERTY(int wifiSignalBars READ wifiSignalBars NOTIFY wifiChanged)
    Q_PROPERTY(QString linkSpeed READ linkSpeed NOTIFY wifiChanged)
    Q_PROPERTY(bool wifiConnected READ wifiConnected NOTIFY wifiChanged)
    Q_PROPERTY(bool ethernetConnected READ ethernetConnected NOTIFY ethernetChanged)
    Q_PROPERTY(QString ethernetIp READ ethernetIp NOTIFY ethernetChanged)
    Q_PROPERTY(QString ethernetSpeed READ ethernetSpeed NOTIFY ethernetChanged)
    Q_PROPERTY(QString ethernetDuplex READ ethernetDuplex NOTIFY ethernetChanged)
    Q_PROPERTY(bool internetConnected READ internetConnected NOTIFY latencyChanged)
    Q_PROPERTY(QVariantList networkInterfaces READ networkInterfaces NOTIFY interfacesChanged)
    Q_PROPERTY(qint64 packetsReceived READ packetsReceived NOTIFY packetStatsChanged)
    Q_PROPERTY(qint64 packetsSent READ packetsSent NOTIFY packetStatsChanged)
    Q_PROPERTY(qint64 packetErrors READ packetErrors NOTIFY packetStatsChanged)
    Q_PROPERTY(double downloadMbps READ downloadMbps NOTIFY ratesChanged)
    Q_PROPERTY(double uploadMbps READ uploadMbps NOTIFY ratesChanged)
    Q_PROPERTY(double averageLatency READ averageLatency NOTIFY latencyChanged)
    Q_PROPERTY(QString timeRange READ timeRange NOTIFY timeRangeChanged)

public:
    explicit NetworkMonitor(QObject *parent = nullptr);

    double rxRateMbps() const { return m_rxRateMbps; }
    double txRateMbps() const { return m_txRateMbps; }
    double latencyMs() const { return m_latencyMs; }
    double packetLoss() const { return m_packetLoss; }
    double jitterMs() const { return m_jitterMs; }
    QString primaryInterface() const { return m_primaryInterface; }
    QVariantList trafficHistoryDl() const { return m_trafficHistoryDl; }
    QVariantList trafficHistoryUl() const { return m_trafficHistoryUl; }
    QVariantList latencyHistory() const { return m_latencyHistory; }
    QString wifiSsid() const { return m_wifiSsid; }
    int wifiSignalDbm() const { return m_wifiSignalDbm; }
    int wifiSignalBars() const { return m_wifiSignalBars; }
    QString linkSpeed() const { return m_linkSpeed; }
    bool wifiConnected() const { return m_wifiConnected; }
    bool ethernetConnected() const { return m_ethernetConnected; }
    QString ethernetIp() const { return m_ethernetIp; }
    QString ethernetSpeed() const { return m_ethernetSpeed; }
    QString ethernetDuplex() const { return m_ethernetDuplex; }
    bool internetConnected() const { return m_packetLoss < 100.0 && m_latencyMs > 0; }
    QVariantList networkInterfaces() const { return m_networkInterfaces; }
    qint64 packetsReceived() const { return m_packetsReceived; }
    qint64 packetsSent() const { return m_packetsSent; }
    qint64 packetErrors() const { return m_packetErrors; }
    double downloadMbps() const { return m_rxRateMbps; }
    double uploadMbps() const { return m_txRateMbps; }
    double averageLatency() const { return m_latencyMs; }
    QString timeRange() const { return m_timeRange; }

    Q_INVOKABLE void setTimeRange(const QString &range);

signals:
    void ratesChanged();
    void latencyChanged();
    void historyChanged();
    void wifiChanged();
    void ethernetChanged();
    void interfacesChanged();
    void packetStatsChanged();
    void timeRangeChanged();

private slots:
    void tick();
    void samplePing();

private:
    void sampleThroughput();
    void sampleWifiInfo();
    void sampleWifiInfoSync();
    void detectEthernet();
    void sampleInterfaces();

    double m_rxRateMbps = 0.0;
    double m_txRateMbps = 0.0;
    double m_latencyMs = 0.0;
    double m_packetLoss = 0.0;
    double m_jitterMs = 0.0;
    QString m_primaryInterface = "en0";

    uint64_t m_prevRxBytes = 0;
    uint64_t m_prevTxBytes = 0;
    qint64 m_prevSampleTime = 0;
    int m_tickCounter = 0;

    QVariantList m_trafficHistoryDl;
    QVariantList m_trafficHistoryUl;
    QVariantList m_latencyHistory;

    QVariantList m_networkInterfaces;
    qint64 m_packetsReceived = 1482930;
    qint64 m_packetsSent = 938210;
    qint64 m_packetErrors = 0;
    QString m_timeRange = "1H";

    QString m_wifiSsid;
    int m_wifiSignalDbm = 0;
    int m_wifiSignalBars = 0;
    QString m_linkSpeed;
    bool m_wifiConnected = false;

    bool m_ethernetConnected = false;
    QString m_ethernetIp = "Not Assigned";
    QString m_ethernetSpeed = "—";
    QString m_ethernetDuplex = "—";

    QTimer *m_timer;
    QTimer *m_pingTimer;
    QTimer *m_wifiTimer;
    QProcess *m_pingProcess;
    QProcess *m_wifiProcess;
};
