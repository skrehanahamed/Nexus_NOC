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
    // Dynamic KPI Properties connected to 100% Real C++ Backend
    // ========================================================================
    property int wifiClientCount: (typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.wifiClientCount : 0
    property int ethernetClientCount: (typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.ethernetClientCount : 0
    property int totalDeviceCount: (typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.totalDeviceCount : 0
    property real downloadMbps: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.downloadMbps : 0.0
    property real uploadMbps: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.uploadMbps : 0.0
    property real averageLatency: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.averageLatency : 0.0
    property bool wifiActive: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.wifiConnected : true
    property bool ethActive: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.ethernetConnected : false

    // Selected Time Range: 1H | 6H | 24H | 7D | 30D (Default: 1H)
    property string selectedRange: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.timeRange : "1H"

    // Inspected Device state for detail modal
    property var inspectedDevice: null

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
                trendText: root.wifiClientCount > 0 ? (root.wifiClientCount + " Online") : "No Clients"
                isTrendPositive: root.wifiClientCount > 0
                isInactive: !root.wifiActive || root.wifiClientCount === 0
                iconSource: "qrc:/qt/qml/NexusNOC/qml/assets/kpi/kpi_wifi.png"
                iconName: "wifi"
                iconColor: "#00E676"
                sparkColor: "#00E676"
                sparkPoints: [0.3, 0.4, 0.35, 0.6, 0.5, 0.75, 0.65, 0.85]
            }

            // 2. Ethernet Clients (Grayed out with Inactive badge if unplugged/0 clients)
            NetworkKpiCard {
                title: "Ethernet Clients"
                value: root.ethernetClientCount.toString()
                unit: "Clients"
                trendText: (root.ethActive && root.ethernetClientCount > 0) ? (root.ethernetClientCount + " Online") : "Inactive"
                isTrendPositive: root.ethernetClientCount > 0
                isInactive: !root.ethActive && root.ethernetClientCount === 0
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
                trendText: root.totalDeviceCount > 0 ? (root.totalDeviceCount + " Discovered") : "Scanning..."
                isTrendPositive: root.totalDeviceCount > 0
                isInactive: root.totalDeviceCount === 0
                iconSource: "qrc:/qt/qml/NexusNOC/qml/assets/kpi/kpi_devices.png"
                iconName: "devices"
                iconColor: "#38BDF8"
                sparkColor: "#38BDF8"
                sparkPoints: [0.3, 0.45, 0.4, 0.65, 0.55, 0.8, 0.7, 0.9]
            }

            // 4. Download (Real throughput from OS socket deltas)
            NetworkKpiCard {
                title: "Download"
                value: root.downloadMbps > 0.0 ? root.downloadMbps.toFixed(1) : "0.0"
                unit: "Mbps"
                trendText: root.wifiActive ? "Live RX" : "Offline"
                isTrendPositive: true
                isInactive: !root.wifiActive
                iconSource: "qrc:/qt/qml/NexusNOC/qml/assets/kpi/kpi_download.png"
                iconName: "arrow-down"
                iconColor: "#00E676"
                sparkColor: "#00E676"
                sparkPoints: (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.trafficHistoryDl && networkMonitor.trafficHistoryDl.length > 0) ?
                    networkMonitor.trafficHistoryDl.slice(-10).map(v => Math.min(1.0, Math.max(0.05, v / 50.0))) :
                    [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
            }

            // 5. Upload (Real throughput from OS socket deltas)
            NetworkKpiCard {
                title: "Upload"
                value: root.uploadMbps > 0.0 ? root.uploadMbps.toFixed(1) : "0.0"
                unit: "Mbps"
                trendText: root.wifiActive ? "Live TX" : "Offline"
                isTrendPositive: true
                isInactive: !root.wifiActive
                iconSource: "qrc:/qt/qml/NexusNOC/qml/assets/kpi/kpi_upload.png"
                iconName: "arrow-up"
                iconColor: "#38BDF8"
                sparkColor: "#38BDF8"
                sparkPoints: (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.trafficHistoryUl && networkMonitor.trafficHistoryUl.length > 0) ?
                    networkMonitor.trafficHistoryUl.slice(-10).map(v => Math.min(1.0, Math.max(0.05, v / 30.0))) :
                    [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
            }

            // 6. Average Latency (Real live ICMP ping)
            NetworkKpiCard {
                title: "Average Latency"
                value: root.averageLatency > 0.0 ? root.averageLatency.toFixed(1) : "—"
                unit: root.averageLatency > 0.0 ? "ms" : ""
                trendText: root.averageLatency > 0.0 ? (root.averageLatency < 40 ? "Optimal" : "Normal") : "No Ping"
                isTrendPositive: root.averageLatency > 0.0 && root.averageLatency < 60
                isInactive: root.averageLatency <= 0.0
                iconSource: "qrc:/qt/qml/NexusNOC/qml/assets/kpi/kpi_latency.png"
                iconName: "globe"
                iconColor: "#38BDF8"
                sparkColor: "#38BDF8"
                sparkPoints: (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.latencyHistory && networkMonitor.latencyHistory.length > 0) ?
                    networkMonitor.latencyHistory.slice(-10).map(v => Math.min(1.0, Math.max(0.1, v / 100.0))) :
                    [0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2]
            }
        }

        // ====================================================================
        // 3. Second Section: Network Topology (Left) + Network Traffic (Right)
        // ====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            // Left Panel: Network Topology Visualization (~58% width)
            NetworkTopologyCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 580
                onDeviceSelected: function(dev) {
                    root.inspectedDevice = dev;
                }
            }

            // Right Panel: Large Live Network Traffic Graph (~42% width)
            NetworkTrafficCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 420
            }
        }
    }

    // ========================================================================
    // Interactive Device Detail Inspector Modal Drawer
    // ========================================================================
    Rectangle {
        id: inspectorOverlay
        visible: root.inspectedDevice !== null
        anchors.fill: parent
        color: "#A6030712"
        z: 99

        MouseArea {
            anchors.fill: parent
            onClicked: root.inspectedDevice = null
        }

        Rectangle {
            id: inspectorCard
            width: Math.min(420, parent.width - 40)
            height: 330
            radius: 12
            color: "#0E182A"
            border.color: "#1E3A5F"
            border.width: 1.5
            anchors.centerIn: parent

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        width: 38
                        height: 38
                        radius: 19
                        color: "#13233E"
                        border.color: Theme.accentCyan
                        border.width: 1

                        IconDraw {
                            anchors.centerIn: parent
                            iconName: root.inspectedDevice ? (root.inspectedDevice.icon || "laptop") : "laptop"
                            iconColor: Theme.accentCyan
                            iconSize: 20
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Layout.fillWidth: true

                        Text {
                            text: root.inspectedDevice ? root.inspectedDevice.name : "Device Details"
                            font.pixelSize: 15
                            font.bold: true
                            font.family: Theme.fontSans
                            color: Theme.textPrimary
                        }

                        Text {
                            text: (root.inspectedDevice && root.inspectedDevice.online) ? "Online • Active on Subnet" : "Offline"
                            font.pixelSize: 11
                            color: (root.inspectedDevice && root.inspectedDevice.online) ? Theme.statusSuccess : Theme.statusCritical
                        }
                    }

                    Text {
                        text: "✕"
                        font.pixelSize: 16
                        color: Theme.textMuted
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.inspectedDevice = null
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#1B2A42"
                }

                // Device Specs Grid
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 10
                    columnSpacing: 16

                    ColumnLayout {
                        spacing: 2
                        Text { text: "IP ADDRESS"; font.pixelSize: 10; font.bold: true; font.family: Theme.fontMono; color: Theme.textMuted }
                        Text { text: root.inspectedDevice ? (root.inspectedDevice.ip || "—") : "—"; font.pixelSize: 13; font.family: Theme.fontMono; color: Theme.accentCyan }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text { text: "MAC ADDRESS"; font.pixelSize: 10; font.bold: true; font.family: Theme.fontMono; color: Theme.textMuted }
                        Text { text: root.inspectedDevice ? (root.inspectedDevice.mac || "—") : "—"; font.pixelSize: 12; font.family: Theme.fontMono; color: Theme.textSecondary }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text { text: "CONNECTION"; font.pixelSize: 10; font.bold: true; font.family: Theme.fontMono; color: Theme.textMuted }
                        Text { text: root.inspectedDevice ? (root.inspectedDevice.connection || "Wi-Fi") : "Wi-Fi"; font.pixelSize: 13; color: Theme.textPrimary }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text { text: "DEVICE CATEGORY"; font.pixelSize: 10; font.bold: true; font.family: Theme.fontMono; color: Theme.textMuted }
                        Text { text: root.inspectedDevice ? (root.inspectedDevice.type || "Client") : "Client"; font.pixelSize: 13; color: Theme.textPrimary }
                    }
                }

                Item { Layout.fillHeight: true }

                // Actions Row: Ping Diagnostic & Close
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 6
                        color: "#13233E"
                        border.color: Theme.accentCyan

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            IconDraw { iconName: "uptime"; iconColor: Theme.accentCyan; iconSize: 14 }
                            Text { text: "PING DIAGNOSTIC"; font.pixelSize: 11; font.bold: true; color: Theme.accentCyan }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (typeof networkMonitor !== "undefined" && networkMonitor) {
                                    networkMonitor.samplePing();
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 6
                        color: "#162033"
                        border.color: "#2A3A55"

                        Text {
                            anchors.centerIn: parent
                            text: "CLOSE"
                            font.pixelSize: 11
                            font.bold: true
                            color: Theme.textSecondary
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.inspectedDevice = null
                        }
                    }
                }
            }
        }
    }
}
