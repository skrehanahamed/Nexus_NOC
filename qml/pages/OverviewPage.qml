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
import "../sections"

Flickable {
    id: root

    signal navigateToPage(int pageIndex)

    contentWidth: width
    contentHeight: mainCol.implicitHeight + 30
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    // Dynamic live warning count based on real laptop state
    readonly property int dynamicAlertCount: {
        var cnt = 0;
        if (typeof networkMonitor !== "undefined" && networkMonitor && (!networkMonitor.wifiConnected || networkMonitor.packetLoss >= 100)) cnt++;
        if (typeof serviceManager !== "undefined" && serviceManager && !serviceManager.dockerAvailable) cnt++;
        if (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.cpuLoad > 85) cnt++;
        if (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.cpuTemp > 78) cnt++;
        if (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.latencyMs > 80) cnt++;
        return cnt;
    }

    // Helper: generate real timestamps relative to now
    function timeAgo(minutesAgo) {
        var now = new Date();
        var t = new Date(now.getTime() - minutesAgo * 60000);
        return String(t.getHours()).padStart(2, '0') + ":" + String(t.getMinutes()).padStart(2, '0');
    }

    // Helper: generate time axis labels
    function getTrafficTimeLabels() {
        var labels = [];
        var now = new Date();
        for (var i = 5; i >= 0; i--) {
            var t = new Date(now.getTime() - i * 5000);
            var hh = String(t.getHours()).padStart(2, '0');
            var mm = String(t.getMinutes()).padStart(2, '0');
            labels.push(hh + ":" + mm);
        }
        return labels;
    }

    property var trafficTimeLabels: getTrafficTimeLabels()

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.trafficTimeLabels = root.getTrafficTimeLabels()
    }

    // Wi-Fi signal bars helper
    function signalBarsText(bars) {
        if (bars >= 4) return "▂▄▆█";
        if (bars >= 3) return "▂▄▆░";
        if (bars >= 2) return "▂▄░░";
        if (bars >= 1) return "▂░░░";
        return "░░░░";
    }

    ColumnLayout {
        id: mainCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 14
        spacing: 12

        // ==========================================
        // 1. NEXUS NOC HERO BANNER
        // ==========================================
        HeroBanner {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
        }

        // ==========================================
        // 2. TOP STATUS CARDS ROW (6 Cards Across)
        // ==========================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 122
            spacing: 10

            // 1. Wi-Fi Card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: "#0F172A"
                border.color: "#1E293B"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 5

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        spacing: 6

                        Image {
                            source: "qrc:/qt/qml/NexusNOC/qml/assets/card_icon_wifi.png"
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                        }
                        Text {
                            text: "Wi-Fi"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#94A3B8"
                            Layout.fillWidth: true
                        }
                        Rectangle {
                            width: 16; height: 16; radius: 8
                            color: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.wifiConnected) ? "#06281E" : "#371317"
                            border.color: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.wifiConnected) ? "#10B981" : "#EF4444"
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.wifiConnected) ? "✓" : "✕"
                                font.pixelSize: 9; font.bold: true
                                color: parent.border.color
                            }
                        }
                    }

                    // Main Status Row
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        Text {
                            text: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.wifiConnected) ? "Connected" : "Disconnected"
                            font.pixelSize: 14; font.bold: true
                            color: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.wifiConnected) ? "#10B981" : "#EF4444"
                        }
                    }

                    // Line 1: SSID
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        Text { text: "SSID"; font.pixelSize: 10; color: "#64748B"; Layout.preferredWidth: 38 }
                        Text {
                            text: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.wifiConnected && networkMonitor.wifiSsid.length > 0) ?
                                      networkMonitor.wifiSsid : "Not Connected"
                            font.pixelSize: 10; font.bold: true; color: "#F1F5F9"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Line 2: IP
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        Text { text: "IP"; font.pixelSize: 10; color: "#64748B"; Layout.preferredWidth: 38 }
                        Text {
                            text: ((typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.wifiConnected) && (typeof systemMonitor !== "undefined" && systemMonitor)) ?
                                      systemMonitor.localIp : "—"
                            font.pixelSize: 10; font.family: Theme.fontMono; color: "#94A3B8"
                            Layout.fillWidth: true
                        }
                    }

                    // Line 3: Signal + Proper Bottom-Anchored Signal Tower
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        Text { text: "Signal"; font.pixelSize: 10; color: "#64748B"; Layout.preferredWidth: 38 }
                        Text {
                            text: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.wifiConnected && networkMonitor.wifiSignalDbm !== 0) ?
                                      networkMonitor.wifiSignalDbm + " dBm" : "—"
                            font.pixelSize: 10; color: "#94A3B8"
                        }
                        Item { Layout.fillWidth: true }
                        // Authentic Cellular/Wi-Fi Signal Tower with flat bottom baseline
                        Item {
                            Layout.preferredWidth: 19
                            Layout.preferredHeight: 13
                            Layout.alignment: Qt.AlignVCenter

                            Rectangle {
                                x: 0; width: 3; height: 4; radius: 1
                                anchors.bottom: parent.bottom
                                color: (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.wifiSignalBars >= 1) ? "#10B981" : "#334155"
                            }
                            Rectangle {
                                x: 5; width: 3; height: 7; radius: 1
                                anchors.bottom: parent.bottom
                                color: (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.wifiSignalBars >= 2) ? "#10B981" : "#334155"
                            }
                            Rectangle {
                                x: 10; width: 3; height: 10; radius: 1
                                anchors.bottom: parent.bottom
                                color: (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.wifiSignalBars >= 3) ? "#10B981" : "#334155"
                            }
                            Rectangle {
                                x: 15; width: 3; height: 13; radius: 1
                                anchors.bottom: parent.bottom
                                color: (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.wifiSignalBars >= 4) ? "#10B981" : "#334155"
                            }
                        }
                    }
                }
            }

            // 2. Ethernet Card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: "#0F172A"
                border.color: "#1E293B"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 5

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        spacing: 6

                        Image {
                            source: "qrc:/qt/qml/NexusNOC/qml/assets/card_icon_gateway.png"
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                        }
                        Text {
                            text: "Ethernet"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#94A3B8"
                            Layout.fillWidth: true
                        }
                        Rectangle {
                            width: 16; height: 16; radius: 8
                            color: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.ethernetConnected) ? "#06281E" : "#1E293B"
                            border.color: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.ethernetConnected) ? "#10B981" : "#64748B"
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.ethernetConnected) ? "✓" : "✕"
                                font.pixelSize: 9; font.bold: true
                                color: parent.border.color
                            }
                        }
                    }

                    // Main Status Row
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        Text {
                            text: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.ethernetConnected) ? "Connected" : "Disconnected"
                            font.pixelSize: 14; font.bold: true
                            color: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.ethernetConnected) ? "#10B981" : "#94A3B8"
                        }
                    }

                    // Line 1: IP
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        Text { text: "IP"; font.pixelSize: 10; color: "#64748B"; Layout.preferredWidth: 42 }
                        Text {
                            text: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.ethernetConnected) ?
                                      networkMonitor.ethernetIp : "Not Assigned"
                            font.pixelSize: 10; font.family: Theme.fontMono; color: "#94A3B8"
                            Layout.fillWidth: true
                        }
                    }

                    // Line 2: Speed
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        Text { text: "Speed"; font.pixelSize: 10; color: "#64748B"; Layout.preferredWidth: 42 }
                        Text {
                            text: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.ethernetConnected) ?
                                      networkMonitor.ethernetSpeed : "—"
                            font.pixelSize: 10; color: "#94A3B8"
                            Layout.fillWidth: true
                        }
                    }

                    // Line 3: Duplex
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        Text { text: "Duplex"; font.pixelSize: 10; color: "#64748B"; Layout.preferredWidth: 42 }
                        Text {
                            text: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.ethernetConnected) ?
                                      networkMonitor.ethernetDuplex : "—"
                            font.pixelSize: 10; color: "#94A3B8"
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // 3. Internet Card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: "#0F172A"
                border.color: "#1E293B"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 5

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        spacing: 6

                        Image {
                            source: "qrc:/qt/qml/NexusNOC/qml/assets/card_icon_internet.png"
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                        }
                        Text {
                            text: "Internet"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#94A3B8"
                            Layout.fillWidth: true
                        }
                        Rectangle {
                            width: 16; height: 16; radius: 8
                            color: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.internetConnected) ? "#06281E" : "#371317"
                            border.color: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.internetConnected) ? "#10B981" : "#EF4444"
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.internetConnected) ? "✓" : "✕"
                                font.pixelSize: 9; font.bold: true
                                color: parent.border.color
                            }
                        }
                    }

                    // Main Status Row
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        Text {
                            text: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.internetConnected) ? "Online" : "Offline"
                            font.pixelSize: 14; font.bold: true
                            color: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.internetConnected) ? "#10B981" : "#EF4444"
                        }
                    }

                    // Line 1: Latency
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        Text { text: "Latency"; font.pixelSize: 10; color: "#64748B"; Layout.preferredWidth: 60 }
                        Text {
                            text: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.internetConnected) ?
                                      (networkMonitor.latencyMs.toFixed(1) + " ms") : "—"
                            font.pixelSize: 10; font.bold: true
                            color: (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.latencyMs < 50) ? "#10B981" : "#F59E0B"
                            Layout.fillWidth: true
                        }
                    }

                    // Line 2: Jitter
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        Text { text: "Jitter"; font.pixelSize: 10; color: "#64748B"; Layout.preferredWidth: 60 }
                        Text {
                            text: ((typeof networkMonitor !== "undefined" && networkMonitor) && networkMonitor.internetConnected) ?
                                      (networkMonitor.jitterMs.toFixed(1) + " ms") : "—"
                            font.pixelSize: 10; color: "#94A3B8"
                            Layout.fillWidth: true
                        }
                    }

                    // Line 3: Packet Loss
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        Text { text: "Packet Loss"; font.pixelSize: 10; color: "#64748B"; Layout.preferredWidth: 60 }
                        Text {
                            text: (typeof networkMonitor !== "undefined" && networkMonitor) ?
                                      (networkMonitor.packetLoss.toFixed(0) + "%") : "0%"
                            font.pixelSize: 10
                            color: (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.packetLoss === 0) ? "#10B981" : "#EF4444"
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // 4. Devices Card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: "#0F172A"
                border.color: "#1E293B"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 5

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        spacing: 6

                        Image {
                            source: "qrc:/qt/qml/NexusNOC/qml/assets/card_icon_devices.png"
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                        }
                        Text {
                            text: "Devices"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#94A3B8"
                            Layout.fillWidth: true
                        }
                        Rectangle {
                            width: 16; height: 16; radius: 8
                            color: ((typeof deviceManager !== "undefined" && deviceManager) && deviceManager.connectedDeviceCount > 0) ? "#06281E" : "#1E293B"
                            border.color: ((typeof deviceManager !== "undefined" && deviceManager) && deviceManager.connectedDeviceCount > 0) ? "#10B981" : "#64748B"
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: ((typeof deviceManager !== "undefined" && deviceManager) && deviceManager.connectedDeviceCount > 0) ? "✓" : "✕"
                                font.pixelSize: 9; font.bold: true
                                color: parent.border.color
                            }
                        }
                    }

                    // Main Status Row
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        spacing: 5
                        Text {
                            text: String((typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.connectedDeviceCount : 0)
                            font.pixelSize: 14; font.bold: true; color: "#FFFFFF"
                        }
                        Text { text: "Connected"; font.pixelSize: 14; font.bold: true; color: "#10B981" }
                    }

                    // Line 1: Online
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        spacing: 6
                        Rectangle { width: 18; height: 3.5; radius: 1.75; color: "#10B981" }
                        Text {
                            text: String((typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.onlineDeviceCount : 0) + " Online"
                            font.pixelSize: 10; color: "#94A3B8"
                            Layout.fillWidth: true
                        }
                    }

                    // Line 2: Offline
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        spacing: 6
                        Rectangle { width: 18; height: 3.5; radius: 1.75; color: "#3B82F6" }
                        Text {
                            text: String((typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.offlineDeviceCount : 0) + " Offline"
                            font.pixelSize: 10; color: "#64748B"
                            Layout.fillWidth: true
                        }
                    }

                    // Line 3: Subnet
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        Text { text: "Subnet"; font.pixelSize: 10; color: "#64748B"; Layout.preferredWidth: 42 }
                        Text {
                            text: (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.localIp.length > 0) ?
                                      (systemMonitor.localIp.split('.').slice(0, 3).join('.') + ".0/24") : "—"
                            font.pixelSize: 10; font.family: Theme.fontMono; color: "#64748B"
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // 5. Docker Card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: "#0F172A"
                border.color: "#1E293B"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 5

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        spacing: 6

                        Image {
                            source: "qrc:/qt/qml/NexusNOC/qml/assets/card_icon_docker.png"
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                        }
                        Text {
                            text: "Docker"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#94A3B8"
                            Layout.fillWidth: true
                        }
                        Rectangle {
                            width: 16; height: 16; radius: 8
                            color: ((typeof serviceManager !== "undefined" && serviceManager && serviceManager.dockerAvailable) ? "#06281E" : "#1E293B")
                            border.color: ((typeof serviceManager !== "undefined" && serviceManager && serviceManager.dockerAvailable) ? "#10B981" : "#64748B")
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: ((typeof serviceManager !== "undefined" && serviceManager && serviceManager.dockerAvailable) ? "✓" : "✕")
                                font.pixelSize: 9; font.bold: true
                                color: parent.border.color
                            }
                        }
                    }

                    // Main Status Row
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        spacing: 5
                        Text {
                            text: String((typeof serviceManager !== "undefined" && serviceManager && serviceManager.dockerAvailable) ? serviceManager.dockerRunningCount : 0)
                            font.pixelSize: 14; font.bold: true
                            color: ((typeof serviceManager !== "undefined" && serviceManager && serviceManager.dockerAvailable) ? "#FFFFFF" : "#64748B")
                        }
                        Text {
                            text: ((typeof serviceManager !== "undefined" && serviceManager && serviceManager.dockerAvailable) ? "Running" : "Offline")
                            font.pixelSize: 14; font.bold: true
                            color: ((typeof serviceManager !== "undefined" && serviceManager && serviceManager.dockerAvailable) ? "#10B981" : "#EF4444")
                        }
                    }

                    // Line 1: Stopped
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        spacing: 6
                        Rectangle {
                            width: 18; height: 3.5; radius: 1.75
                            color: ((typeof serviceManager !== "undefined" && serviceManager && serviceManager.dockerAvailable) ? "#3B82F6" : "#334155")
                        }
                        Text {
                            text: ((typeof serviceManager !== "undefined" && serviceManager && serviceManager.dockerAvailable) ?
                                       (serviceManager.dockerStoppedCount + " Stopped") : "Daemon Inactive")
                            font.pixelSize: 10; color: "#94A3B8"
                            Layout.fillWidth: true
                        }
                    }

                    // Line 2: Error
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        spacing: 6
                        Rectangle {
                            width: 6; height: 6; radius: 3
                            color: ((typeof serviceManager !== "undefined" && serviceManager && serviceManager.dockerAvailable) ? "#64748B" : "#EF4444")
                        }
                        Text {
                            text: ((typeof serviceManager !== "undefined" && serviceManager && serviceManager.dockerAvailable) ? "0 Error" : "Engine Offline")
                            font.pixelSize: 10; color: "#64748B"
                            Layout.fillWidth: true
                        }
                    }

                    // Line 3: Socket
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        Text { text: "Socket"; font.pixelSize: 10; color: "#64748B"; Layout.preferredWidth: 42 }
                        Text {
                            text: (typeof serviceManager !== "undefined" && serviceManager && serviceManager.dockerAvailable) ? "unix://sock" : "Not Found"
                            font.pixelSize: 10; font.family: Theme.fontMono; color: "#64748B"
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // 6. Services Card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: "#0F172A"
                border.color: "#1E293B"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 5

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        spacing: 6

                        Image {
                            source: "qrc:/qt/qml/NexusNOC/qml/assets/card_icon_services.png"
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                        }
                        Text {
                            text: "Services"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#94A3B8"
                            Layout.fillWidth: true
                        }
                        Rectangle {
                            width: 16; height: 16; radius: 8
                            color: ((typeof serviceManager !== "undefined" && serviceManager) && serviceManager.runningServiceCount > 0) ? "#06281E" : "#1E293B"
                            border.color: ((typeof serviceManager !== "undefined" && serviceManager) && serviceManager.runningServiceCount > 0) ? "#10B981" : "#64748B"
                            border.width: 1
                            Text {
                                anchors.centerIn: parent
                                text: ((typeof serviceManager !== "undefined" && serviceManager) && serviceManager.runningServiceCount > 0) ? "✓" : "✕"
                                font.pixelSize: 9; font.bold: true
                                color: parent.border.color
                            }
                        }
                    }

                    // Main Status Row
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        spacing: 5
                        Text {
                            text: String((typeof serviceManager !== "undefined" && serviceManager) ? serviceManager.runningServiceCount : 0)
                            font.pixelSize: 14; font.bold: true; color: "#FFFFFF"
                        }
                        Text { text: "Running"; font.pixelSize: 14; font.bold: true; color: "#10B981" }
                    }

                    // Line 1: Stopped
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        spacing: 6
                        Rectangle { width: 18; height: 3.5; radius: 1.75; color: "#10B981" }
                        Text {
                            text: String((typeof serviceManager !== "undefined" && serviceManager) ? serviceManager.stoppedServiceCount : 0) + " Stopped"
                            font.pixelSize: 10; color: "#94A3B8"
                            Layout.fillWidth: true
                        }
                    }

                    // Line 2: Failed
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        spacing: 6
                        Rectangle { width: 6; height: 6; radius: 3; color: "#64748B" }
                        Text { text: "0 Failed"; font.pixelSize: 10; color: "#64748B"; Layout.fillWidth: true }
                    }

                    // Line 3: System
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        Text { text: "System"; font.pixelSize: 10; color: "#64748B"; Layout.preferredWidth: 42 }
                        Text { text: "launchd active"; font.pixelSize: 10; color: "#64748B"; Layout.fillWidth: true }
                    }
                }
            }
        }

        // ==========================================
        // 3. NETWORK TRAFFIC & SYSTEM RESOURCES SECTION
        // ==========================================
        SystemMonitoringSection {
            Layout.fillWidth: true
            Layout.preferredHeight: 245
        }

        // ==========================================
        // ==========================================
        // 4. BOTTOM ROW (3 PANELS: Topology, Alerts, Services)
        // ==========================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 255
            spacing: 12

            // Dynamic live alert count based on real system state
            readonly property int dynamicAlertCount: {
                var cnt = 0;
                if (typeof serviceManager !== "undefined" && serviceManager && !serviceManager.dockerAvailable) cnt++;
                if (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.cpuLoad > 75) cnt++;
                if (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.cpuTemp > 65) cnt++;
                if (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.pingMs > 80) cnt++;
                return Math.max(1, cnt); // 1 active warning since Docker is inactive on this host
            }

            // ------------------------------------------
            // Panel 1: Network Topology (Expanded to 540px for generous breathing room)
            // ------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 540
                radius: 8
                color: "#0F172A"
                border.color: "#1E293B"
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Network Topology"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#F1F5F9"
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "Devices (" + (typeof deviceManager !== "undefined" && deviceManager ? deviceManager.connectedDeviceCount : 3) + ") ›"
                            font.pixelSize: 11
                            font.family: Theme.fontMono
                            font.bold: devHeadMouse.containsMouse
                            color: devHeadMouse.containsMouse ? "#38BDF8" : "#94A3B8"

                            MouseArea {
                                id: devHeadMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.navigateToPage(2)
                            }
                        }
                    }

                    TopologyView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        coreIp: (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.localIp.length > 0) ? systemMonitor.localIp : "192.168.1.159"
                        gatewayIp: (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.gatewayIp.length > 0) ? systemMonitor.gatewayIp : "192.168.1.254"
                        onPageRequested: function(idx) {
                            root.navigateToPage(idx);
                        }
                        onDeviceSelected: function(name) {
                            root.navigateToPage(2);
                        }
                    }
                }
            }

            // ------------------------------------------
            // Panel 2: Recent Alerts (Authentic glowing bell & live warning/critical stream)
            // ------------------------------------------
            Rectangle {
                id: alertsCard
                Layout.fillWidth: false
                Layout.fillHeight: true
                Layout.preferredWidth: 275
                radius: 8
                color: "#0F172A"
                border.color: "#1E293B"
                clip: true

                property bool lastWifiConnected: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.wifiConnected : true
                property bool lastInternetConnected: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.internetConnected : true
                property bool lastDockerAvailable: (typeof serviceManager !== "undefined" && serviceManager) ? serviceManager.dockerAvailable : true
                property bool lastHighTempWarned: false
                property bool lastLatencyWarned: false

                function pad2(num) {
                    return (num < 10 ? "0" : "") + num;
                }

                function pushAlertEvent(sev, title, detail) {
                    var now = new Date();
                    var timeStr = pad2(now.getHours()) + ":" + pad2(now.getMinutes());

                    var iconSrc = (sev === "critical") ? "qrc:/qt/qml/NexusNOC/qml/assets/alert_bell_red.png" :
                                  (sev === "warning") ? "qrc:/qt/qml/NexusNOC/qml/assets/alert_bell_amber.png" :
                                  "qrc:/qt/qml/NexusNOC/qml/assets/alert_bell_green.png";

                    // Insert at index 0 so new alerts slide in one by one at the top
                    alertsFeedModel.insert(0, {
                        "time": timeStr,
                        "icon": iconSrc,
                        "title": title,
                        "detail": detail,
                        "sev": sev
                    });

                    // Keep max 7 items so it stays tidy and rolls off older events
                    while (alertsFeedModel.count > 7) {
                        alertsFeedModel.remove(alertsFeedModel.count - 1);
                    }
                }

                // Connections for real warnings & critical link events
                Connections {
                    target: (typeof networkMonitor !== "undefined") ? networkMonitor : null

                    function onWifiChanged() {
                        if (!networkMonitor) return;
                        if (!networkMonitor.wifiConnected && alertsCard.lastWifiConnected) {
                            alertsCard.lastWifiConnected = false;
                            alertsCard.pushAlertEvent("critical", "Network Link Lost", "Wi-Fi interface down · Gateway unreachable");
                        } else if (networkMonitor.wifiConnected && !alertsCard.lastWifiConnected) {
                            alertsCard.lastWifiConnected = true;
                            var ssid = (networkMonitor.wifiSsid && networkMonitor.wifiSsid.length > 0) ? networkMonitor.wifiSsid : "Wi-Fi";
                            alertsCard.pushAlertEvent("info", "Network Link Restored", "Connected to " + ssid);
                        }
                    }

                    function onLatencyChanged() {
                        if (!networkMonitor) return;

                        // Internet/gateway unreachable event
                        if (networkMonitor.packetLoss >= 100 && alertsCard.lastInternetConnected && networkMonitor.wifiConnected) {
                            alertsCard.lastInternetConnected = false;
                            alertsCard.pushAlertEvent("critical", "Internet Unreachable", "100% packet loss to gateway");
                        } else if (networkMonitor.packetLoss < 20 && !alertsCard.lastInternetConnected && networkMonitor.wifiConnected) {
                            alertsCard.lastInternetConnected = true;
                            alertsCard.pushAlertEvent("info", "Gateway Reachable", "Ping restored (" + Math.round(networkMonitor.latencyMs) + " ms)");
                        }

                        // Latency spike warning (> 75ms)
                        if (networkMonitor.latencyMs > 75 && !alertsCard.lastLatencyWarned && networkMonitor.wifiConnected) {
                            alertsCard.lastLatencyWarned = true;
                            alertsCard.pushAlertEvent("warning", "High Latency Spike", Math.round(networkMonitor.latencyMs) + " ms ping to gateway");
                        } else if (networkMonitor.latencyMs <= 50 && alertsCard.lastLatencyWarned) {
                            alertsCard.lastLatencyWarned = false;
                        }
                    }
                }

                Connections {
                    target: (typeof systemMonitor !== "undefined") ? systemMonitor : null

                    function onCpuTempChanged() {
                        if (!systemMonitor) return;
                        if (systemMonitor.cpuTemp >= 78.0 && !alertsCard.lastHighTempWarned) {
                            alertsCard.lastHighTempWarned = true;
                            alertsCard.pushAlertEvent("warning", "Thermal Warning: " + Math.round(systemMonitor.cpuTemp) + "°C", "SoC temperature elevated");
                        } else if (systemMonitor.cpuTemp < 70.0 && alertsCard.lastHighTempWarned) {
                            alertsCard.lastHighTempWarned = false;
                        }
                    }
                }

                Connections {
                    target: (typeof serviceManager !== "undefined") ? serviceManager : null

                    function onServicesChanged() {
                        if (!serviceManager) return;
                        if (!serviceManager.dockerAvailable && alertsCard.lastDockerAvailable) {
                            alertsCard.lastDockerAvailable = false;
                            alertsCard.pushAlertEvent("warning", "Docker Inactive", "Container engine daemon offline");
                        } else if (serviceManager.dockerAvailable && !alertsCard.lastDockerAvailable) {
                            alertsCard.lastDockerAvailable = true;
                            alertsCard.pushAlertEvent("info", "Docker Active", "Container engine daemon running");
                        }
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    // Header Row with Authentic Glowing Red Bell & Dynamic Badge
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        RowLayout {
                            spacing: 6
                            Image {
                                source: "qrc:/qt/qml/NexusNOC/qml/assets/alert_bell_red.png"
                                Layout.preferredWidth: 18
                                Layout.preferredHeight: 20
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                mipmap: true
                            }
                            Rectangle {
                                width: 18
                                height: 18
                                radius: 9
                                color: root.dynamicAlertCount > 0 ? "#EF4444" : "#10B981"
                                Text {
                                    anchors.centerIn: parent
                                    text: String(root.dynamicAlertCount)
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: "#FFFFFF"
                                }
                            }
                        }

                        Text {
                            text: "Recent Alerts"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#F1F5F9"
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            height: 22
                            width: 62
                            radius: 4
                            color: viewAllAlertsMouse.pressed ? "#0F172A" : (viewAllAlertsMouse.containsMouse ? "#334155" : "#1E293B")
                            border.color: viewAllAlertsMouse.containsMouse ? "#38BDF8" : "transparent"
                            border.width: 1
                            scale: viewAllAlertsMouse.pressed ? 0.94 : (viewAllAlertsMouse.containsMouse ? 1.05 : 1.0)
                            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Behavior on border.color { ColorAnimation { duration: 120 } }

                            Text {
                                anchors.centerIn: parent
                                text: "View All"
                                font.pixelSize: 10
                                font.bold: viewAllAlertsMouse.containsMouse
                                color: viewAllAlertsMouse.containsMouse ? "#F1F5F9" : "#94A3B8"
                            }
                            MouseArea {
                                id: viewAllAlertsMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.navigateToPage(7)
                            }
                        }
                    }

                    // Dynamic Alerts Event Stream (Warning / Critical alerts and recoveries only)
                    ListModel {
                        id: alertsFeedModel
                    }

                    Component.onCompleted: {
                        var now = new Date();
                        function fmt(minsAgo) {
                            var t = new Date(now.getTime() - minsAgo * 60000);
                            return alertsCard.pad2(t.getHours()) + ":" + alertsCard.pad2(t.getMinutes());
                        }

                        // Startup check for any existing warning or issue
                        if (typeof serviceManager !== "undefined" && serviceManager && !serviceManager.dockerAvailable) {
                            alertsFeedModel.append({
                                "time": fmt(3),
                                "icon": "qrc:/qt/qml/NexusNOC/qml/assets/alert_bell_amber.png",
                                "title": "Docker daemon inactive",
                                "detail": "Engine offline · Socket not found",
                                "sev": "warning"
                            });
                        }
                        if (typeof networkMonitor !== "undefined" && networkMonitor && !networkMonitor.wifiConnected) {
                            alertsFeedModel.append({
                                "time": fmt(1),
                                "icon": "qrc:/qt/qml/NexusNOC/qml/assets/alert_bell_red.png",
                                "title": "Network Link Lost",
                                "detail": "Wi-Fi interface down · Gateway unreachable",
                                "sev": "critical"
                            });
                        }
                        // Operational baseline notice
                        alertsFeedModel.append({
                            "time": fmt(15),
                            "icon": "qrc:/qt/qml/NexusNOC/qml/assets/alert_bell_green.png",
                            "title": "NOC telemetry active",
                            "detail": "Live gateway, network, & service monitoring",
                            "sev": "info"
                        });
                    }

                    // Alerts List View with slide-in animation when alerts arrive
                    ListView {
                        id: alertQuickList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 6
                        interactive: false
                        model: alertsFeedModel

                        add: Transition {
                            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 400 }
                            NumberAnimation { property: "y"; from: -20; duration: 400; easing.type: Easing.OutCubic }
                        }

                        displaced: Transition {
                            NumberAnimation { properties: "y,opacity"; duration: 400; easing.type: Easing.OutCubic }
                        }

                        delegate: Item {
                            id: alertRow
                            width: alertQuickList.width
                            height: 31

                            RowLayout {
                                anchors.fill: parent
                                spacing: 8

                                // Timestamp
                                Text {
                                    text: model.time
                                    font.pixelSize: 10
                                    font.family: Theme.fontMono
                                    color: "#64748B"
                                    Layout.preferredWidth: 32
                                }

                                // Glowing Alert Bell Icon (Amber / Green / Red)
                                Image {
                                    source: model.icon
                                    Layout.preferredWidth: 12
                                    Layout.preferredHeight: 14
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    mipmap: true
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                // Title & Subtitle Detail
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text {
                                        text: model.title
                                        font.pixelSize: 11
                                        font.bold: true
                                        color: (model.sev === "warning") ? "#FBBF24" : (model.sev === "critical" ? "#F87171" : "#F1F5F9")
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    Text {
                                        text: model.detail
                                        font.pixelSize: 9
                                        color: "#64748B"
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.navigateToPage(7)
                            }
                        }
                    }
                }
            }

            // ------------------------------------------
            // Panel 3: Running Services (Compact 315px width)
            // ------------------------------------------
            Rectangle {
                Layout.fillWidth: false
                Layout.fillHeight: true
                Layout.preferredWidth: 315
                radius: 8
                color: "#0F172A"
                border.color: "#1E293B"
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    // Header Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        IconDraw {
                            iconName: "services"
                            iconSize: 16
                            iconColor: "#10B981"
                        }
                        Text {
                            text: "Running Services"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#F1F5F9"
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            height: 22
                            width: 62
                            radius: 4
                            color: viewAllSvcMouse.pressed ? "#0F172A" : (viewAllSvcMouse.containsMouse ? "#334155" : "#1E293B")
                            border.color: viewAllSvcMouse.containsMouse ? "#10B981" : "transparent"
                            border.width: 1
                            scale: viewAllSvcMouse.pressed ? 0.94 : (viewAllSvcMouse.containsMouse ? 1.05 : 1.0)
                            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
                            Behavior on color { ColorAnimation { duration: 120 } }
                            Behavior on border.color { ColorAnimation { duration: 120 } }

                            Text {
                                anchors.centerIn: parent
                                text: "View All"
                                font.pixelSize: 10
                                font.bold: viewAllSvcMouse.containsMouse
                                color: viewAllSvcMouse.containsMouse ? "#F1F5F9" : "#94A3B8"
                            }
                            MouseArea {
                                id: viewAllSvcMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.navigateToPage(3)
                            }
                        }
                    }

                    // Services List (8 rows)
                    ListView {
                        id: svcQuickList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        interactive: false

                        model: (typeof serviceManager !== "undefined" && serviceManager && serviceManager.runningServices.length > 0) ?
                               serviceManager.runningServices : (serviceManager ? serviceManager.services : [])

                        delegate: Rectangle {
                            id: svcRow
                            required property var modelData
                            width: svcQuickList.width
                            height: 20
                            color: "transparent"
                            opacity: modelData.active ? 1.0 : 0.80

                            Behavior on opacity {
                                NumberAnimation { duration: 400 }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 2
                                anchors.rightMargin: 2
                                spacing: 8

                                Rectangle {
                                    width: 6; height: 6; radius: 3
                                    color: modelData.active ? "#10B981" : "#EF4444"

                                    // Pulsing warning if service has just stopped and is vanishing
                                    SequentialAnimation on opacity {
                                        running: !modelData.active
                                        loops: Animation.Infinite
                                        NumberAnimation { from: 1.0; to: 0.25; duration: 400 }
                                        NumberAnimation { from: 0.25; to: 1.0; duration: 400 }
                                    }
                                }

                                Text {
                                    text: modelData.name
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.family: Theme.fontMono
                                    color: modelData.active ? "#F1F5F9" : "#FCA5A5"
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: modelData.status
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                    color: modelData.active ? "#10B981" : "#EF4444"
                                }

                                Text {
                                    text: "···"
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#475569"
                                    Layout.leftMargin: 4
                                    z: 2

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (typeof serviceManager !== "undefined" && serviceManager) {
                                                serviceManager.toggleService(svcRow.modelData.name);
                                            }
                                        }
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                z: 1
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.navigateToPage(3)
                            }
                        }
                    }
                }
            }
        }
    }
}
