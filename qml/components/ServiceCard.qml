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

    property string serviceName: "pihole-FTL"
    property string description: "DNS Sinkhole & Local Resolver"
    property string status: "active"      // "active", "failed", "inactive"
    property string memoryUsage: "48.2 MB"
    property string cpuUsage: "0.8%"
    property string uptime: "4d 12h"
    property int port: 53

    signal restartRequested()

    height: 72
    color: touchArea.pressed ? Theme.bgCardActive : (touchArea.containsMouse ? Theme.bgCardHover : Theme.bgCard)
    border.color: root.status === "failed" ? Theme.statusCritical : (touchArea.containsMouse ? Theme.borderBright : Theme.borderCard)
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

        // Status Indicator Pill
        Rectangle {
            width: 10
            height: 10
            radius: 5
            color: root.status === "active" ? Theme.statusSuccess : (root.status === "failed" ? Theme.statusCritical : Theme.statusWarning)

            SequentialAnimation on opacity {
                running: root.status === "failed"
                loops: Animation.Infinite
                PropertyAnimation { to: 0.2; duration: 500 }
                PropertyAnimation { to: 1.0; duration: 500 }
            }
        }

        // Service Info
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                spacing: 8

                Text {
                    text: root.serviceName
                    font.pixelSize: Theme.fontBody
                    font.bold: true
                    font.family: Theme.fontMono
                    color: Theme.textPrimary
                }

                Rectangle {
                    visible: root.port > 0
                    height: 18
                    width: portText.implicitWidth + 10
                    radius: 4
                    color: Theme.bgInput
                    border.color: Theme.borderSubtle

                    Text {
                        id: portText
                        anchors.centerIn: parent
                        text: ":" + root.port
                        font.pixelSize: 10
                        font.family: Theme.fontMono
                        color: Theme.accentCyan
                    }
                }
            }

            Text {
                text: root.description
                font.pixelSize: Theme.fontSmall
                color: Theme.textMuted
            }
        }

        // Telemetry (Memory & CPU)
        RowLayout {
            spacing: 16

            ColumnLayout {
                spacing: 1
                Text { text: "CPU"; font.pixelSize: 10; color: Theme.textMuted }
                Text { text: root.cpuUsage; font.pixelSize: Theme.fontSmall; font.family: Theme.fontMono; font.bold: true; color: Theme.textPrimary }
            }

            ColumnLayout {
                spacing: 1
                Text { text: "MEM"; font.pixelSize: 10; color: Theme.textMuted }
                Text { text: root.memoryUsage; font.pixelSize: Theme.fontSmall; font.family: Theme.fontMono; color: Theme.textSecondary }
            }

            ColumnLayout {
                spacing: 1
                Text { text: "UPTIME"; font.pixelSize: 10; color: Theme.textMuted }
                Text { text: root.uptime; font.pixelSize: Theme.fontSmall; font.family: Theme.fontMono; color: Theme.textMuted }
            }
        }

        // Restart Action Button
        Rectangle {
            width: 44
            height: 44
            radius: Theme.radiusSmall
            color: restartTouch.pressed ? Theme.bgCardActive : Theme.bgInput
            border.color: Theme.borderSubtle

            IconDraw {
                anchors.centerIn: parent
                iconName: "uptime"
                iconSize: 18
                iconColor: Theme.textSecondary
            }

            MouseArea {
                id: restartTouch
                anchors.fill: parent
                onClicked: root.restartRequested()
            }
        }
    }
}
