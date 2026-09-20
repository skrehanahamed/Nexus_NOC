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

    property real downloadMbps: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.rxRateMbps : 86.4
    property real uploadMbps: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.txRateMbps : 32.1

    property var dlHistory: (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.trafficHistoryDl) ? networkMonitor.trafficHistoryDl : []
    property var ulHistory: (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.trafficHistoryUl) ? networkMonitor.trafficHistoryUl : []

    readonly property var timeLabels: ["13:10", "13:12", "13:14", "13:16", "13:18", "13:20"]
    readonly property var yLabels: ["200 Mbps", "150 Mbps", "100 Mbps", "50 Mbps", "0 Mbps"]

    color: "#0C1322"
    border.color: "#1E293B"
    border.width: 1
    radius: 10
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        // Header Row: Title & Dual Legends
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            IconDraw {
                iconName: "network"
                iconColor: Theme.accentCyan
                iconSize: 16
            }

            Text {
                text: "Network Traffic"
                font.pixelSize: 14
                font.bold: true
                font.family: Theme.fontSans
                color: Theme.textPrimary
            }

            Item { Layout.fillWidth: true }

            // Download Legend (Green)
            RowLayout {
                spacing: 4
                Text {
                    text: "↓"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#00E676"
                }
                Text {
                    text: root.downloadMbps.toFixed(1) + " Mbps"
                    font.pixelSize: 12
                    font.bold: true
                    font.family: Theme.fontMono
                    color: "#00E676"
                }
            }

            Item { width: 8 }

            // Upload Legend (Blue)
            RowLayout {
                spacing: 4
                Text {
                    text: "↑"
                    font.pixelSize: 12
                    font.bold: true
                    color: "#38BDF8"
                }
                Text {
                    text: root.uploadMbps.toFixed(1) + " Mbps"
                    font.pixelSize: 12
                    font.bold: true
                    font.family: Theme.fontMono
                    color: "#38BDF8"
                }
            }
        }

        // Graph Canvas with Y and X Axes
        Item {
            id: graphArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Y-Axis Labels
            Column {
                id: yAxisCol
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: xAxisRow.top
                anchors.bottomMargin: 4
                width: 60
                spacing: (height - 5 * 12) / 4

                Repeater {
                    model: root.yLabels
                    Text {
                        text: modelData
                        font.pixelSize: 9
                        font.family: Theme.fontMono
                        color: Theme.textMuted
                    }
                }
            }

            // Main Waveform Canvas
            Canvas {
                id: waveCanvas
                anchors.left: yAxisCol.right
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: xAxisRow.top
                anchors.bottomMargin: 4
                renderTarget: Canvas.Image
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d");
                    var w = width;
                    var h = height;
                    ctx.clearRect(0, 0, w, h);
                    if (w <= 0 || h <= 0) return;

                    // 1. Grid horizontal lines
                    ctx.lineWidth = 1;
                    ctx.strokeStyle = "#162238";
                    for (var gi = 0; gi <= 4; gi++) {
                        var gy = gi * (h / 4);
                        ctx.beginPath();
                        ctx.moveTo(0, gy);
                        ctx.lineTo(w, gy);
                        ctx.stroke();
                    }

                    // Data buffers
                    var dl = root.dlHistory;
                    var ul = root.ulHistory;
                    var count = (dl && dl.length > 1) ? dl.length : 20;
                    var step = w / (count - 1);
                    var maxScale = 200.0;

                    // Helper to draw smooth bezier line and fill
                    function drawWave(data, strokeColor, fillColor) {
                        if (!data || data.length < 2) return;

                        // Path for fill
                        ctx.beginPath();
                        ctx.moveTo(0, h);

                        for (var i = 0; i < data.length; i++) {
                            var val = typeof data[i] === "number" ? data[i] : parseFloat(data[i]);
                            var px = i * step;
                            var py = h - Math.min(h, Math.max(0, (val / maxScale) * h));

                            if (i === 0) {
                                ctx.lineTo(px, py);
                            } else {
                                var prevX = (i - 1) * step;
                                var prevVal = typeof data[i-1] === "number" ? data[i-1] : parseFloat(data[i-1]);
                                var prevY = h - Math.min(h, Math.max(0, (prevVal / maxScale) * h));
                                var cpx = (prevX + px) * 0.5;
                                ctx.bezierCurveTo(cpx, prevY, cpx, py, px, py);
                            }
                        }

                        ctx.lineTo(w, h);
                        ctx.closePath();

                        var grad = ctx.createLinearGradient(0, 0, 0, h);
                        grad.addColorStop(0, fillColor);
                        grad.addColorStop(1, "transparent");
                        ctx.fillStyle = grad;
                        ctx.fill();

                        // Stroke outline
                        ctx.beginPath();
                        for (var j = 0; j < data.length; j++) {
                            var sval = typeof data[j] === "number" ? data[j] : parseFloat(data[j]);
                            var sx = j * step;
                            var sy = h - Math.min(h, Math.max(0, (sval / maxScale) * h));
                            if (j === 0) {
                                ctx.moveTo(sx, sy);
                            } else {
                                var sprevX = (j - 1) * step;
                                var sprevVal = typeof data[j-1] === "number" ? data[j-1] : parseFloat(data[j-1]);
                                var sprevY = h - Math.min(h, Math.max(0, (sprevVal / maxScale) * h));
                                var scpx = (sprevX + sx) * 0.5;
                                ctx.bezierCurveTo(scpx, sprevY, scpx, sy, sx, sy);
                            }
                        }
                        ctx.strokeStyle = strokeColor;
                        ctx.lineWidth = 2.0;
                        ctx.stroke();
                    }

                    // Draw Download curve (Green)
                    drawWave(dl, "#00E676", "rgba(0, 230, 118, 0.22)");

                    // Draw Upload curve (Blue)
                    drawWave(ul, "#38BDF8", "rgba(56, 189, 248, 0.20)");
                }

                Connections {
                    target: root
                    function onDlHistoryChanged() { waveCanvas.requestPaint(); }
                    function onUlHistoryChanged() { waveCanvas.requestPaint(); }
                    function onDownloadMbpsChanged() { waveCanvas.requestPaint(); }
                    function onUploadMbpsChanged() { waveCanvas.requestPaint(); }
                }
            }

            // X-Axis Time Labels
            Row {
                id: xAxisRow
                anchors.left: yAxisCol.right
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                spacing: (width - root.timeLabels.length * 36) / (root.timeLabels.length - 1)

                Repeater {
                    model: root.timeLabels
                    Text {
                        text: modelData
                        font.pixelSize: 9
                        font.family: Theme.fontMono
                        color: Theme.textMuted
                    }
                }
            }
        }
    }
}
