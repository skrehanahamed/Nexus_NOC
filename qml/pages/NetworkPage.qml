/**
 * ============================================================================
 * Nexus NOC - Enterprise Network Operations Center Appliance
 * Copyright (c) 2026 Sk Rehan Ahamed
 * Developer: Sk Rehan Ahamed (https://github.com/skrehanahamed)
 * Licensed under the MIT License
 * ============================================================================
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import NexusNOC
import "../components"

Item {
    id: root

    // ========================================================================
    // Dynamic KPI Properties connected to C++ Backend (NetworkMonitor & DeviceManager)
    // ========================================================================
    property int wifiClientCount: (typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.wifiClientCount : 5
    property int ethernetClientCount: (typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.ethernetClientCount : 2
    property int totalDeviceCount: (typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.totalDeviceCount : 12
    property real downloadMbps: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.downloadMbps : 86.4
    property real uploadMbps: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.uploadMbps : 32.1
    property real averageLatency: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.averageLatency : 30.4

    // Selected Time Range: 1H | 6H | 24H | 7D | 30D (Default: 1H)
    property string selectedRange: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.timeRange : "1H"

    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // ====================================================================
        // 1. Network Page Header with Time-Range Selector
        // ====================================================================
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                spacing: 3
                Layout.fillWidth: true

                Text {
                    text: "Network"
                    font.pixelSize: 22
                    font.bold: true
                    font.family: Theme.fontSans
                    color: Theme.textPrimary
                }

                Text {
                    text: "Monitor, analyze and manage your network infrastructure in real-time."
                    font.pixelSize: 12
                    font.family: Theme.fontSans
                    color: Theme.textSecondary
                }
            }

            Item { Layout.fillWidth: true }

            // Time-Range Selector: 1H | 6H | 24H | 7D | 30D
            Rectangle {
                height: 32
                implicitWidth: rangeRow.implicitWidth + 8
                radius: 6
                color: "#0B1322"
                border.color: "#1B2A42"
                border.width: 1

                RowLayout {
                    id: rangeRow
                    anchors.centerIn: parent
                    spacing: 2

                    Repeater {
                        model: ["1H", "6H", "24H", "7D", "30D"]
                        delegate: Rectangle {
                            width: 38
                            height: 26
                            radius: 4
                            color: root.selectedRange === modelData ? Theme.accentPrimary : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 11
                                font.bold: root.selectedRange === modelData
                                font.family: Theme.fontMono
                                color: root.selectedRange === modelData ? "#FFFFFF" : Theme.textSecondary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.selectedRange = modelData;
                                    if (typeof networkMonitor !== "undefined" && networkMonitor) {
                                        networkMonitor.setTimeRange(modelData);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ====================================================================
        // 2. First KPI Row: 6 Compact Network Cards
        // ====================================================================
        RowLayout {
            id: kpiRow
            Layout.fillWidth: true
            Layout.preferredHeight: 96
            spacing: 12

            // 1. Wi-Fi Clients
            NetworkKpiCard {
                title: "Wi-Fi Clients"
                value: root.wifiClientCount.toString()
                unit: "Clients"
                trendText: "↑ 2"
                isTrendPositive: true
                iconSource: "qrc:/qt/qml/NexusNOC/qml/assets/kpi/kpi_wifi.png"
                iconName: "wifi"
                iconColor: "#00E676"
                sparkColor: "#00E676"
                sparkPoints: [0.3, 0.4, 0.35, 0.6, 0.5, 0.75, 0.65, 0.85]
            }

            // 2. Ethernet Clients
            NetworkKpiCard {
                title: "Ethernet Clients"
                value: root.ethernetClientCount.toString()
                unit: "Clients"
                trendText: "↑ 1"
                isTrendPositive: true
                iconSource: "qrc:/qt/qml/NexusNOC/qml/assets/kpi/kpi_ethernet.png"
                iconName: "ethernet"
                iconColor: "#38BDF8"
                sparkColor: "#38BDF8"
                sparkPoints: [0.4, 0.35, 0.5, 0.45, 0.6, 0.55, 0.7, 0.8]
            }

            // 3. Total Devices
            NetworkKpiCard {
                title: "Total Devices"
                value: root.totalDeviceCount.toString()
                unit: "Devices"
                trendText: "↑ 3"
                isTrendPositive: true
                iconSource: "qrc:/qt/qml/NexusNOC/qml/assets/kpi/kpi_devices.png"
                iconName: "devices"
                iconColor: "#38BDF8"
                sparkColor: "#38BDF8"
                sparkPoints: [0.3, 0.45, 0.4, 0.65, 0.55, 0.8, 0.7, 0.9]
            }

            // 4. Download
            NetworkKpiCard {
                title: "Download"
                value: root.downloadMbps.toFixed(1)
                unit: "Mbps"
                trendText: ""
                isTrendPositive: true
                iconSource: "qrc:/qt/qml/NexusNOC/qml/assets/kpi/kpi_download.png"
                iconName: "arrow-down"
                iconColor: "#00E676"
                sparkColor: "#00E676"
                sparkPoints: (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.trafficHistoryDl && networkMonitor.trafficHistoryDl.length > 0) ?
                    networkMonitor.trafficHistoryDl.slice(-10).map(v => Math.min(1.0, Math.max(0.1, v / 120.0))) :
                    [0.2, 0.5, 0.4, 0.8, 0.6, 0.7, 0.85, 0.75]
            }

            // 5. Upload
            NetworkKpiCard {
                title: "Upload"
                value: root.uploadMbps.toFixed(1)
                unit: "Mbps"
                trendText: ""
                isTrendPositive: true
                iconSource: "qrc:/qt/qml/NexusNOC/qml/assets/kpi/kpi_upload.png"
                iconName: "arrow-up"
                iconColor: "#38BDF8"
                sparkColor: "#38BDF8"
                sparkPoints: (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.trafficHistoryUl && networkMonitor.trafficHistoryUl.length > 0) ?
                    networkMonitor.trafficHistoryUl.slice(-10).map(v => Math.min(1.0, Math.max(0.1, v / 60.0))) :
                    [0.2, 0.35, 0.3, 0.6, 0.45, 0.55, 0.5, 0.65]
            }

            // 6. Average Latency
            NetworkKpiCard {
                title: "Average Latency"
                value: root.averageLatency.toFixed(1)
                unit: "ms"
                trendText: ""
                isTrendPositive: true
                iconSource: "qrc:/qt/qml/NexusNOC/qml/assets/kpi/kpi_latency.png"
                iconName: "globe"
                iconColor: "#38BDF8"
                sparkColor: "#38BDF8"
                sparkPoints: [0.6, 0.4, 0.55, 0.45, 0.5, 0.4, 0.45, 0.4]
            }
        }

        // Breathing space / placeholder below KPI row for future sections
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
