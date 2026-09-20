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
import NexusNOC
import "../components"

Rectangle {
    id: root

    property int currentIndex: 0
    signal pageSelected(int index, string pageName)

    // Dynamic backend metrics
    readonly property int activeAlertCount: 1

    // Dynamic Hardware Information & Logo
    readonly property string detectedType: (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.deviceType) ? systemMonitor.deviceType : ""
    readonly property string detectedName: (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.deviceName) ? systemMonitor.deviceName : ""
    readonly property string deviceModel: detectedName.length > 0 ? detectedName : "Apple MacBook Air"
    readonly property string deviceHostName: (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.hostName) ? systemMonitor.hostName : ""
    readonly property string deviceRamFormatted: ((typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.ramTotalGb > 0) ? Math.round(systemMonitor.ramTotalGb) : 16) + " GB RAM"
    readonly property string deviceSsdFormatted: {
        var tot = (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.storageTotalGb > 0) ? systemMonitor.storageTotalGb : 512;
        if (tot >= 1800) return "2 TB SSD";
        if (tot >= 900) return "1 TB SSD";
        if (tot >= 400) return "512 GB SSD";
        if (tot >= 200) return "256 GB SSD";
        if (tot >= 100) return "128 GB SSD";
        return Math.round(tot) + " GB SSD";
    }
    readonly property string deviceImageSource: {
        var t = root.detectedType.toLowerCase();
        var n = root.detectedName.toLowerCase();
        if (t === "apple" || n.indexOf("mac") !== -1 || n.indexOf("apple") !== -1) {
            return "qrc:/qt/qml/NexusNOC/qml/assets/device_macbook_air.png";
        } else if (t === "pi" || n.indexOf("raspberry") !== -1 || n.indexOf("pi") !== -1) {
            return "qrc:/qt/qml/NexusNOC/qml/assets/topo_rpi_board.png";
        } else {
            return "qrc:/qt/qml/NexusNOC/qml/assets/linux_logo.png";
        }
    }

    readonly property var navItems: [
        { id: "overview", name: "Overview", icon: "qrc:/qt/qml/NexusNOC/qml/assets/nav_overview.png", hasAlert: false },
        { id: "network",  name: "Network",  icon: "qrc:/qt/qml/NexusNOC/qml/assets/nav_network.png",  hasAlert: false },
        { id: "devices",  name: "Devices",  icon: "qrc:/qt/qml/NexusNOC/qml/assets/nav_devices.png",  hasAlert: false },
        { id: "services", name: "Services", icon: "qrc:/qt/qml/NexusNOC/qml/assets/nav_services.png", hasAlert: false },
        { id: "docker",   name: "Docker",   icon: "qrc:/qt/qml/NexusNOC/qml/assets/nav_docker.png",   hasAlert: false },
        { id: "system",   name: "System",   icon: "qrc:/qt/qml/NexusNOC/qml/assets/nav_system.png",   hasAlert: false },
        { id: "logs",     name: "Logs",     icon: "qrc:/qt/qml/NexusNOC/qml/assets/nav_logs.png",     hasAlert: false },
        { id: "alerts",   name: "Alerts",   icon: "qrc:/qt/qml/NexusNOC/qml/assets/alert_bell_red.png",   hasAlert: true, alertCount: root.activeAlertCount },
        { id: "settings", name: "Settings", icon: "qrc:/qt/qml/NexusNOC/qml/assets/nav_settings.png", hasAlert: false }
    ]

    Layout.preferredWidth: 250
    color: "#080E1A"
    border.color: Qt.rgba(255, 255, 255, 0.08)
    border.width: 1

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Clean breathing space at top
        Item {
            Layout.preferredHeight: 14
        }

        // Navigation Container with Sliding Selection Pill
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Sliding Selection Highlight Capsule (Clean rounded glass pill without any lines)
            Rectangle {
                id: selectionPill
                x: 10
                width: parent.width - 20
                height: 44
                radius: 8
                z: 0

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#143660" }
                    GradientStop { position: 0.7; color: "#0D2240" }
                    GradientStop { position: 1.0; color: "#09172B" }
                }

                border.width: 1
                border.color: "#2563EB"

                y: root.currentIndex * 48
                visible: root.currentIndex >= 0 && root.currentIndex < root.navItems.length

                Behavior on y {
                    SpringAnimation {
                        spring: 3.4
                        damping: 0.30
                        epsilon: 0.25
                    }
                }
            }

            // Navigation Items List
            ListView {
                id: navList
                anchors.fill: parent
                z: 1
                clip: true
                model: root.navItems
                interactive: false
                spacing: 4

                delegate: Item {
                    id: itemDelegate
                    required property var modelData
                    required property int index

                    readonly property bool isSelected: root.currentIndex === index
                    readonly property bool isHovered: itemMouse.containsMouse

                    width: ListView.view.width - 20
                    height: 44
                    x: 10

                    // Subtle hover backdrop (only when unselected)
                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: itemDelegate.isHovered && !itemDelegate.isSelected
                               ? Qt.rgba(255, 255, 255, 0.05)
                               : "transparent"
                        border.width: itemDelegate.isHovered && !itemDelegate.isSelected ? 1 : 0
                        border.color: Qt.rgba(255, 255, 255, 0.08)

                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 22
                        anchors.rightMargin: 16
                        spacing: 16

                        // Navigation Icon with smooth scale & opacity transitions
                        Image {
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 20
                            Layout.alignment: Qt.AlignVCenter
                            source: modelData.icon
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                            scale: itemDelegate.isSelected ? 1.12 : (itemDelegate.isHovered ? 1.06 : 1.0)
                            opacity: itemDelegate.isSelected ? 1.0 : (itemDelegate.isHovered ? 0.90 : 0.65)

                            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }

                        // Navigation Label with subtle micro-shift
                        Text {
                            text: modelData.name
                            font.pixelSize: 13
                            font.bold: itemDelegate.isSelected
                            font.family: Theme.fontFamily
                            color: itemDelegate.isSelected
                                   ? "#FFFFFF"
                                   : (itemDelegate.isHovered ? "#F1F5F9" : "#94A3B8")
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter

                            transform: Translate {
                                x: itemDelegate.isSelected ? 2 : (itemDelegate.isHovered ? 1 : 0)
                                Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                            }

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        // Red Alert Notification Badge (Only Alerts show numbers)
                        Rectangle {
                            visible: modelData.hasAlert && modelData.alertCount > 0
                            Layout.preferredHeight: 20
                            Layout.preferredWidth: Math.max(20, alertText.implicitWidth + 10)
                            Layout.alignment: Qt.AlignVCenter
                            radius: 10
                            color: "#EF4444"
                            scale: itemDelegate.isSelected ? 1.05 : 1.0

                            Behavior on scale { NumberAnimation { duration: 180 } }

                            Text {
                                id: alertText
                                anchors.centerIn: parent
                                text: modelData.alertCount !== undefined ? modelData.alertCount : ""
                                font.pixelSize: 10
                                font.bold: true
                                font.family: Theme.fontMono
                                color: "#FFFFFF"
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.currentIndex = index;
                            root.pageSelected(index, modelData.name);
                        }
                    }
                }
            }
        }

        // Bottom Hardware Section (Completely borderless, prominent and larger)
        Item {
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            Layout.bottomMargin: 14
            Layout.preferredHeight: 185

            ColumnLayout {
                anchors.fill: parent
                spacing: 6

                // Container for Device Image (Clean, transparent background)
                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 145
                    Layout.preferredHeight: 100

                    Image {
                        anchors.fill: parent
                        source: root.deviceImageSource
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }
                }

                Text {
                    text: root.deviceModel
                    font.pixelSize: 13
                    font.bold: true
                    font.family: Theme.fontFamily
                    color: "#FFFFFF"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 6

                    Text {
                        text: root.deviceRamFormatted
                        font.pixelSize: 11
                        font.bold: true
                        font.family: Theme.fontMono
                        color: "#38BDF8"
                    }

                    Text {
                        text: "·"
                        font.pixelSize: 11
                        font.bold: true
                        color: "#64748B"
                    }

                    Text {
                        text: root.deviceSsdFormatted
                        font.pixelSize: 11
                        font.bold: true
                        font.family: Theme.fontMono
                        color: "#38BDF8"
                    }
                }

                Text {
                    text: "NEXUS NOC Appliance"
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    font.letterSpacing: 0.5
                    font.family: Theme.fontFamily
                    color: "#94A3B8"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
