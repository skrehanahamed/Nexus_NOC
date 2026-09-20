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

    property string title: "Metric"
    property string value: "0"
    property string unit: ""
    property string trendText: ""
    property bool isTrendPositive: true
    property string iconName: "wifi"
    property color iconColor: Theme.accentCyan
    property color iconBgColor: Qt.rgba(iconColor.r, iconColor.g, iconColor.b, 0.15)
    property color sparkColor: Theme.accentCyan
    property var sparkPoints: [0.2, 0.4, 0.3, 0.6, 0.5, 0.8, 0.7, 0.9]

    implicitWidth: 210
    implicitHeight: 82
    Layout.fillWidth: true
    Layout.preferredHeight: 82

    radius: 10
    color: "#0C1322"
    border.color: "#1E293B"
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // Left: Circular Icon Badge
        Rectangle {
            width: 36
            height: 36
            radius: 18
            color: root.iconBgColor
            border.color: Qt.rgba(root.iconColor.r, root.iconColor.g, root.iconColor.b, 0.3)
            border.width: 1
            Layout.alignment: Qt.AlignVCenter

            IconDraw {
                anchors.centerIn: parent
                iconName: root.iconName
                iconColor: root.iconColor
                iconSize: 18
            }
        }

        // Middle: Title & Value + Trend
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                text: root.title
                font.pixelSize: 11
                font.family: Theme.fontSans
                color: Theme.textSecondary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 6
                Layout.alignment: Qt.AlignLeft

                Text {
                    text: root.value + (root.unit !== "" ? (" " + root.unit) : "")
                    font.pixelSize: 17
                    font.bold: true
                    font.family: Theme.fontMono
                    color: Theme.textPrimary
                }

                Text {
                    visible: root.trendText !== ""
                    text: root.trendText
                    font.pixelSize: 11
                    font.bold: true
                    font.family: Theme.fontMono
                    color: root.isTrendPositive ? Theme.statusSuccess : Theme.statusCritical
                }
            }
        }

        // Right: Mini Smooth Sparkline Waveform
        Canvas {
            id: sparkCanvas
            Layout.preferredWidth: 54
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignVCenter

            onPaint: {
                var ctx = getContext("2d");
                var w = width;
                var h = height;
                ctx.clearRect(0, 0, w, h);
                if (!root.sparkPoints || root.sparkPoints.length < 2) return;

                var pts = root.sparkPoints;
                var step = w / (pts.length - 1);

                // Gradient stroke
                ctx.beginPath();
                ctx.strokeStyle = root.sparkColor;
                ctx.lineWidth = 1.8;
                ctx.lineCap = "round";
                ctx.lineJoin = "round";

                for (var i = 0; i < pts.length; i++) {
                    var px = i * step;
                    var py = h - (pts[i] * (h - 6)) - 3;
                    if (i === 0) {
                        ctx.moveTo(px, py);
                    } else {
                        var prevX = (i - 1) * step;
                        var prevY = h - (pts[i - 1] * (h - 6)) - 3;
                        var cpx1 = prevX + step * 0.5;
                        var cpy1 = prevY;
                        var cpx2 = prevX + step * 0.5;
                        var cpy2 = py;
                        ctx.bezierCurveTo(cpx1, cpy1, cpx2, cpy2, px, py);
                    }
                }
                ctx.stroke();
            }

            Connections {
                target: root
                function onSparkPointsChanged() { sparkCanvas.requestPaint(); }
                function onSparkColorChanged() { sparkCanvas.requestPaint(); }
            }
        }
    }
}
