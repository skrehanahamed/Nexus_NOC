/**
 * ============================================================================
 * Nexus NOC - Enterprise Network Operations Center Appliance
 * Copyright (c) 2026 Sk Rehan Ahamed
 * Developer: Sk Rehan Ahamed (https://github.com/skrehanahamed)
 * Licensed under the MIT License
 * ============================================================================
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import NexusNOC
import "../components"

Flickable {
    id: root

    contentWidth: width
    contentHeight: mainCol.implicitHeight + 40
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    property string selectedTimeRange: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.timeRange : "1H"
    property var inspectedDevice: null

    ColumnLayout {
        id: mainCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        spacing: 16

        // ====================================================================
        // 1. Network Page Header
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

                Row {
                    id: rangeRow
                    anchors.centerIn: parent
                    spacing: 2

                    Repeater {
                        model: ["1H", "6H", "24H", "7D", "30D"]

                        Rectangle {
                            width: 44
                            height: 26
                            radius: 4
                            color: root.selectedTimeRange === modelData ? "#0284C7" : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 11
                                font.bold: root.selectedTimeRange === modelData
                                font.family: Theme.fontMono
                                color: root.selectedTimeRange === modelData ? "#FFFFFF" : Theme.textSecondary
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.selectedTimeRange = modelData;
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
        // 2. Network KPI Row (6 Cards)
        // ====================================================================
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // 1. Wi-Fi Clients
            NetworkKpiCard {
                title: "Wi-Fi Clients"
                value: (typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.wifiClientCount.toString() : "5"
                trendText: "↑ 2"
                isTrendPositive: true
                iconName: "wifi"
                iconColor: "#38BDF8"
                sparkColor: "#38BDF8"
                sparkPoints: [0.3, 0.4, 0.35, 0.6, 0.5, 0.8, 0.75, 0.95]
            }

            // 2. Ethernet Clients
            NetworkKpiCard {
                title: "Ethernet Clients"
                value: (typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.ethernetClientCount.toString() : "2"
                trendText: "↑ 1"
                isTrendPositive: true
                iconName: "ethernet"
                iconColor: "#00E676"
                sparkColor: "#00E676"
                sparkPoints: [0.2, 0.3, 0.5, 0.4, 0.7, 0.65, 0.85, 0.9]
            }

            // 3. Total Devices
            NetworkKpiCard {
                title: "Total Devices"
                value: (typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.totalDeviceCount.toString() : "12"
                trendText: "↑ 3"
                isTrendPositive: true
                iconName: "devices"
                iconColor: "#38BDF8"
                sparkColor: "#38BDF8"
                sparkPoints: [0.4, 0.35, 0.55, 0.5, 0.7, 0.8, 0.75, 0.95]
            }

            // 4. Download
            NetworkKpiCard {
                title: "Download"
                value: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.rxRateMbps.toFixed(1) : "86.4"
                unit: "Mbps"
                iconName: "arrow-down"
                iconColor: "#00E676"
                sparkColor: "#00E676"
                sparkPoints: [0.5, 0.7, 0.6, 0.85, 0.7, 0.9, 0.8, 0.95]
            }

            // 5. Upload
            NetworkKpiCard {
                title: "Upload"
                value: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.txRateMbps.toFixed(1) : "32.1"
                unit: "Mbps"
                iconName: "arrow-up"
                iconColor: "#38BDF8"
                sparkColor: "#38BDF8"
                sparkPoints: [0.3, 0.5, 0.45, 0.7, 0.6, 0.8, 0.75, 0.85]
            }

            // 6. Average Latency
            NetworkKpiCard {
                title: "Avg. Latency"
                value: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.latencyMs.toFixed(1) : "30.4"
                unit: "ms"
                iconName: "globe"
                iconColor: "#38BDF8"
                sparkColor: "#38BDF8"
                sparkPoints: [0.6, 0.4, 0.55, 0.45, 0.5, 0.4, 0.45, 0.4]
            }
        }

        // ====================================================================
        // 3. Middle Row: Network Topology (Left) + Traffic & Interfaces (Right)
        // ====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 340
            spacing: 12

            // Left: Network Topology Panel (~58% width)
            NetworkTopologyCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 580
                onDeviceSelected: function(dev) {
                    root.inspectedDevice = dev;
                }
            }

            // Right: Traffic & Interfaces Column (~42% width)
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 420
                spacing: 12

                // Top: Network Traffic Graph
                NetworkTrafficCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 164
                }

                // Bottom: Network Interfaces Table
                NetworkInterfacesCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 164
                }
            }
        }

        // ====================================================================
        // 4. Bottom Row: Connected Devices (Left) + Network Statistics (Right)
        // ====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 250
            spacing: 12

            // Left: Connected Devices Table (~58% width)
            ConnectedDevicesCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 580
                onDeviceClicked: function(dev) {
                    root.inspectedDevice = dev;
                }
                onViewAllClicked: {
                    // Navigate to Devices page if root window has page switching
                    if (typeof root.parent !== "undefined" && root.parent.currentIndex !== undefined) {
                        root.parent.currentIndex = 2; // Devices index
                    }
                }
            }

            // Right: Network Statistics 2x2 Grid (~42% width)
            NetworkStatsCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 420
                onViewAllClicked: {
                    if (typeof root.parent !== "undefined" && root.parent.currentIndex !== undefined) {
                        root.parent.currentIndex = 2;
                    }
                }
            }
        }
    }

    // ========================================================================
    // 5. Interactive Device Detail Inspector Overlay
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
                anchors.fill: parent // Prevent clicks closing through card
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14

                // Modal Header
                RowLayout {
                    Layout.fillWidth: true

                    Rectangle {
                        width: 38; height: 38; radius: 19
                        color: Qt.rgba(0, 229, 255, 0.15)
                        border.color: Theme.accentCyan
                        IconDraw {
                            anchors.centerIn: parent
                            iconName: (root.inspectedDevice && root.inspectedDevice.icon) ? root.inspectedDevice.icon : "devices"
                            iconColor: Theme.accentCyan
                            iconSize: 18
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: root.inspectedDevice ? root.inspectedDevice.name : "Device Details"
                            font.pixelSize: 15
                            font.bold: true
                            font.family: Theme.fontSans
                            color: Theme.textPrimary
                        }

                        RowLayout {
                            spacing: 6
                            Rectangle {
                                width: 7; height: 7; radius: 3.5
                                color: (root.inspectedDevice && root.inspectedDevice.online === false) ? "#64748B" : "#00E676"
                            }
                            Text {
                                text: (root.inspectedDevice && root.inspectedDevice.online === false) ? "Offline" : "Online & Active"
                                font.pixelSize: 11
                                font.bold: true
                                color: (root.inspectedDevice && root.inspectedDevice.online === false) ? "#64748B" : "#00E676"
                            }
                        }
                    }

                    // Close Button
                    Rectangle {
                        width: 28; height: 28; radius: 14
                        color: "#16233B"
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 12
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
                        Text { text: root.inspectedDevice ? (root.inspectedDevice.ip || "192.168.1.45") : "—"; font.pixelSize: 13; font.family: Theme.fontMono; color: Theme.accentCyan }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text { text: "MAC ADDRESS"; font.pixelSize: 10; font.bold: true; font.family: Theme.fontMono; color: Theme.textMuted }
                        Text { text: root.inspectedDevice ? (root.inspectedDevice.mac || "F0:18:98:C2:55:10") : "—"; font.pixelSize: 12; font.family: Theme.fontMono; color: Theme.textSecondary }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text { text: "CONNECTION"; font.pixelSize: 10; font.bold: true; font.family: Theme.fontMono; color: Theme.textMuted }
                        Text { text: root.inspectedDevice ? (root.inspectedDevice.connection || "Wi-Fi 6") : "Wi-Fi"; font.pixelSize: 13; color: Theme.textPrimary }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text { text: "DEVICE CATEGORY"; font.pixelSize: 10; font.bold: true; font.family: Theme.fontMono; color: Theme.textMuted }
                        Text { text: root.inspectedDevice ? (root.inspectedDevice.type || "Client") : "Client"; font.pixelSize: 13; color: Theme.textPrimary }
                    }
                }

                Item { Layout.fillHeight: true }

                // Actions Row
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
                                // Trigger live ping
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
                        color: "#2E1520"
                        border.color: Theme.statusCritical

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            IconDraw { iconName: "power"; iconColor: Theme.statusCritical; iconSize: 14 }
                            Text { text: "RESTRICT ACCESS"; font.pixelSize: 11; font.bold: true; color: Theme.statusCritical }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.inspectedDevice && root.inspectedDevice.mac) {
                                    if (typeof deviceManager !== "undefined" && deviceManager) {
                                        deviceManager.blockDevice(root.inspectedDevice.mac);
                                    }
                                }
                                root.inspectedDevice = null;
                            }
                        }
                    }
                }
            }
        }
    }
}
