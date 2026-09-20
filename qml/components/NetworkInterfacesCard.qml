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

    property var interfacesList: (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.networkInterfaces) ? networkMonitor.networkInterfaces : [
        { name: "Wi-Fi", icon: "wifi", isUp: true, ip: "192.168.1.45", rxSpeed: "52.3 Mbps", txSpeed: "18.4 Mbps" },
        { name: "Ethernet", icon: "ethernet", isUp: true, ip: "192.168.1.46", rxSpeed: "28.1 Mbps", txSpeed: "12.7 Mbps" },
        { name: "Docker0", icon: "docker", isUp: true, ip: "172.17.0.1", rxSpeed: "1.2 Mbps", txSpeed: "0.6 Mbps" },
        { name: "Br0 (VM)", icon: "network", isUp: false, ip: "—", rxSpeed: "0 Mbps", txSpeed: "—" }
    ]

    color: "#0C1322"
    border.color: "#1E293B"
    border.width: 1
    radius: 10
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // Title
        Text {
            text: "Network Interfaces"
            font.pixelSize: 14
            font.bold: true
            font.family: Theme.fontSans
            color: Theme.textPrimary
        }

        // Table Rows
        ListView {
            id: ifaceView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            interactive: false
            model: root.interfacesList

            delegate: Rectangle {
                required property var modelData
                width: ifaceView.width
                height: 32
                radius: 6
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    spacing: 8

                    // Interface Icon & Name
                    RowLayout {
                        Layout.preferredWidth: 95
                        spacing: 8

                        IconDraw {
                            iconName: modelData.icon ? modelData.icon : "network"
                            iconColor: modelData.isUp ? Theme.accentCyan : Theme.textMuted
                            iconSize: 16
                        }

                        Text {
                            text: modelData.name
                            font.pixelSize: 12
                            font.bold: true
                            font.family: Theme.fontSans
                            color: Theme.textPrimary
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Status Indicator Dot & Text
                    RowLayout {
                        Layout.preferredWidth: 65
                        spacing: 6

                        Rectangle {
                            width: 7
                            height: 7
                            radius: 3.5
                            color: modelData.isUp ? "#00E676" : "#64748B"
                        }

                        Text {
                            text: modelData.isUp ? "Up" : "Down"
                            font.pixelSize: 11
                            font.bold: true
                            font.family: Theme.fontSans
                            color: modelData.isUp ? "#00E676" : "#64748B"
                        }
                    }

                    // IP Address
                    Text {
                        text: modelData.ip
                        font.pixelSize: 11
                        font.family: Theme.fontMono
                        color: Theme.textSecondary
                        Layout.preferredWidth: 100
                    }

                    Item { Layout.fillWidth: true }

                    // Download Rate (Green)
                    RowLayout {
                        Layout.preferredWidth: 85
                        spacing: 4
                        visible: modelData.rxSpeed !== "—"

                        Text {
                            text: modelData.isUp ? "↓" : "●"
                            font.pixelSize: 11
                            font.bold: true
                            color: modelData.isUp ? "#00E676" : "#64748B"
                        }

                        Text {
                            text: modelData.rxSpeed
                            font.pixelSize: 11
                            font.bold: true
                            font.family: Theme.fontMono
                            color: modelData.isUp ? "#00E676" : "#64748B"
                        }
                    }

                    // Upload Rate (Blue)
                    RowLayout {
                        Layout.preferredWidth: 80
                        spacing: 4
                        visible: modelData.txSpeed !== "—"

                        Text {
                            text: "↑"
                            font.pixelSize: 11
                            font.bold: true
                            color: "#38BDF8"
                        }

                        Text {
                            text: modelData.txSpeed
                            font.pixelSize: 11
                            font.bold: true
                            font.family: Theme.fontMono
                            color: "#38BDF8"
                        }
                    }

                    Text {
                        visible: modelData.txSpeed === "—"
                        text: "—"
                        font.pixelSize: 11
                        font.family: Theme.fontMono
                        color: Theme.textMuted
                        Layout.preferredWidth: 80
                    }
                }
            }
        }
    }
}
