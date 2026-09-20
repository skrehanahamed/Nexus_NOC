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

    property string deviceName: "MacBook Pro"
    property string ipAddress: "192.168.1.105"
    property string macAddress: "A4:83:E7:4F:29:1A"
    property string connectionType: "1000M Ethernet"
    property string iconName: "laptop"
    property string rxRate: "142.3 Mbps"
    property string txRate: "12.8 Mbps"
    property bool isOnline: true
    property bool isBlocked: false

    signal toggleBlock()

    height: 76
    color: touchArea.pressed ? Theme.bgCardActive : (touchArea.containsMouse ? Theme.bgCardHover : Theme.bgCard)
    border.color: root.isBlocked ? Theme.statusCritical : (touchArea.containsMouse ? Theme.borderBright : Theme.borderCard)
    border.width: 1
    radius: Theme.radiusSmall

    Behavior on color { ColorAnimation { duration: 150 } }

    MouseArea {
        id: touchArea
        anchors.fill: parent
        hoverEnabled: true
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 16

        // Device Icon + Status Dot
        Item {
            width: 44
            height: 44

            Rectangle {
                anchors.fill: parent
                radius: Theme.radiusSmall
                color: Theme.bgInput
                border.color: Theme.borderSubtle

                IconDraw {
                    anchors.centerIn: parent
                    iconName: root.iconName
                    iconSize: 21
                    iconColor: root.isBlocked ? Theme.textMuted : Theme.accentCyan
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: -2
                width: 12
                height: 12
                radius: 6
                color: root.isBlocked ? Theme.statusCritical : (root.isOnline ? Theme.statusSuccess : Theme.statusWarning)
                border.color: Theme.bgCard
                border.width: 2
            }
        }

        // Hostname, IP, MAC
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                spacing: 8
                Text {
                    text: root.deviceName
                    font.pixelSize: Theme.fontBody
                    font.bold: true
                    color: root.isBlocked ? Theme.textMuted : Theme.textPrimary
                }

                Rectangle {
                    visible: root.isBlocked
                    height: 18
                    width: 54
                    radius: 9
                    color: Theme.statusCriticalBg
                    border.color: Theme.statusCritical
                    Text {
                        anchors.centerIn: parent
                        text: "BLOCKED"
                        font.pixelSize: 9
                        font.bold: true
                        color: Theme.statusCritical
                    }
                }
            }

            RowLayout {
                spacing: 12
                Text {
                    text: root.ipAddress
                    font.pixelSize: Theme.fontSmall
                    font.family: Theme.fontMono
                    color: Theme.accentCyan
                }
                Text {
                    text: root.macAddress
                    font.pixelSize: Theme.fontSmall
                    font.family: Theme.fontMono
                    color: Theme.textMuted
                }
                Text {
                    text: "• " + root.connectionType
                    font.pixelSize: Theme.fontSmall
                    color: Theme.textSecondary
                }
            }
        }

        // Bandwidth
        ColumnLayout {
            spacing: 2
            Layout.preferredWidth: 120
            visible: root.isOnline && !root.isBlocked

            RowLayout {
                Text { text: "↓"; font.pixelSize: 12; color: Theme.accentCyan; font.bold: true }
                Text { text: root.rxRate; font.pixelSize: Theme.fontSmall; font.family: Theme.fontMono; color: Theme.textPrimary }
            }
            RowLayout {
                Text { text: "↑"; font.pixelSize: 12; color: Theme.accentPurple; font.bold: true }
                Text { text: root.txRate; font.pixelSize: Theme.fontSmall; font.family: Theme.fontMono; color: Theme.textSecondary }
            }
        }

        // Block / Allow Touch Button
        Rectangle {
            Layout.preferredWidth: 76
            Layout.preferredHeight: Theme.touchMinHeight - 8
            radius: Theme.radiusSmall
            color: root.isBlocked ? Qt.rgba(Theme.statusSuccess.r, Theme.statusSuccess.g, Theme.statusSuccess.b, 0.15) : Qt.rgba(Theme.statusCritical.r, Theme.statusCritical.g, Theme.statusCritical.b, 0.15)
            border.color: root.isBlocked ? Theme.statusSuccess : Theme.statusCritical
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: root.isBlocked ? "ALLOW" : "BLOCK"
                font.pixelSize: Theme.fontSmall
                font.bold: true
                font.letterSpacing: 1.0
                color: root.isBlocked ? Theme.statusSuccess : Theme.statusCritical
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.isBlocked = !root.isBlocked;
                    root.toggleBlock();
                }
            }
        }
    }
}
