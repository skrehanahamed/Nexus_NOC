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

Rectangle {
    id: root

    signal viewAllClicked()

    property int totalDevices: (typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.totalDeviceCount : 12
    property int wifiClients: (typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.wifiClientCount : 5
    property int ethernetClients: (typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.ethernetClientCount : 2
    property int iotDevices: (typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.iotDeviceCount : 3

    color: "#0C1322"
    border.color: "#1E293B"
    border.width: 1
    radius: 10
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // Header Row
        RowLayout {
            Layout.fillWidth: true

            RowLayout {
                spacing: 8
                IconDraw {
                    iconName: "network"
                    iconColor: Theme.accentCyan
                    iconSize: 16
                }
                Text {
                    text: "Network Statistics"
                    font.pixelSize: 14
                    font.bold: true
                    font.family: Theme.fontSans
                    color: Theme.textPrimary
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "View All"
                font.pixelSize: 11
                font.bold: true
                font.family: Theme.fontSans
                color: Theme.accentCyan

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.viewAllClicked()
                }
            }
        }

        // 2x2 Grid of Sub-Cards
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            rows: 2
            columnSpacing: 10
            rowSpacing: 10

            // 1. Total Devices
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: "#111B2E"
                border.color: "#1B2A42"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Rectangle {
                        width: 38
                        height: 38
                        radius: 19
                        color: Qt.rgba(0, 229, 255, 0.12)
                        border.color: Qt.rgba(0, 229, 255, 0.25)
                        IconDraw {
                            anchors.centerIn: parent
                            iconName: "overview"
                            iconColor: Theme.accentCyan
                            iconSize: 18
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: root.totalDevices.toString()
                            font.pixelSize: 18
                            font.bold: true
                            font.family: Theme.fontMono
                            color: Theme.textPrimary
                        }

                        Text {
                            text: "Total Devices"
                            font.pixelSize: 11
                            font.family: Theme.fontSans
                            color: Theme.textSecondary
                        }
                    }
                }
            }

            // 2. Wi-Fi Clients
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: "#111B2E"
                border.color: "#1B2A42"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Rectangle {
                        width: 38
                        height: 38
                        radius: 19
                        color: Qt.rgba(56, 189, 248, 0.12)
                        border.color: Qt.rgba(56, 189, 248, 0.25)
                        IconDraw {
                            anchors.centerIn: parent
                            iconName: "wifi"
                            iconColor: "#38BDF8"
                            iconSize: 18
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: root.wifiClients.toString()
                            font.pixelSize: 18
                            font.bold: true
                            font.family: Theme.fontMono
                            color: Theme.textPrimary
                        }

                        Text {
                            text: "Wi-Fi Clients"
                            font.pixelSize: 11
                            font.family: Theme.fontSans
                            color: Theme.textSecondary
                        }
                    }
                }
            }

            // 3. Ethernet Clients
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: "#111B2E"
                border.color: "#1B2A42"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Rectangle {
                        width: 38
                        height: 38
                        radius: 19
                        color: Qt.rgba(0, 230, 118, 0.12)
                        border.color: Qt.rgba(0, 230, 118, 0.25)
                        IconDraw {
                            anchors.centerIn: parent
                            iconName: "ethernet"
                            iconColor: "#00E676"
                            iconSize: 18
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: root.ethernetClients.toString()
                            font.pixelSize: 18
                            font.bold: true
                            font.family: Theme.fontMono
                            color: Theme.textPrimary
                        }

                        Text {
                            text: "Ethernet Clients"
                            font.pixelSize: 11
                            font.family: Theme.fontSans
                            color: Theme.textSecondary
                        }
                    }
                }
            }

            // 4. IoT Devices
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: "#111B2E"
                border.color: "#1B2A42"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Rectangle {
                        width: 38
                        height: 38
                        radius: 19
                        color: Qt.rgba(168, 85, 247, 0.12)
                        border.color: Qt.rgba(168, 85, 247, 0.25)
                        IconDraw {
                            anchors.centerIn: parent
                            iconName: "network"
                            iconColor: "#A855F7"
                            iconSize: 18
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: root.iotDevices.toString()
                            font.pixelSize: 18
                            font.bold: true
                            font.family: Theme.fontMono
                            color: Theme.textPrimary
                        }

                        Text {
                            text: "IoT Devices"
                            font.pixelSize: 11
                            font.family: Theme.fontSans
                            color: Theme.textSecondary
                        }
                    }
                }
            }
        }
    }
}
