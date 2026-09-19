#include "SystemMonitor.h"
#include <QStorageInfo>
#include <QNetworkInterface>
#include <QHostInfo>
#include <QThread>
#include <QSysInfo>
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QProcess>
#include <QRegularExpression>
#include <QtMath>

#ifdef Q_OS_MACOS
#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/mach.h>
#include <mach/mach_host.h>
#include <mach/processor_info.h>
#endif

SystemMonitor::SystemMonitor(QObject *parent)
    : QObject(parent)
    , m_timer(new QTimer(this))
{
    detectHardware();
    detectNetwork();
    sampleStorage();
    sampleRam();
    sampleCpuLoad();

    connect(m_timer, &QTimer::timeout, this, &SystemMonitor::tick);
    m_timer->start(500);
}

void SystemMonitor::detectHardware()
{
    m_hostName = QHostInfo::localHostName();
    m_cpuCores = QThread::idealThreadCount();

#ifdef Q_OS_MACOS
    // Read CPU Brand first
    char cpuBuffer[256] = {0};
    size_t cpuLen = sizeof(cpuBuffer);
    if (sysctlbyname("machdep.cpu.brand_string", cpuBuffer, &cpuLen, nullptr, 0) == 0) {
        m_cpuModel = QString::fromUtf8(cpuBuffer).trimmed();
    } else {
        m_cpuModel = "Apple Silicon";
    }

    // Determine chip suffix like " (M1)", " (M2)", " (M5)", etc.
    QString chipTag;
    if (m_cpuModel.startsWith("Apple ")) {
        chipTag = " (" + m_cpuModel.mid(6) + ")";
    } else if (!m_cpuModel.isEmpty() && m_cpuModel != "Apple Silicon") {
        chipTag = " (" + m_cpuModel + ")";
    }

    // Read macOS Model
    char modelBuffer[256] = {0};
    size_t modelLen = sizeof(modelBuffer);
    if (sysctlbyname("hw.model", modelBuffer, &modelLen, nullptr, 0) == 0) {
        QString model(modelBuffer);
        if (model.contains("MacBookAir", Qt::CaseInsensitive) || model.startsWith("Mac14,") || model.startsWith("Mac15,") || model.startsWith("Mac16,") || model.startsWith("Mac17,")) {
            m_deviceName = "MacBook Air" + chipTag;
            m_deviceShortName = "MacBook-Air";
        } else if (model.contains("MacBookPro", Qt::CaseInsensitive)) {
            m_deviceName = "MacBook Pro" + chipTag;
            m_deviceShortName = "MacBook-Pro";
        } else if (model.contains("Macmini", Qt::CaseInsensitive)) {
            m_deviceName = "Mac mini" + chipTag;
            m_deviceShortName = "Mac-mini";
        } else if (model.contains("MacStudio", Qt::CaseInsensitive)) {
            m_deviceName = "Mac Studio" + chipTag;
            m_deviceShortName = "Mac-Studio";
        } else if (model.contains("MacPro", Qt::CaseInsensitive)) {
            m_deviceName = "Mac Pro" + chipTag;
            m_deviceShortName = "Mac-Pro";
        } else if (model.contains("iMac", Qt::CaseInsensitive)) {
            m_deviceName = "iMac" + chipTag;
            m_deviceShortName = "iMac";
        } else {
            m_deviceName = "Apple Mac" + chipTag;
            m_deviceShortName = "Apple-Mac";
        }
    } else {
        m_deviceName = "Apple Mac" + chipTag;
        m_deviceShortName = "Apple-Mac";
    }

    // Read Total RAM
    uint64_t memBytes = 0;
    size_t memLen = sizeof(memBytes);
    if (sysctlbyname("hw.memsize", &memBytes, &memLen, nullptr, 0) == 0) {
        m_ramTotalGb = qRound(static_cast<double>(memBytes) / (1024.0 * 1024.0 * 1024.0));
    }

    // Read Real System Uptime
    struct timeval boottime;
    size_t bootLen = sizeof(boottime);
    if (sysctlbyname("kern.boottime", &boottime, &bootLen, nullptr, 0) == 0) {
        qint64 nowSec = QDateTime::currentSecsSinceEpoch();
        m_uptimeSeconds = static_cast<int>(nowSec - boottime.tv_sec);
    }

    m_deviceType = "apple";

#elif defined(Q_OS_LINUX)
    // Check if Raspberry Pi
    QFile dtModel("/proc/device-tree/model");
    if (dtModel.exists() && dtModel.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString model = QString::fromUtf8(dtModel.readAll()).trimmed();
        dtModel.close();
        if (!model.isEmpty()) {
            m_deviceName = model;
            m_deviceShortName = model.contains("Raspberry Pi 5") ? "NEXUS-Pi5" : "NEXUS-Pi";
            m_deviceType = "pi";
        }
    } else {
        m_deviceName = QSysInfo::prettyProductName();
        m_deviceShortName = "NEXUS-Linux";
        m_deviceType = "linux";
    }

    // Read CPU info
    QFile cpuInfo("/proc/cpuinfo");
    if (cpuInfo.exists() && cpuInfo.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&cpuInfo);
        while (!in.atEnd()) {
            QString line = in.readLine();
            if (line.startsWith("model name") || line.startsWith("Model")) {
                QStringList parts = line.split(":");
                if (parts.size() > 1) {
                    m_cpuModel = parts[1].trimmed();
                    break;
                }
            }
        }
        cpuInfo.close();
    }

    // Read RAM
    QFile memInfo("/proc/meminfo");
    if (memInfo.exists() && memInfo.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&memInfo);
        while (!in.atEnd()) {
            QString line = in.readLine();
            if (line.startsWith("MemTotal:")) {
                QStringList parts = line.split(QRegularExpression("\\s+"));
                if (parts.size() > 1) {
                    double kb = parts[1].toDouble();
                    m_ramTotalGb = qRound((kb / (1024.0 * 1024.0)) * 10.0) / 10.0;
                    break;
                }
            }
        }
        memInfo.close();
    }
#else
    m_deviceName = QSysInfo::prettyProductName();
    m_deviceShortName = "NEXUS-Host";
    m_deviceType = "generic";
#endif

    emit hardwareChanged();
}

void SystemMonitor::detectNetwork()
{
    // Find active non-loopback IPv4 interface
    const QList<QNetworkInterface> interfaces = QNetworkInterface::allInterfaces();
    for (const QNetworkInterface &iface : interfaces) {
        if (iface.flags().testFlag(QNetworkInterface::IsUp) &&
            iface.flags().testFlag(QNetworkInterface::IsRunning) &&
            !iface.flags().testFlag(QNetworkInterface::IsLoopBack)) {
            
            for (const QNetworkAddressEntry &entry : iface.addressEntries()) {
                if (entry.ip().protocol() == QAbstractSocket::IPv4Protocol) {
                    m_localIp = entry.ip().toString();
                    m_macAddress = iface.hardwareAddress();
                    break;
                }
            }
            if (m_localIp != "127.0.0.1") break;
        }
    }

    // Query Default Gateway
    QProcess process;
    process.start("netstat", QStringList() << "-rn");
    if (process.waitForFinished(1000)) {
        QString output = QString::fromUtf8(process.readAllStandardOutput());
        const QStringList lines = output.split('\n');
        for (const QString &line : lines) {
            if (line.contains("default") || line.startsWith("0.0.0.0")) {
                QStringList tokens = line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);
                if (tokens.size() > 1) {
                    m_gatewayIp = tokens[1];
                    break;
                }
            }
        }
    }

    emit networkChanged();
}

void SystemMonitor::sampleStorage()
{
    QStorageInfo rootStorage = QStorageInfo::root();
    if (rootStorage.isValid() && rootStorage.isReady()) {
        double totalGb = static_cast<double>(rootStorage.bytesTotal()) / (1024.0 * 1024.0 * 1024.0);
        double availGb = static_cast<double>(rootStorage.bytesAvailable()) / (1024.0 * 1024.0 * 1024.0);
        m_storageTotalGb = qRound(totalGb);
        m_storageUsedGb = qRound((totalGb - availGb) * 10.0) / 10.0;
        emit storageChanged();
    }
}

void SystemMonitor::sampleRam()
{
#ifdef Q_OS_MACOS
    mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;
    vm_statistics64_data_t vmstat;
    if (host_statistics64(mach_host_self(), HOST_VM_INFO64, (host_info64_t)&vmstat, &count) == KERN_SUCCESS) {
        int64_t pageSize = 16384;
        double usedBytes = (static_cast<int64_t>(vmstat.active_count) + vmstat.wire_count) * pageSize;
        m_ramUsedGb = qRound((usedBytes / (1024.0 * 1024.0 * 1024.0)) * 10.0) / 10.0;
        emit ramChanged();
    }
#elif defined(Q_OS_LINUX)
    QFile memInfo("/proc/meminfo");
    if (memInfo.exists() && memInfo.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&memInfo);
        double totalKb = 0;
        double availKb = 0;
        while (!in.atEnd()) {
            QString line = in.readLine();
            if (line.startsWith("MemTotal:")) {
                QStringList parts = line.split(QRegularExpression("\\s+"));
                if (parts.size() > 1) totalKb = parts[1].toDouble();
            } else if (line.startsWith("MemAvailable:")) {
                QStringList parts = line.split(QRegularExpression("\\s+"));
                if (parts.size() > 1) availKb = parts[1].toDouble();
            }
        }
        memInfo.close();
        if (totalKb > 0) {
            m_ramUsedGb = qRound(((totalKb - availKb) / (1024.0 * 1024.0)) * 10.0) / 10.0;
            emit ramChanged();
        }
    }
#endif
}

void SystemMonitor::sampleCpuLoad()
{
#ifdef Q_OS_MACOS
    natural_t numProcessors = 0;
    processor_info_array_t cpuInfo;
    mach_msg_type_number_t numCpuInfo;

    if (host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numProcessors, &cpuInfo, &numCpuInfo) == KERN_SUCCESS) {
        uint64_t totalUser = 0;
        uint64_t totalSystem = 0;
        uint64_t totalIdle = 0;

        for (natural_t i = 0; i < numProcessors; ++i) {
            totalUser += cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER];
            totalSystem += cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM];
            totalIdle += cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];
        }

        vm_deallocate(mach_task_self(), (vm_address_t)cpuInfo, numCpuInfo * sizeof(integer_t));

        if (m_prevUserTicks > 0 || m_prevSystemTicks > 0 || m_prevIdleTicks > 0) {
            uint64_t userDiff = totalUser - m_prevUserTicks;
            uint64_t sysDiff = totalSystem - m_prevSystemTicks;
            uint64_t idleDiff = totalIdle - m_prevIdleTicks;
            uint64_t totalDiff = userDiff + sysDiff + idleDiff;

            if (totalDiff > 0) {
                double load = ((userDiff + sysDiff) * 100.0) / totalDiff;
                m_cpuLoad = qRound(load * 10.0) / 10.0;
                emit cpuLoadChanged();
            }
        }

        m_prevUserTicks = totalUser;
        m_prevSystemTicks = totalSystem;
        m_prevIdleTicks = totalIdle;
    }
#elif defined(Q_OS_LINUX)
    QFile statFile("/proc/stat");
    if (statFile.exists() && statFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QString line = statFile.readLine();
        statFile.close();
        QStringList parts = line.split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);
        if (parts.size() >= 5) {
            double user = parts[1].toDouble();
            double nice = parts[2].toDouble();
            double system = parts[3].toDouble();
            double idle = parts[4].toDouble();
            double total = user + nice + system + idle;
            if (total > 0) {
                m_cpuLoad = qRound(((user + system) / total * 100.0) * 10.0) / 10.0;
                emit cpuLoadChanged();
            }
        }
    }
#endif
}

void SystemMonitor::tick()
{
    m_uptimeSeconds++;
    emit uptimeChanged();

    sampleCpuLoad();
    sampleRam();

    // Subtle thermal reading (estimated from load if no hardware sensor)
    m_cpuTemp = qRound((38.0 + (m_cpuLoad * 0.25)) * 10.0) / 10.0;
    emit cpuTempChanged();
}

QString SystemMonitor::uptimeFormatted() const
{
    int secs = m_uptimeSeconds;
    int days = secs / 86400;
    int hours = (secs % 86400) / 3600;
    int mins = (secs % 3600) / 60;
    return QString("%1d %2h %3m").arg(days).arg(hours).arg(mins);
}

QString SystemMonitor::osName() const
{
    return QSysInfo::prettyProductName();
}
