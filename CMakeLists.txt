cmake_minimum_required(VERSION 3.20)

project(NexusNOC VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Gui Quick QuickControls2)

if(QT_KNOWN_POLICY_QTP0004)
    qt_policy(SET QTP0004 NEW)
endif()

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(NexusNOC
    main.cpp
    src/SystemMonitor.h
    src/SystemMonitor.cpp
    src/NetworkMonitor.h
    src/NetworkMonitor.cpp
    src/DeviceManager.h
    src/DeviceManager.cpp
    src/ServiceManager.h
    src/ServiceManager.cpp
)

set_source_files_properties(qml/Theme.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(NexusNOC
    URI NexusNOC
    VERSION 1.0
    RESOURCES
        qml/assets/logo.png
        qml/assets/image.png
        qml/assets/icon_nexus_logo.png
        qml/assets/icon_clock.png
        qml/assets/icon_uptime.png
        qml/assets/icon_status_check.png
        qml/assets/nav_overview.png
        qml/assets/nav_network.png
        qml/assets/nav_devices.png
        qml/assets/nav_services.png
        qml/assets/nav_docker.png
        qml/assets/nav_system.png
        qml/assets/nav_logs.png
        qml/assets/nav_alerts.png
        qml/assets/nav_settings.png
        qml/assets/apple_logo_white.png
        qml/assets/device_macbook_air.png
        qml/assets/raspberry_pi_logo.png
        qml/assets/linux_logo.png
        qml/assets/globe.jpg
        qml/assets/hero_bg.png
        qml/assets/nexus_noc_wordmark.png
        qml/assets/card_icon_wifi.png
        qml/assets/card_icon_gateway.png
        qml/assets/card_icon_internet.png
        qml/assets/card_icon_devices.png
        qml/assets/card_icon_docker.png
        qml/assets/card_icon_services.png
        qml/assets/topo_globe.png
        qml/assets/topo_router.png
        qml/assets/topo_rpi.png
        qml/assets/topo_laptop.png
        qml/assets/topo_phone.png
        qml/assets/topo_tv.png
        qml/assets/topo_iot.png
        qml/assets/topo_rpi_board.png
        qml/assets/alert_bell_red.png
        qml/assets/alert_bell_amber.png
        qml/assets/alert_bell_green.png
    QML_FILES
        qml/Main.qml
        qml/Theme.qml
        qml/components/HeroBanner.qml
        qml/components/NetworkTrafficGraph.qml
        qml/components/ResourceGauge.qml
        qml/sections/SystemMonitoringSection.qml
        qml/components/StatusCard.qml
        qml/components/MetricCard.qml
        qml/components/NetworkCard.qml
        qml/components/DeviceCard.qml
        qml/components/ServiceCard.qml
        qml/components/AlertCard.qml
        qml/components/Graph.qml
        qml/components/CircularGauge.qml
        qml/components/LatencyGraph.qml
        qml/components/TopologyView.qml
        qml/components/IconDraw.qml
        qml/pages/OverviewPage.qml
        qml/pages/NetworkPage.qml
        qml/pages/DevicesPage.qml
        qml/pages/ServicesPage.qml
        qml/pages/DockerPage.qml
        qml/pages/SystemPage.qml
        qml/pages/LogsPage.qml
        qml/pages/AlertsPage.qml
        qml/pages/SettingsPage.qml
        qml/navigation/Sidebar.qml
)

target_link_libraries(NexusNOC
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Quick
        Qt6::QuickControls2
)

set_target_properties(NexusNOC PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

include(GNUInstallDirs)
install(TARGETS NexusNOC
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
