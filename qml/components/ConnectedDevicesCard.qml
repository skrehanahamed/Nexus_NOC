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

    signal deviceClicked(var device)
    signal viewAllClicked()

    property var devicesList: (typeof deviceManager !== "undefined" && deviceManager && deviceManager.devices) ? deviceManager.devices : [
        { name: "MacBook Air", ip: "192.168.1.45", type: "Laptop", icon: "laptop", connection: "Wi-Fi", lastSeen: "Now", online: true },
        { name: "iPhone", ip: "192.168.1.56", type: "Phone", icon: "phone", connection: "Wi-Fi", lastSeen: "1 min ago", online: true },
        { name: "Samsung TV", ip: "192.168.1.78", type: "TV", icon: "tv", connection: "Wi-Fi", lastSeen: "2 min ago", online: true },
        { name: "IP Camera", ip: "192.168.1.90", type: "Camera", icon: "camera", connection: "Wi-Fi", lastSeen: "3 min ago", online: true },
        { name: "PlayStation", ip: "192.168.1.102", type: "Console", icon: "gamepad", connection: "Wi-Fi", lastSeen: "5 min ago", online: true },
        { name: "ESP32", ip: "192.168.1.150", type: "IoT", icon: "chip", connection: "Wi-Fi", lastSeen: "Offline", online: false }
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

        // Header Row: Title and View All
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Connected Devices"
                font.pixelSize: 14
                font.bold: true
                font.family: Theme.fontSans
                color: Theme.textPrimary
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

        // Table Column Headers
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text { text: "Status"; font.pixelSize: 11; font.family: Theme.fontSans; color: Theme.textMuted; Layout.preferredWidth: 50 }
            Text { text: "Name"; font.pixelSize: 11; font.family: Theme.fontSans; color: Theme.textMuted; Layout.preferredWidth: 120 }
            Text { text: "IP Address"; font.pixelSize: 11; font.family: Theme.fontSans; color: Theme.textMuted; Layout.preferredWidth: 105 }
            Text { text: "Type"; font.pixelSize: 11; font.family: Theme.fontSans; color: Theme.textMuted; Layout.preferredWidth: 50 }
            Text { text: "Connection"; font.pixelSize: 11; font.family: Theme.fontSans; color: Theme.textMuted; Layout.preferredWidth: 80 }
            Text { text: "Last Seen"; font.pixelSize: 11; font.family: Theme.fontSans; color: Theme.textMuted; Layout.fillWidth: true }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#162238"
        }

        // Device Rows ListView
        ListView {
            id: devListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 6
            interactive: true
            model: root.devicesList

            delegate: Rectangle {
                required property var modelData
                width: devListView.width
                height: 28
                radius: 4
                color: mouseItem.containsMouse ? "#131E33" : "transparent"

                RowLayout {
                    anchors.fill: parent
                    spacing: 8

                    // Status Dot
                    Item {
                        Layout.preferredWidth: 50
                        Layout.fillHeight: true
                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            width: 7
                            height: 7
                            radius: 3.5
                            color: modelData.online ? "#00E676" : "#64748B"
                        }
                    }

                    // Device Name
                    Text {
                        text: modelData.name
                        font.pixelSize: 12
                        font.family: Theme.fontSans
                        color: Theme.textPrimary
                        Layout.preferredWidth: 120
                        elide: Text.ElideRight
                    }

                    // IP Address
                    Text {
                        text: modelData.ip
                        font.pixelSize: 11
                        font.family: Theme.fontMono
                        color: Theme.textSecondary
                        Layout.preferredWidth: 105
                    }

                    // Type Icon
                    Item {
                        Layout.preferredWidth: 50
                        Layout.fillHeight: true
                        IconDraw {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            iconName: modelData.icon ? modelData.icon : "devices"
                            iconColor: Theme.accentCyan
                            iconSize: 15
                        }
                    }

                    // Connection
                    Text {
                        text: modelData.connection ? modelData.connection : "Wi-Fi"
                        font.pixelSize: 11
                        font.family: Theme.fontSans
                        color: Theme.textSecondary
                        Layout.preferredWidth: 80
                    }

                    // Last Seen
                    Text {
                        text: modelData.lastSeen ? modelData.lastSeen : (modelData.online ? "Now" : "Offline")
                        font.pixelSize: 11
                        font.family: Theme.fontSans
                        color: modelData.online ? Theme.textSecondary : Theme.textMuted
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: mouseItem
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.deviceClicked(modelData)
                }
            }
        }
    }
}
