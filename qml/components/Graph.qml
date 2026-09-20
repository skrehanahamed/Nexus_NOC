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

    property string title: "BANDWIDTH THROUGHPUT"
    property real currentDownload: 384.5 // Mbps
    property real currentUpload: 42.8    // Mbps
    property real maxBandwidth: 1000.0   // 1 Gbps max scale
    property var downloadHistory: []
    property var uploadHistory: []
    readonly property int maxDataPoints: 40

    // Component initialization
    Component.onCompleted: {
        var dl = [];
        var ul = [];
        for (var i = 0; i < maxDataPoints; i++) {
            var baseDl = 280 + Math.sin(i * 0.3) * 80 + (Math.random() * 60 - 30);
            var baseUl = 35 + Math.cos(i * 0.2) * 15 + (Math.random() * 10 - 5);
            dl.push(Math.max(10, baseDl));
            ul.push(Math.max(5, baseUl));
        }
        downloadHistory = dl;
        uploadHistory = ul;
        graphCanvas.requestPaint();
    }

    // Live update simulation timer (ticks every 1s)
    Timer {
        id: liveTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            // Generate realistic jittered network traffic
            var nextDl = Math.max(80, Math.min(850, root.currentDownload + (Math.random() * 90 - 45)));
            var nextUl = Math.max(10, Math.min(180, root.currentUpload + (Math.random() * 20 - 10)));
            root.currentDownload = parseFloat(nextDl.toFixed(1));
            root.currentUpload = parseFloat(nextUl.toFixed(1));

            var newDl = root.downloadHistory.slice(1);
            newDl.push(nextDl);
            root.downloadHistory = newDl;

            var newUl = root.uploadHistory.slice(1);
            newUl.push(nextUl);
            root.uploadHistory = newUl;

            graphCanvas.requestPaint();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Graph Header with Live Values and Legend
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            // Download Stat
            RowLayout {
                spacing: 8
                Rectangle {
                    width: 10
                    height: 10
                    radius: 2
                    color: Theme.accentCyan
                }
                Text {
                    text: "RX (DL):"
                    font.pixelSize: Theme.fontCaption
                    font.bold: true
                    font.family: Theme.fontSans
                    color: Theme.textSecondary
                }
                Text {
                    text: root.currentDownload + " Mbps"
                    font.pixelSize: Theme.fontHeader
                    font.bold: true
                    font.family: Theme.fontMono
                    color: Theme.accentCyan
                }
            }

            // Upload Stat
            RowLayout {
                spacing: 8
                Rectangle {
                    width: 10
                    height: 10
                    radius: 2
                    color: Theme.accentPurple
                }
                Text {
                    text: "TX (UL):"
                    font.pixelSize: Theme.fontCaption
                    font.bold: true
                    font.family: Theme.fontSans
                    color: Theme.textSecondary
                }
                Text {
                    text: root.currentUpload + " Mbps"
                    font.pixelSize: Theme.fontHeader
                    font.bold: true
                    font.family: Theme.fontMono
                    color: Theme.accentPurple
                }
            }

            Item { Layout.fillWidth: true }

            // Peak Indicator
            Text {
                text: "SCALE: 1 Gbps | INTERFACE: eth0"
                font.pixelSize: Theme.fontSmall
                font.family: Theme.fontMono
                color: Theme.textMuted
            }
        }

        // Canvas Area for Live Dual Graph
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.bgInput
            radius: Theme.radiusSmall
            border.color: Theme.borderSubtle
            clip: true

            Canvas {
                id: graphCanvas
                anchors.fill: parent
                anchors.margins: 4
                renderTarget: Canvas.Image
                renderStrategy: Canvas.Threaded

                onPaint: {
                    var ctx = getContext("2d");
                    var w = width;
                    var h = height;

                    ctx.clearRect(0, 0, w, h);

                    if (w <= 0 || h <= 0) return;

                    // Draw Horizontal Grid Lines
                    ctx.strokeStyle = "#1A2233";
                    ctx.lineWidth = 1;
                    var gridSteps = 4;
                    for (var g = 1; g <= gridSteps; g++) {
                        var y = (h / gridSteps) * g;
                        ctx.beginPath();
                        ctx.moveTo(0, y);
                        ctx.lineTo(w, y);
                        ctx.stroke();

                        // Label
                        var val = Math.round(root.maxBandwidth * (1.0 - g / gridSteps));
                        if (val > 0) {
                            ctx.fillStyle = "#4B5568";
                            ctx.font = "10px Helvetica, Arial";
                            ctx.fillText(val + "M", 6, y - 4);
                        }
                    }

                    // Helper to draw filled spline
                    function drawStream(data, strokeColor, fillColor) {
                        if (!data || data.length < 2) return;
                        var step = w / (data.length - 1);

                        // Gradient fill
                        var grad = ctx.createLinearGradient(0, 0, 0, h);
                        grad.addColorStop(0, fillColor);
                        grad.addColorStop(1, "rgba(11, 14, 20, 0.0)");

                        ctx.beginPath();
                        ctx.moveTo(0, h);

                        for (var i = 0; i < data.length; i++) {
                            var px = i * step;
                            var py = h - (data[i] / root.maxBandwidth) * h;
                            py = Math.max(0, Math.min(h, py));
                            if (i === 0) {
                                ctx.lineTo(px, py);
                            } else {
                                var prevX = (i - 1) * step;
                                var prevY = h - (data[i - 1] / root.maxBandwidth) * h;
                                var cpx1 = prevX + (px - prevX) / 2;
                                var cpy1 = prevY;
                                var cpx2 = prevX + (px - prevX) / 2;
                                var cpy2 = py;
                                ctx.bezierCurveTo(cpx1, cpy1, cpx2, cpy2, px, py);
                            }
                        }

                        ctx.lineTo(w, h);
                        ctx.closePath();
                        ctx.fillStyle = grad;
                        ctx.fill();

                        // Stroke line
                        ctx.beginPath();
                        for (var j = 0; j < data.length; j++) {
                            var sx = j * step;
                            var sy = h - (data[j] / root.maxBandwidth) * h;
                            sy = Math.max(0, Math.min(h, sy));
                            if (j === 0) {
                                ctx.moveTo(sx, sy);
                            } else {
                                var psx = (j - 1) * step;
                                var psy = h - (data[j - 1] / root.maxBandwidth) * h;
                                var csx1 = psx + (sx - psx) / 2;
                                var csy1 = psy;
                                var csx2 = psx + (sx - psx) / 2;
                                var csy2 = sy;
                                ctx.bezierCurveTo(csx1, csy1, csx2, csy2, sx, sy);
                            }
                        }
                        ctx.strokeStyle = strokeColor;
                        ctx.lineWidth = 2;
                        ctx.stroke();
                    }

                    // Draw Download (Cyan)
                    drawStream(root.downloadHistory, "#06B6D4", "rgba(6, 182, 212, 0.25)");

                    // Draw Upload (Purple)
                    drawStream(root.uploadHistory, "#8B5CF6", "rgba(139, 92, 246, 0.20)");
                }
            }
        }
    }
}
