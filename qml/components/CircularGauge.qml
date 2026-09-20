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

Item {
    id: root

    property string title: "CPU"
    property string valueText: "32%"
    property string subtext: "2.1 / 6.8 GHz"
    property real percentage: 0.32       // 0.0 to 1.0
    property color gaugeColor: "#10B981" // Green, Blue, Amber, or Red
    property color sparklineColor: gaugeColor

    onPercentageChanged: gaugeCanvas.requestPaint()

    implicitWidth: 100
    implicitHeight: 140

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        // Circular Gauge Canvas
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 84
            Layout.preferredHeight: 84

            Canvas {
                id: gaugeCanvas
                anchors.fill: parent
                renderTarget: Canvas.Image

                onPaint: {
                    var ctx = getContext("2d");
                    var w = width;
                    var h = height;
                    var cx = w / 2;
                    var cy = h / 2;
                    var radius = (Math.min(w, h) / 2) - 6;

                    ctx.clearRect(0, 0, w, h);

                    // Background Track Arc (270 degrees from 135 deg to 405 deg)
                    var startAngle = Math.PI * 0.75;
                    var totalAngle = Math.PI * 1.5;
                    var endTrackAngle = startAngle + totalAngle;

                    ctx.beginPath();
                    ctx.arc(cx, cy, radius, startAngle, endTrackAngle);
                    ctx.strokeStyle = "#1A2338";
                    ctx.lineWidth = 6;
                    ctx.lineCap = "round";
                    ctx.stroke();

                    // Progress Arc
                    var currentAngle = startAngle + (totalAngle * Math.max(0.02, Math.min(1.0, root.percentage)));
                    ctx.beginPath();
                    ctx.arc(cx, cy, radius, startAngle, currentAngle);
                    ctx.strokeStyle = root.gaugeColor;
                    ctx.lineWidth = 6;
                    ctx.lineCap = "round";
                    ctx.stroke();
                }
            }

            // Center Text: Value & Label
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 1

                Text {
                    text: root.valueText
                    font.pixelSize: 17
                    font.bold: true
                    font.family: Theme.fontMono
                    color: Theme.textPrimary
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: root.title
                    font.pixelSize: 10
                    font.bold: true
                    color: Theme.textSecondary
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // Bottom Mini Sparkline
        Canvas {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 64
            Layout.preferredHeight: 14
            renderTarget: Canvas.Image

            onPaint: {
                var ctx = getContext("2d");
                var w = width;
                var h = height;
                ctx.clearRect(0, 0, w, h);

                ctx.beginPath();
                ctx.moveTo(0, h * 0.8);
                ctx.lineTo(w * 0.2, h * 0.5);
                ctx.lineTo(w * 0.4, h * 0.7);
                ctx.lineTo(w * 0.6, h * 0.3);
                ctx.lineTo(w * 0.8, h * 0.6);
                ctx.lineTo(w, h * 0.4);
                ctx.strokeStyle = root.sparklineColor;
                ctx.lineWidth = 1.5;
                ctx.stroke();
            }
        }

        // Subtext / Details
        Text {
            text: root.subtext
            font.pixelSize: 10
            font.family: Theme.fontMono
            color: Theme.textMuted
            Layout.alignment: Qt.AlignHCenter
            elide: Text.ElideRight
        }
    }
}
