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
    property string iconSource: ""
    property string iconName: "wifi"
    property color iconColor: Theme.accentCyan
    property color sparkColor: Theme.accentCyan
    property var sparkPoints: [0.3, 0.5, 0.4, 0.7, 0.6, 0.85, 0.75, 0.9]

    implicitWidth: 190
    implicitHeight: 96
    Layout.fillWidth: true
    Layout.preferredHeight: 96
    Layout.minimumWidth: 150

    radius: 10
    color: mouseArea.containsMouse ? "#0F172A" : "#0C1322"
    border.color: mouseArea.containsMouse ? Theme.accentPrimary : "#1E293B"
    border.width: 1

    Behavior on color { ColorAnimation { duration: 180 } }
    Behavior on border.color { ColorAnimation { duration: 180 } }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 4

        // Top Row: [ICON]  Title
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // 4K PNG transparent icon from assets/branding/image.png
            Item {
                width: 26
                height: 26
                Layout.alignment: Qt.AlignVCenter

                Image {
                    id: imgIcon
                    visible: root.iconSource !== ""
                    anchors.fill: parent
                    source: root.iconSource
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    asynchronous: true
                }

                IconDraw {
                    visible: root.iconSource === ""
                    anchors.centerIn: parent
                    iconName: root.iconName
                    iconColor: root.iconColor
                    iconSize: 18
                }
            }

            Text {
                text: root.title
                font.pixelSize: 12
                font.bold: false
                font.family: Theme.fontSans
                color: "#94A3B8"
                elide: Text.ElideRight
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }
        }

        // Bottom Row: Value & Trend (Left) + Sparkline (Right)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 1

                // Primary Value (White, bold, high contrast)
                Text {
                    text: root.value
                    font.pixelSize: 21
                    font.bold: true
                    font.family: Theme.fontMono
                    color: "#FFFFFF"
                }

                // Subtitle/Unit + Trend indicator
                RowLayout {
                    spacing: 6

                    Text {
                        visible: root.unit !== ""
                        text: root.unit
                        font.pixelSize: 11
                        font.family: Theme.fontSans
                        color: "#64748B"
                    }

                    Text {
                        visible: root.trendText !== ""
                        text: root.trendText
                        font.pixelSize: 11
                        font.bold: true
                        font.family: Theme.fontMono
                        color: root.isTrendPositive ? "#10B981" : "#EF4444"
                    }
                }
            }

            // Right: Smooth Sparkline Curve
            Canvas {
                id: sparkCanvas
                Layout.preferredWidth: 60
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

                    ctx.beginPath();
                    ctx.strokeStyle = root.sparkColor;
                    ctx.lineWidth = 2.0;
                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";

                    for (var i = 0; i < pts.length; i++) {
                        var px = i * step;
                        var py = h - (pts[i] * (h - 8)) - 4;
                        if (i === 0) {
                            ctx.moveTo(px, py);
                        } else {
                            var prevX = (i - 1) * step;
                            var prevY = h - (pts[i - 1] * (h - 8)) - 4;
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

                Component.onCompleted: requestPaint()
            }
        }
    }
}
