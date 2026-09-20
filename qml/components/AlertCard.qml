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

    property string severity: "warning" // "critical", "warning", "info"
    property string subsystem: "NETWORK"
    property string timestamp: "14:23:05"
    property string message: "High latency detected on WAN gateway (182ms)"
    property bool acknowledged: false

    signal acknowledgeRequested()

    readonly property color severityColor: severity === "critical" ? Theme.statusCritical : (severity === "warning" ? Theme.statusWarning : Theme.statusInfo)
    readonly property color severityBgColor: severity === "critical" ? Theme.statusCriticalBg : (severity === "warning" ? Theme.statusWarningBg : Theme.statusInfoBg)

    height: 60
    color: root.acknowledged ? Theme.bgInput : Theme.bgCard
    border.color: root.acknowledged ? Theme.borderSubtle : Qt.rgba(root.severityColor.r, root.severityColor.g, root.severityColor.b, 0.4)
    border.width: 1
    radius: Theme.radiusSmall

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        // Severity indicator bar
        Rectangle {
            width: 4
            Layout.fillHeight: true
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            radius: 2
            color: root.acknowledged ? Theme.textMuted : root.severityColor
        }

        // Subsystem badge & time
        ColumnLayout {
            Layout.preferredWidth: 90
            spacing: 2

            Rectangle {
                height: 18
                width: subText.implicitWidth + 8
                radius: 3
                color: root.severityBgColor
                border.color: Qt.rgba(root.severityColor.r, root.severityColor.g, root.severityColor.b, 0.3)

                Text {
                    id: subText
                    anchors.centerIn: parent
                    text: root.subsystem
                    font.pixelSize: 9
                    font.bold: true
                    font.family: Theme.fontMono
                    color: root.severityColor
                }
            }

            Text {
                text: root.timestamp
                font.pixelSize: 10
                font.family: Theme.fontMono
                color: Theme.textMuted
            }
        }

        // Message
        Text {
            text: root.message
            font.pixelSize: Theme.fontBody
            color: root.acknowledged ? Theme.textMuted : Theme.textPrimary
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        // Acknowledge touch button
        Rectangle {
            visible: !root.acknowledged
            width: 68
            height: 32
            radius: Theme.radiusSmall
            color: ackTouch.pressed ? Theme.bgCardActive : Theme.bgInput
            border.color: Theme.borderSubtle

            Text {
                anchors.centerIn: parent
                text: "ACK"
                font.pixelSize: Theme.fontSmall
                font.bold: true
                font.letterSpacing: 0.8
                color: Theme.textSecondary
            }

            MouseArea {
                id: ackTouch
                anchors.fill: parent
                onClicked: {
                    root.acknowledged = true;
                    root.acknowledgeRequested();
                }
            }
        }
    }
}
