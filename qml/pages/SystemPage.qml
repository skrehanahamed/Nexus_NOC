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
    contentHeight: sysCol.implicitHeight + 40
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: sysCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        spacing: 16

        // Page Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                text: "SYSTEM HARDWARE & SENSORS"
                font.pixelSize: Theme.fontTitle
                font.bold: true
                color: Theme.textPrimary
            }

            Rectangle {
                height: 24
                width: 140
                radius: 12
                color: Theme.statusSuccessBg
                border.color: Theme.statusSuccess
                Text {
                    anchors.centerIn: parent
                    text: "HARDWARE HEALTHY"
                    font.pixelSize: 10
                    font.bold: true
                    font.family: Theme.fontMono
                    color: Theme.statusSuccess
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "BOARD: Raspberry Pi 5 Model B Rev 1.0 (8GB)"
                font.pixelSize: Theme.fontSmall
                font.family: Theme.fontMono
                color: Theme.textMuted
            }
        }

        // ROW 1: Per-Core CPU & Clocks
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            StatusCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 220
                title: "CPU Core Frequencies & Utilization"
                subtitle: "Broadcom BCM2712 (4x ARM Cortex-A76 @ 2.40 GHz)"
                badgeText: "GOVERNOR: schedutil"
                badgeColor: Theme.accentCyan
                badgeBgColor: Theme.bgInput

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    Repeater {
                        model: [
                            { core: "Core 0", load: 0.48, pct: "48%", freq: "2400 MHz", temp: "44.1°C" },
                            { core: "Core 1", load: 0.38, pct: "38%", freq: "2400 MHz", temp: "44.0°C" },
                            { core: "Core 2", load: 0.45, pct: "45%", freq: "2400 MHz", temp: "44.3°C" },
                            { core: "Core 3", load: 0.39, pct: "39%", freq: "2400 MHz", temp: "44.2°C" }
                        ]

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Text { text: modelData.core; font.pixelSize: 12; font.bold: true; font.family: Theme.fontMono; color: Theme.textPrimary; Layout.preferredWidth: 60 }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 8
                                radius: 4
                                color: Theme.bgInput
                                Rectangle {
                                    height: parent.height
                                    width: parent.width * modelData.load
                                    radius: 4
                                    color: Theme.accentCyan
                                }
                            }

                            Text { text: modelData.pct; font.pixelSize: 12; font.bold: true; font.family: Theme.fontMono; color: Theme.accentCyan; Layout.preferredWidth: 44 }
                            Text { text: modelData.freq; font.pixelSize: 11; font.family: Theme.fontMono; color: Theme.textSecondary; Layout.preferredWidth: 80 }
                            Text { text: modelData.temp; font.pixelSize: 11; font.family: Theme.fontMono; color: Theme.statusSuccess; Layout.preferredWidth: 60 }
                        }
                    }
                }
            }

            // Thermal & Cooling Telemetry
            StatusCard {
                Layout.preferredWidth: 420
                Layout.preferredHeight: 220
                title: "Thermal Management & Cooling"
                subtitle: "Active PWM Fan & Heatsink Sensors"
                badgeText: "THERMAL OK"
                badgeColor: Theme.statusSuccess
                badgeBgColor: Theme.statusSuccessBg

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "SoC Junction Temp:"; font.pixelSize: 12; color: Theme.textMuted; Layout.fillWidth: true }
                        Text { text: "44.2 °C"; font.pixelSize: 14; font.bold: true; font.family: Theme.fontMono; color: Theme.statusSuccess }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "PMIC Power Temp:"; font.pixelSize: 12; color: Theme.textMuted; Layout.fillWidth: true }
                        Text { text: "41.8 °C"; font.pixelSize: 14; font.bold: true; font.family: Theme.fontMono; color: Theme.statusSuccess }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "NVMe SSD Temp:"; font.pixelSize: 12; color: Theme.textMuted; Layout.fillWidth: true }
                        Text { text: "38.5 °C"; font.pixelSize: 14; font.bold: true; font.family: Theme.fontMono; color: Theme.statusSuccess }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Active Cooling Fan:"; font.pixelSize: 12; color: Theme.textMuted; Layout.fillWidth: true }
                        Text { text: "1,850 RPM (38% PWM)"; font.pixelSize: 14; font.bold: true; font.family: Theme.fontMono; color: Theme.accentCyan }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "Throttling Events:"; font.pixelSize: 12; color: Theme.textMuted; Layout.fillWidth: true }
                        Text { text: "None (0x0)"; font.pixelSize: 12; font.family: Theme.fontMono; color: Theme.textSecondary }
                    }
                }
            }
        }

        // ROW 2: Power & Storage Partitions
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            StatusCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                title: "Storage Partitions & NVMe Health"
                subtitle: "KIOXIA 128GB M.2 2230 NVMe SSD (PCIe Gen 2 x1)"
                badgeText: "SMART: PASSED"
                badgeColor: Theme.statusSuccess
                badgeBgColor: Theme.statusSuccessBg

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    Repeater {
                        model: [
                            { mount: "/ (rootfs)", used: "14.2 GB", total: "32 GB", pct: 0.44 },
                            { mount: "/var/log", used: "2.1 GB", total: "16 GB", pct: 0.13 },
                            { mount: "/data/docker", used: "21.9 GB", total: "80 GB", pct: 0.27 }
                        ]

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: modelData.mount; font.pixelSize: 12; font.bold: true; font.family: Theme.fontMono; color: Theme.textPrimary }
                                Item { Layout.fillWidth: true }
                                Text { text: modelData.used + " / " + modelData.total; font.pixelSize: 11; font.family: Theme.fontMono; color: Theme.textSecondary }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 6
                                radius: 3
                                color: Theme.bgInput
                                Rectangle {
                                    height: parent.height
                                    width: parent.width * modelData.pct
                                    radius: 3
                                    color: Theme.accentCyan
                                }
                            }
                        }
                    }
                }
            }

            StatusCard {
                Layout.preferredWidth: 420
                Layout.preferredHeight: 200
                title: "Power Supply & Voltage Rails"
                subtitle: "Official 27W USB-C PD Power Supply (5.1V / 5.0A)"
                badgeText: "POWER: 9.18W"
                badgeColor: Theme.accentCyan
                badgeBgColor: Theme.bgInput

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10

                    RowLayout {
                        Text { text: "Input Voltage:"; font.pixelSize: 12; color: Theme.textMuted; Layout.fillWidth: true }
                        Text { text: "5.12 V"; font.pixelSize: 13; font.bold: true; font.family: Theme.fontMono; color: Theme.textPrimary }
                    }

                    RowLayout {
                        Text { text: "Current Draw:"; font.pixelSize: 12; color: Theme.textMuted; Layout.fillWidth: true }
                        Text { text: "1.79 A"; font.pixelSize: 13; font.bold: true; font.family: Theme.fontMono; color: Theme.textPrimary }
                    }

                    RowLayout {
                        Text { text: "Under-voltage Status:"; font.pixelSize: 12; color: Theme.textMuted; Layout.fillWidth: true }
                        Text { text: "Normal (No Dip)"; font.pixelSize: 13; font.bold: true; font.family: Theme.fontMono; color: Theme.statusSuccess }
                    }

                    RowLayout {
                        Text { text: "RTC Battery Voltage:"; font.pixelSize: 12; color: Theme.textMuted; Layout.fillWidth: true }
                        Text { text: "3.08 V (Rechargeable)"; font.pixelSize: 12; font.family: Theme.fontMono; color: Theme.textSecondary }
                    }
                }
            }
        }
    }
}
