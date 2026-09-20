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

    property string interfaceName: "eth0"
    property string interfaceType: "Gigabit Ethernet"
    property string ipAddress: "192.168.1.2/24"
    property string macAddress: "DC:A6:32:8F:12:4A"
    property string linkSpeed: "1000 Mbps Full Duplex"
    property string rxRate: "384.2 Mbps"
    property string txRate: "42.8 Mbps"
    property bool isUp: true

    color: Theme.bgCard
    border.color: Theme.borderCard
    border.width: 1
    radius: Theme.radiusMedium

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header: Interface Name & Status
        RowLayout {
            Layout.fillWidth: true

            Rectangle {
                width: 36
                height: 36
                radius: Theme.radiusSmall
                color: root.isUp ? Theme.statusSuccessBg : Theme.statusCriticalBg
                border.color: root.isUp ? Theme.statusSuccess : Theme.statusCritical
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: root.interfaceName.startsWith("eth") ? "⚡" : (root.interfaceName.startsWith("wl") ? "📶" : "🔒")
                    font.pixelSize: 18
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: root.interfaceName.toUpperCase()
                    font.pixelSize: Theme.fontHeader
                    font.bold: true
                    font.family: Theme.fontMono
                    color: Theme.textPrimary
                }

                Text {
                    text: root.interfaceType
                    font.pixelSize: Theme.fontSmall
                    color: Theme.textMuted
                }
            }

            // State Badge
            Rectangle {
                height: 24
                width: 64
                radius: 12
                color: root.isUp ? Theme.statusSuccessBg : Theme.statusCriticalBg
                border.color: root.isUp ? Theme.statusSuccess : Theme.statusCritical

                Text {
                    anchors.centerIn: parent
                    text: root.isUp ? "UP" : "DOWN"
                    font.pixelSize: Theme.fontSmall
                    font.bold: true
                    font.family: Theme.fontMono
                    color: root.isUp ? Theme.statusSuccess : Theme.statusCritical
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderSubtle }

        // IP and MAC
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Text { text: "IPv4:"; font.pixelSize: Theme.fontSmall; color: Theme.textMuted; Layout.preferredWidth: 60 }
                Text { text: root.ipAddress; font.pixelSize: Theme.fontBody; font.bold: true; font.family: Theme.fontMono; color: Theme.textPrimary }
            }

            RowLayout {
                Text { text: "MAC:"; font.pixelSize: Theme.fontSmall; color: Theme.textMuted; Layout.preferredWidth: 60 }
                Text { text: root.macAddress; font.pixelSize: Theme.fontSmall; font.family: Theme.fontMono; color: Theme.textSecondary }
            }

            RowLayout {
                Text { text: "SPEED:"; font.pixelSize: Theme.fontSmall; color: Theme.textMuted; Layout.preferredWidth: 60 }
                Text { text: root.linkSpeed; font.pixelSize: Theme.fontSmall; font.family: Theme.fontMono; color: Theme.accentCyan }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderSubtle }

        // RX / TX Bandwidth
        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { text: "DOWNLINK (RX)"; font.pixelSize: 10; font.bold: true; color: Theme.textMuted }
                Text { text: root.rxRate; font.pixelSize: Theme.fontBody; font.bold: true; font.family: Theme.fontMono; color: Theme.accentCyan }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text { text: "UPLINK (TX)"; font.pixelSize: 10; font.bold: true; color: Theme.textMuted }
                Text { text: root.txRate; font.pixelSize: Theme.fontBody; font.bold: true; font.family: Theme.fontMono; color: Theme.accentPurple }
            }
        }
    }
}
