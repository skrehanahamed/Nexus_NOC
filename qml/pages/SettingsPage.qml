import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import NexusNOC
import "../components"

Flickable {
    id: root

    contentWidth: width
    contentHeight: setCol.implicitHeight + 40
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    property int screenBrightness: 85
    property string activeTimeout: "15 min"

    ColumnLayout {
        id: setCol
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20
        spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                text: "APPLIANCE CONFIGURATION"
                font.pixelSize: Theme.fontTitle
                font.bold: true
                color: Theme.textPrimary
            }

            Rectangle {
                height: 24
                width: 110
                radius: 12
                color: Theme.bgInput
                border.color: Theme.borderSubtle
                Text {
                    anchors.centerIn: parent
                    text: "ADMIN MODE"
                    font.pixelSize: 10
                    font.bold: true
                    font.family: Theme.fontMono
                    color: Theme.accentCyan
                }
            }
        }

        // Section 1: Touchscreen & Display
        StatusCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            title: "10.1\" Touchscreen & Display"
            subtitle: "1920x1200 / 1280x800 MIPI DSI / HDMI Display Panel"
            showHeader: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 16

                // Brightness Slider
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Text {
                        text: "Display Brightness"
                        font.pixelSize: Theme.fontBody
                        color: Theme.textPrimary
                        Layout.preferredWidth: 160
                    }

                    Slider {
                        id: brightSlider
                        Layout.fillWidth: true
                        from: 10
                        to: 100
                        value: root.screenBrightness
                        onMoved: root.screenBrightness = Math.round(value)
                    }

                    Text {
                        text: root.screenBrightness + "%"
                        font.pixelSize: Theme.fontHeader
                        font.bold: true
                        font.family: Theme.fontMono
                        color: Theme.accentCyan
                        Layout.preferredWidth: 60
                    }
                }

                // Screen Timeout
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    Text {
                        text: "Screen Sleep Timeout"
                        font.pixelSize: Theme.fontBody
                        color: Theme.textPrimary
                        Layout.preferredWidth: 160
                    }

                    RowLayout {
                        spacing: 8
                        Repeater {
                            model: ["5 min", "15 min", "30 min", "Never"]
                            Rectangle {
                                height: 38
                                width: 88
                                radius: Theme.radiusSmall
                                color: root.activeTimeout === modelData ? Theme.accentCyan : Theme.bgInput
                                border.color: root.activeTimeout === modelData ? Theme.accentCyan : Theme.borderSubtle

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: root.activeTimeout === modelData ? "#0B0E14" : Theme.textSecondary
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: root.activeTimeout = modelData
                                }
                            }
                        }
                    }
                }
            }
        }

        // Section 2: Appliance Network Identity
        StatusCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            title: "Appliance Network Identity"
            subtitle: "Static IP & Hostname Assignment"
            showHeader: true

            RowLayout {
                anchors.fill: parent
                spacing: 16

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text { text: "APPLIANCE HOSTNAME"; font.pixelSize: 11; color: Theme.textMuted }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 42
                        radius: Theme.radiusSmall
                        color: Theme.bgInput
                        border.color: Theme.borderSubtle
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            text: "nexus-noc-core.local"
                            font.pixelSize: 13
                            font.family: Theme.fontMono
                            color: Theme.textPrimary
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text { text: "STATIC IP ADDRESS"; font.pixelSize: 11; color: Theme.textMuted }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 42
                        radius: Theme.radiusSmall
                        color: Theme.bgInput
                        border.color: Theme.borderSubtle
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            text: "192.168.1.2"
                            font.pixelSize: 13
                            font.family: Theme.fontMono
                            color: Theme.accentCyan
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text { text: "GATEWAY IP"; font.pixelSize: 11; color: Theme.textMuted }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 42
                        radius: Theme.radiusSmall
                        color: Theme.bgInput
                        border.color: Theme.borderSubtle
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            text: "192.168.1.1"
                            font.pixelSize: 13
                            font.family: Theme.fontMono
                            color: Theme.textSecondary
                        }
                    }
                }
            }
        }

        // Section 3: Appliance Operations & Power
        StatusCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            title: "Appliance Operations & Power Control"
            subtitle: "Hardware Maintenance and Graceful Shutdown"
            showHeader: true

            RowLayout {
                anchors.fill: parent
                spacing: 16

                // Export Diagnostic Bundle
                Rectangle {
                    Layout.fillWidth: true
                    height: Theme.touchButtonHeight
                    radius: Theme.radiusSmall
                    color: Theme.bgInput
                    border.color: Theme.borderSubtle

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        IconDraw { iconName: "logs"; iconSize: 16; iconColor: Theme.textSecondary }
                        Text {
                            text: "EXPORT DIAGNOSTIC BUNDLE"
                            font.pixelSize: 12
                            font.bold: true
                            font.letterSpacing: 0.8
                            color: Theme.textPrimary
                        }
                    }
                }

                // Reboot Button
                Rectangle {
                    Layout.fillWidth: true
                    height: Theme.touchButtonHeight
                    radius: Theme.radiusSmall
                    color: Theme.statusWarningBg
                    border.color: Theme.statusWarning

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        IconDraw { iconName: "uptime"; iconSize: 16; iconColor: Theme.statusWarning }
                        Text {
                            text: "REBOOT APPLIANCE"
                            font.pixelSize: 12
                            font.bold: true
                            font.letterSpacing: 0.8
                            color: Theme.statusWarning
                        }
                    }
                }

                // Shutdown Button
                Rectangle {
                    Layout.fillWidth: true
                    height: Theme.touchButtonHeight
                    radius: Theme.radiusSmall
                    color: Theme.statusCriticalBg
                    border.color: Theme.statusCritical

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        IconDraw { iconName: "power"; iconSize: 16; iconColor: Theme.statusCritical }
                        Text {
                            text: "SAFE SHUTDOWN"
                            font.pixelSize: 12
                            font.bold: true
                            font.letterSpacing: 0.8
                            color: Theme.statusCritical
                        }
                    }
                }
            }
        }
    }
}
