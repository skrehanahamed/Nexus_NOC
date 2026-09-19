import QtQuick
import QtQuick.Layouts
import NexusNOC

Rectangle {
    id: root

    property string title: "METRIC"
    property string value: "0"
    property string unit: "%"
    property string subtext: "Normal"
    property real percentage: 0.0      // 0.0 to 1.0
    property color accentColor: Theme.accentCyan
    property string iconName: ""

    color: touchArea.pressed ? Theme.bgCardActive : (touchArea.containsMouse ? Theme.bgCardHover : Theme.bgCard)
    border.color: touchArea.containsMouse ? Theme.borderBright : Theme.borderCard
    border.width: 1
    radius: Theme.radiusMedium

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    MouseArea {
        id: touchArea
        anchors.fill: parent
        hoverEnabled: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // Header
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: root.title.toUpperCase()
                font.pixelSize: Theme.fontSmall
                font.bold: true
                font.family: Theme.fontSans
                font.letterSpacing: 1.1
                color: Theme.textMuted
                Layout.fillWidth: true
            }

            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: root.percentage > 0.85 ? Theme.statusCritical : (root.percentage > 0.70 ? Theme.statusWarning : root.accentColor)

                // Gentle pulse for high usage
                SequentialAnimation on opacity {
                    running: root.percentage > 0.70
                    loops: Animation.Infinite
                    PropertyAnimation { to: 0.3; duration: 600 }
                    PropertyAnimation { to: 1.0; duration: 600 }
                }
            }
        }

        // Value and Unit
        RowLayout {
            spacing: 4
            Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

            Text {
                text: root.value
                font.pixelSize: Theme.fontTelemetry
                font.bold: true
                font.family: Theme.fontMono
                color: Theme.textPrimary
            }

            Text {
                text: root.unit
                font.pixelSize: Theme.fontHeader
                font.bold: true
                font.family: Theme.fontMono
                color: root.accentColor
                Layout.alignment: Qt.AlignBaseline
            }
        }

        // Progress Bar
        Rectangle {
            Layout.fillWidth: true
            height: 6
            radius: 3
            color: Theme.bgInput

            Rectangle {
                height: parent.height
                width: Math.min(parent.width, Math.max(4, parent.width * Math.max(0.0, Math.min(1.0, root.percentage))))
                radius: 3
                color: root.percentage > 0.85 ? Theme.statusCritical : (root.percentage > 0.70 ? Theme.statusWarning : root.accentColor)

                Behavior on width {
                    NumberAnimation { duration: 300; easing.type: Easing.OutQuad }
                }
            }
        }

        // Subtext / Details
        Text {
            text: root.subtext
            font.pixelSize: Theme.fontSmall
            font.family: Theme.fontSans
            color: Theme.textSecondary
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }
}
