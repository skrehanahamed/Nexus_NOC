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

Item {
    id: root

    property string alertFilter: "ALL"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Page Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Image {
                source: "qrc:/qt/qml/NexusNOC/qml/assets/alert_bell_red.png"
                Layout.preferredWidth: 24
                Layout.preferredHeight: 26
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

            Text {
                text: "ALERTS & INCIDENT CENTER"
                font.pixelSize: Theme.fontTitle
                font.bold: true
                color: Theme.textPrimary
            }

            Rectangle {
                height: 24
                width: 130
                radius: 12
                color: Theme.statusWarningBg
                border.color: Theme.statusWarning
                Text {
                    anchors.centerIn: parent
                    text: "1 ACTIVE WARNING"
                    font.pixelSize: 10
                    font.bold: true
                    font.family: Theme.fontMono
                    color: Theme.statusWarning
                }
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 6
                Repeater {
                    model: ["ALL", "ACTIVE", "RESOLVED"]
                    Rectangle {
                        height: 34
                        width: tabText.implicitWidth + 20
                        radius: Theme.radiusSmall
                        color: root.alertFilter === modelData ? Theme.accentCyan : Theme.bgInput
                        border.color: root.alertFilter === modelData ? Theme.accentCyan : Theme.borderSubtle

                        Text {
                            id: tabText
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 11
                            font.bold: true
                            color: root.alertFilter === modelData ? "#0B0E14" : Theme.textSecondary
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.alertFilter = modelData
                        }
                    }
                }
            }
        }

        // Alerts List
        ListView {
            id: alertList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8

            model: [
                { sev: "warning", sub: "NETWORK", time: "23:14:02", msg: "WAN latency spike to 142ms on gateway hop (threshold 100ms)", ack: false },
                { sev: "info", sub: "DOCKER", time: "22:45:18", msg: "Container 'prometheus' image healthcheck passed successfully", ack: true },
                { sev: "info", sub: "SECURITY", time: "21:30:00", msg: "Nightly automated firewall rule validation ok (0 unauthorized drop spikes)", ack: true },
                { sev: "warning", sub: "STORAGE", time: "18:22:11", msg: "NVMe trim scheduled task took 14.2s (I/O wait elevated)", ack: true },
                { sev: "critical", sub: "SYSTEM", time: "12:04:55", msg: "WAN link eth0 down event detected (recovered after 3s)", ack: true }
            ]

            delegate: AlertCard {
                required property var modelData
                width: alertList.width
                severity: modelData.sev
                subsystem: modelData.sub
                timestamp: modelData.time
                message: modelData.msg
                acknowledged: modelData.ack
                visible: root.alertFilter === "ALL" || (root.alertFilter === "ACTIVE" && !modelData.ack) || (root.alertFilter === "RESOLVED" && modelData.ack)
                height: visible ? 60 : 0
            }
        }
    }
}
