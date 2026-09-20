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

Flickable {
    id: root

    contentWidth: width
    contentHeight: netCol.implicitHeight + 40
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: netCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        spacing: 16

        // Page Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Text {
                text: "NETWORK INTERFACES & ROUTING"
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
                    text: "3 ACTIVE LINKS"
                    font.pixelSize: 10
                    font.bold: true
                    font.family: Theme.fontMono
                    color: Theme.statusSuccess
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "DEFAULT GATEWAY: 192.168.1.1 (eth0)"
                font.pixelSize: Theme.fontSmall
                font.family: Theme.fontMono
                color: Theme.textMuted
            }
        }

        // Row 1: Detailed Interfaces
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            NetworkCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 210
                interfaceName: "eth0"
                interfaceType: "1000BASE-T Gigabit Ethernet (WAN/LAN)"
                ipAddress: "192.168.1.2 / 24"
                macAddress: "DC:A6:32:8F:12:4A"
                linkSpeed: "1000 Mbps Full Duplex (MTU 1500)"
                rxRate: "384.5 Mbps"
                txRate: "42.8 Mbps"
                isUp: true
            }

            NetworkCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 210
                interfaceName: "wlan0"
                interfaceType: "802.11ax Wi-Fi 6 (Standby Failover)"
                ipAddress: "192.168.1.3 / 24"
                macAddress: "DC:A6:32:8F:12:4B"
                linkSpeed: "866 Mbps (5GHz Channel 48)"
                rxRate: "1.2 Mbps"
                txRate: "0.4 Mbps"
                isUp: true
            }

            NetworkCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 210
                interfaceName: "wg0"
                interfaceType: "WireGuard Secure VPN Tunnel"
                ipAddress: "10.10.0.1 / 24"
                macAddress: "VIRTUAL TUNNEL"
                linkSpeed: "Encrypted UDP Port 51820"
                rxRate: "28.4 Mbps"
                txRate: "31.2 Mbps"
                isUp: true
            }
        }

        // Row 2: Routing Table & DNS Benchmarks
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 320
            spacing: 14

            // Kernel Routing Table
            StatusCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "Kernel IP Routing Table"
                subtitle: "Active IPv4 Routes (Linux FIB)"
                badgeText: "KERNEL FIB"
                badgeColor: Theme.accentCyan
                badgeBgColor: Theme.bgInput

                ListView {
                    id: routingList
                    anchors.fill: parent
                    clip: true
                    spacing: 4
                    model: [
                        { dest: "0.0.0.0/0", gateway: "192.168.1.1", iface: "eth0", metric: "100", proto: "static" },
                        { dest: "192.168.1.0/24", gateway: "0.0.0.0", iface: "eth0", metric: "100", proto: "kernel" },
                        { dest: "10.10.0.0/24", gateway: "0.0.0.0", iface: "wg0", metric: "50", proto: "kernel" },
                        { dest: "172.17.0.0/16", gateway: "0.0.0.0", iface: "docker0", metric: "0", proto: "kernel" },
                        { dest: "192.168.1.3/32", gateway: "0.0.0.0", iface: "wlan0", metric: "600", proto: "kernel" }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        width: routingList.width
                        height: 44
                        radius: Theme.radiusSmall
                        color: Theme.bgInput
                        border.color: Theme.borderSubtle

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            Text { text: modelData.dest; font.pixelSize: 12; font.bold: true; font.family: Theme.fontMono; color: Theme.textPrimary; Layout.preferredWidth: 140 }
                            Text { text: "via " + modelData.gateway; font.pixelSize: 11; font.family: Theme.fontMono; color: Theme.accentCyan; Layout.preferredWidth: 140 }
                            Text { text: "dev " + modelData.iface; font.pixelSize: 11; font.family: Theme.fontMono; color: Theme.textSecondary; Layout.preferredWidth: 80 }
                            Text { text: "metric " + modelData.metric; font.pixelSize: 10; font.family: Theme.fontMono; color: Theme.textMuted }
                            Item { Layout.fillWidth: true }
                            Text { text: modelData.proto; font.pixelSize: 10; color: Theme.textDim }
                        }
                    }
                }
            }

            // Upstream DNS Latency Probes
            StatusCard {
                Layout.preferredWidth: 420
                Layout.fillHeight: true
                title: "Upstream DNS Latency"
                subtitle: "Live probe response times"
                badgeText: "DNS HEALTHY"
                badgeColor: Theme.statusSuccess
                badgeBgColor: Theme.statusSuccessBg

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    Repeater {
                        model: [
                            { name: "Cloudflare Primary", ip: "1.1.1.1", ping: "10.4 ms", status: "Optimal" },
                            { name: "Cloudflare Secondary", ip: "1.0.0.1", ping: "11.2 ms", status: "Optimal" },
                            { name: "Google Public DNS", ip: "8.8.8.8", ping: "14.8 ms", status: "Good" },
                            { name: "Quad9 Secure", ip: "9.9.9.9", ping: "16.1 ms", status: "Good" }
                        ]

                        Rectangle {
                            Layout.fillWidth: true
                            height: 48
                            radius: Theme.radiusSmall
                            color: Theme.bgInput
                            border.color: Theme.borderSubtle

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                Rectangle { width: 8; height: 8; radius: 4; color: Theme.statusSuccess }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text { text: modelData.name; font.pixelSize: 12; font.bold: true; color: Theme.textPrimary }
                                    Text { text: modelData.ip; font.pixelSize: 10; font.family: Theme.fontMono; color: Theme.textMuted }
                                }

                                Text { text: modelData.ping; font.pixelSize: 12; font.bold: true; font.family: Theme.fontMono; color: Theme.accentCyan }
                            }
                        }
                    }
                }
            }
        }
    }
}
