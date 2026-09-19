#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QIcon>

#include "src/SystemMonitor.h"
#include "src/NetworkMonitor.h"
#include "src/DeviceManager.h"
#include "src/ServiceManager.h"

int main(int argc, char *argv[])
{
    // High-DPI scaling is enabled by default in Qt 6
    QGuiApplication app(argc, argv);

    app.setApplicationName("NexusNOC");
    app.setOrganizationName("NexusNetworks");
    app.setApplicationDisplayName("NEXUS NOC – Network Operations & Control Console");

    // Use Basic/Material style for clean dark appliance rendering
    QQuickStyle::setStyle("Basic");

    QQmlApplicationEngine engine;

    // Instantiate backend singletons for QML access
    SystemMonitor systemMonitor;
    NetworkMonitor networkMonitor;
    DeviceManager deviceManager;
    ServiceManager serviceManager;

    engine.rootContext()->setContextProperty("systemMonitor", &systemMonitor);
    engine.rootContext()->setContextProperty("networkMonitor", &networkMonitor);
    engine.rootContext()->setContextProperty("deviceManager", &deviceManager);
    engine.rootContext()->setContextProperty("serviceManager", &serviceManager);

    // Load Main.qml
    const QUrl url(QStringLiteral("qrc:/qt/qml/NexusNOC/qml/Main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
