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

    property string selectedLevel: "ALL"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Page Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                text: "SYSTEM LOGS & JOURNAL"
                font.pixelSize: Theme.fontTitle
                font.bold: true
                color: Theme.textPrimary
            }

            Rectangle {
                height: 24
                width: 100
                radius: 12
                color: Theme.statusSuccessBg
                border.color: Theme.statusSuccess
                Text {
                    anchors.centerIn: parent
                    text: "STREAMING"
                    font.pixelSize: 10
                    font.bold: true
                    font.family: Theme.fontMono
                    color: Theme.statusSuccess
                }
            }

            Item { Layout.fillWidth: true }

            // Log level filters
            RowLayout {
                spacing: 6
                Repeater {
                    model: ["ALL", "INFO", "WARN", "ERROR"]
                    Rectangle {
                        height: 34
                        width: levelText.implicitWidth + 20
                        radius: Theme.radiusSmall
                        color: root.selectedLevel === modelData ? Theme.accentCyan : Theme.bgInput
                        border.color: root.selectedLevel === modelData ? Theme.accentCyan : Theme.borderSubtle

                        Text {
                            id: levelText
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 11
                            font.bold: true
                            color: root.selectedLevel === modelData ? "#0B0E14" : Theme.textSecondary
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.selectedLevel = modelData
                        }
                    }
                }
            }
        }

        // Terminal-style Log Viewer
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.bgInput
            radius: Theme.radiusMedium
            border.color: Theme.borderCard
            clip: true

            ListView {
                id: logListView
                anchors.fill: parent
                anchors.margins: 12
                spacing: 4

                model: [
                    { time: "23:14:02.102", unit: "kernel", level: "WARN", msg: "eth0: link rx throughput peaked at 410.2 Mbps (82% queue depth)" },
                    { time: "23:12:45.890", unit: "systemd-resolved[612]", level: "INFO", msg: "Using degraded feature set UDP instead of UDP+EDNS0 for DNS server 1.1.1.1" },
                    { time: "23:10:19.412", unit: "dockerd[1042]", level: "INFO", msg: "Container 74a2b919fe02 (prometheus) liveness probe completed successfully in 8ms" },
                    { time: "23:08:04.119", unit: "wireguard", level: "INFO", msg: "Peer [sN39...Z1a=] completed handshake (rx: 14.2 MB, tx: 18.9 MB)" },
                    { time: "23:05:33.782", unit: "pihole-FTL[510]", level: "INFO", msg: "Imported 1,842,019 gravity domains from 4 blocklists" },
                    { time: "23:01:12.001", unit: "ufw", level: "INFO", msg: "[UFW BLOCK] IN=eth0 OUT= MAC=dc:a6:32:8f:12:4a SRC=185.220.101.5 DST=192.168.1.2 PROTO=TCP SPT=48192 DPT=23" },
                    { time: "22:58:40.450", unit: "kea-dhcp4[620]", level: "INFO", msg: "DHCP4_LEASE_ALLOC lease 192.168.1.142 assigned to MAC f0:18:98:c2:55:01 for 86400s" },
                    { time: "22:55:00.100", unit: "kernel", level: "INFO", msg: "thermal thermal_zone0: temp=44200 mC, fan PWM adjusted to step 1 (1850 RPM)" },
                    { time: "22:50:18.904", unit: "sshd[1844]", level: "INFO", msg: "Accepted publickey for admin from 192.168.1.105 port 54820 ssh2: RSA SHA256:8yH..." },
                    { time: "22:45:12.330", unit: "chronyd[480]", level: "INFO", msg: "Selected source 162.159.200.1 (time.cloudflare.com) offset -0.000128s" }
                ]

                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: logListView.width
                    height: 32
                    color: index % 2 === 0 ? "transparent" : Qt.rgba(1, 1, 1, 0.02)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 12

                        Text {
                            text: modelData.time
                            font.pixelSize: 11
                            font.family: Theme.fontMono
                            color: Theme.textMuted
                            Layout.preferredWidth: 100
                        }

                        Rectangle {
                            height: 18
                            width: 50
                            radius: 3
                            color: modelData.level === "ERROR" ? Theme.statusCriticalBg : (modelData.level === "WARN" ? Theme.statusWarningBg : Theme.statusSuccessBg)
                            border.color: modelData.level === "ERROR" ? Theme.statusCritical : (modelData.level === "WARN" ? Theme.statusWarning : Theme.statusSuccess)

                            Text {
                                anchors.centerIn: parent
                                text: modelData.level
                                font.pixelSize: 9
                                font.bold: true
                                font.family: Theme.fontMono
                                color: modelData.level === "ERROR" ? Theme.statusCritical : (modelData.level === "WARN" ? Theme.statusWarning : Theme.statusSuccess)
                            }
                        }

                        Text {
                            text: modelData.unit
                            font.pixelSize: 11
                            font.bold: true
                            font.family: Theme.fontMono
                            color: Theme.accentCyan
                            Layout.preferredWidth: 160
                            elide: Text.ElideRight
                        }

                        Text {
                            text: modelData.msg
                            font.pixelSize: 11
                            font.family: Theme.fontMono
                            color: Theme.textPrimary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
