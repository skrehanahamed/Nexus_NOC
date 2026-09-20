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

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                text: "DOCKER CONTAINERS"
                font.pixelSize: Theme.fontTitle
                font.bold: true
                color: Theme.textPrimary
            }

            Rectangle {
                height: 24
                width: 120
                radius: 12
                color: Theme.statusSuccessBg
                border.color: Theme.statusSuccess
                Text {
                    anchors.centerIn: parent
                    text: "8 RUNNING • 0 STOP"
                    font.pixelSize: 10
                    font.bold: true
                    font.family: Theme.fontMono
                    color: Theme.statusSuccess
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "ENGINE: Docker 26.1 • Storage: overlay2"
                font.pixelSize: Theme.fontSmall
                font.family: Theme.fontMono
                color: Theme.textMuted
            }
        }

        // Containers Grid / List
        ListView {
            id: dockerList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8

            model: [
                { name: "pihole", image: "pihole/pihole:latest", status: "Up 4 days (healthy)", ports: "53:53/udp, 80:80/tcp", cpu: "1.2%", mem: "142 MB / 8 GB", net: "1.2GB / 480MB" },
                { name: "wireguard", image: "linuxserver/wireguard:latest", status: "Up 4 days", ports: "51820:51820/udp", cpu: "0.8%", mem: "24 MB / 8 GB", net: "4.8GB / 5.1GB" },
                { name: "prometheus", image: "prom/prometheus:v2.45.0", status: "Up 4 days", ports: "9090:9090/tcp", cpu: "2.4%", mem: "88 MB / 8 GB", net: "820MB / 120MB" },
                { name: "grafana", image: "grafana/grafana:10.1.2", status: "Up 4 days", ports: "3000:3000/tcp", cpu: "1.5%", mem: "116 MB / 8 GB", net: "410MB / 290MB" },
                { name: "nginx-proxy-manager", image: "jc21/nginx-proxy-manager:latest", status: "Up 4 days", ports: "80:80, 443:443, 81:81", cpu: "0.9%", mem: "180 MB / 8 GB", net: "2.4GB / 2.1GB" },
                { name: "homeassistant", image: "ghcr.io/home-assistant/home-assistant:stable", status: "Up 4 days (healthy)", ports: "8123:8123/tcp", cpu: "3.8%", mem: "340 MB / 8 GB", net: "520MB / 310MB" },
                { name: "mosquitto-mqtt", image: "eclipse-mosquitto:2.0", status: "Up 4 days", ports: "1883:1883/tcp", cpu: "0.2%", mem: "12 MB / 8 GB", net: "84MB / 89MB" },
                { name: "node-red", image: "nodered/node-red:latest", status: "Up 4 days", ports: "1880:1880/tcp", cpu: "1.1%", mem: "95 MB / 8 GB", net: "120MB / 110MB" }
            ]

            delegate: Rectangle {
                required property var modelData
                width: dockerList.width
                height: 74
                radius: Theme.radiusSmall
                color: Theme.bgCard
                border.color: Theme.borderCard
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 16

                    // Docker Whale Icon / Indicator
                    Rectangle {
                        width: 40
                        height: 40
                        radius: Theme.radiusSmall
                        color: Theme.bgInput
                        border.color: Theme.borderSubtle

                        IconDraw {
                            anchors.centerIn: parent
                            iconName: "docker"
                            iconSize: 21
                            iconColor: Theme.accentCyan
                        }
                    }

                    // Container Info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            spacing: 8
                            Text {
                                text: modelData.name
                                font.pixelSize: Theme.fontBody
                                font.bold: true
                                font.family: Theme.fontMono
                                color: Theme.textPrimary
                            }

                            Rectangle {
                                height: 18
                                width: 50
                                radius: 9
                                color: Theme.statusSuccessBg
                                border.color: Theme.statusSuccess
                                Text {
                                    anchors.centerIn: parent
                                    text: "RUNNING"
                                    font.pixelSize: 8
                                    font.bold: true
                                    color: Theme.statusSuccess
                                }
                            }
                        }

                        Text {
                            text: modelData.image + " • " + modelData.ports
                            font.pixelSize: 11
                            font.family: Theme.fontMono
                            color: Theme.textMuted
                            elide: Text.ElideRight
                        }
                    }

                    // Stats
                    RowLayout {
                        spacing: 16

                        ColumnLayout {
                            spacing: 1
                            Text { text: "CPU"; font.pixelSize: 10; color: Theme.textMuted }
                            Text { text: modelData.cpu; font.pixelSize: Theme.fontSmall; font.family: Theme.fontMono; font.bold: true; color: Theme.accentCyan }
                        }

                        ColumnLayout {
                            spacing: 1
                            Text { text: "MEM USAGE"; font.pixelSize: 10; color: Theme.textMuted }
                            Text { text: modelData.mem; font.pixelSize: Theme.fontSmall; font.family: Theme.fontMono; color: Theme.textSecondary }
                        }

                        ColumnLayout {
                            spacing: 1
                            Text { text: "NET I/O"; font.pixelSize: 10; color: Theme.textMuted }
                            Text { text: modelData.net; font.pixelSize: Theme.fontSmall; font.family: Theme.fontMono; color: Theme.textMuted }
                        }
                    }

                    // Action Controls
                    RowLayout {
                        spacing: 6

                        Rectangle {
                            width: 36
                            height: 36
                            radius: Theme.radiusSmall
                            color: Theme.bgInput
                            border.color: Theme.borderSubtle
                            IconDraw { anchors.centerIn: parent; iconName: "uptime"; iconSize: 16; iconColor: Theme.textSecondary }
                        }

                        Rectangle {
                            width: 36
                            height: 36
                            radius: Theme.radiusSmall
                            color: Theme.bgInput
                            border.color: Theme.borderSubtle
                            IconDraw { anchors.centerIn: parent; iconName: "power"; iconSize: 16; iconColor: Theme.statusCritical }
                        }
                    }
                }
            }
        }
    }
}
