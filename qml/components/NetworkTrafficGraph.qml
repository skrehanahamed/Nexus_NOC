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

    property color panelBg: "#0F172A"
    property color panelBorder: "#1E293B"

    // Live Metrics Properties bound to real C++ NetworkMonitor
    property real downloadMbps: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.rxRateMbps : 0.0
    property real uploadMbps: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.txRateMbps : 0.0

    // Live History buffers
    property var dlHistory: []
    property var ulHistory: []

    // Time Axis labels
    readonly property var timeLabels: ["60s", "45s", "30s", "15s", "Now"]

    color: panelBg
    border.color: panelBorder
    border.width: 1
    radius: 10
    clip: true

    implicitWidth: 500
    implicitHeight: 235
    Layout.fillWidth: true
    Layout.fillHeight: true

    // Smooth value interpolation
    Behavior on downloadMbps {
        NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
    }
    Behavior on uploadMbps {
        NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
    }

    // Continuous live pulse animation for real-time oscilloscope feedback
    property real pulsePhase: 0.0
    NumberAnimation on pulsePhase {
        from: 0.0; to: 1.0; duration: 1500; loops: Animation.Infinite; running: true
    }
    onPulsePhaseChanged: graphCanvas.requestPaint()

    // Refresh timer to paint live hardware throughput updates
    Timer {
        id: animTimer
        interval: 250
        running: true
        repeat: true
        onTriggered: {
            updateTrafficData();
        }
    }

    // Connect to C++ NetworkMonitor signals if available
    Connections {
        target: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor : null
        function onRatesChanged() {
            root.downloadMbps = networkMonitor.rxRateMbps;
            root.uploadMbps = networkMonitor.txRateMbps;
            updateTrafficData();
        }
        function onHistoryChanged() {
            if (networkMonitor.trafficHistoryDl && networkMonitor.trafficHistoryDl.length > 0) {
                root.dlHistory = networkMonitor.trafficHistoryDl;
                root.ulHistory = networkMonitor.trafficHistoryUl;
                graphCanvas.requestPaint();
            }
        }
    }

    Component.onCompleted: {
        initHistory();
        graphCanvas.requestPaint();
    }

    function initHistory() {
        var baseDl = root.downloadMbps > 0 ? root.downloadMbps : 0.5;
        var baseUl = root.uploadMbps > 0 ? root.uploadMbps : 0.4;
        var initialDl = [];
        var initialUl = [];
        for (var i = 0; i < 20; i++) {
            var phase = i / 20.0 * Math.PI * 2;
            var vDl = Math.max(0.1, baseDl + Math.sin(phase) * (baseDl * 0.25));
            var vUl = Math.max(0.1, baseUl + Math.cos(phase) * (baseUl * 0.25));
            initialDl.push(Math.round(vDl * 10) / 10);
            initialUl.push(Math.round(vUl * 10) / 10);
        }
        root.dlHistory = initialDl;
        root.ulHistory = initialUl;
    }

    function updateTrafficData() {
        var targetDl = (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.rxRateMbps : root.downloadMbps;
        var targetUl = (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.txRateMbps : root.uploadMbps;

        var newDl = root.dlHistory.slice();
        var newUl = root.ulHistory.slice();
        if (newDl.length >= 24) newDl.shift();
        if (newUl.length >= 24) newUl.shift();

        // Smooth moving step to eliminate jagged random spikes
        var prevDl = newDl.length > 0 ? newDl[newDl.length - 1] : targetDl;
        var prevUl = newUl.length > 0 ? newUl[newUl.length - 1] : targetUl;
        var nextDl = Math.round((prevDl * 0.4 + targetDl * 0.6) * 10) / 10;
        var nextUl = Math.round((prevUl * 0.4 + targetUl * 0.6) * 10) / 10;

        newDl.push(nextDl);
        newUl.push(nextUl);
        root.dlHistory = newDl;
        root.ulHistory = newUl;
        graphCanvas.requestPaint();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // Header Row: Title, Current Speeds, and Legend
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Title & NOC Status Pill
            RowLayout {
                spacing: 8
                Rectangle {
                    width: 7
                    height: 7
                    radius: 3.5
                    color: "#10B981"
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.4; duration: 1200; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 0.4; to: 1.0; duration: 1200; easing.type: Easing.InOutQuad }
                    }
                }

                Text {
                    text: "NETWORK TRAFFIC"
                    font.pixelSize: 12
                    font.bold: true
                    font.letterSpacing: 1.2
                    font.family: Theme.fontFamily
                    color: "#F1F5F9"
                }
            }

            Item { Layout.fillWidth: true }

            // Live Download Speed Badge & Legend
            RowLayout {
                spacing: 5
                Rectangle {
                    width: 6; height: 6; radius: 3
                    color: "#38BDF8"
                }
                Text {
                    text: "↓"
                    font.pixelSize: 11
                    font.bold: true
                    color: "#38BDF8"
                }
                Text {
                    text: root.downloadMbps.toFixed(1) + " Mbps"
                    font.pixelSize: 11
                    font.bold: true
                    font.family: Theme.fontMono
                    color: "#38BDF8"
                }
            }

            // Separator
            Rectangle {
                width: 1
                height: 12
                color: "#334155"
            }

            // Live Upload Speed Badge & Legend
            RowLayout {
                spacing: 5
                Rectangle {
                    width: 6; height: 6; radius: 3
                    color: "#818CF8"
                }
                Text {
                    text: "↑"
                    font.pixelSize: 11
                    font.bold: true
                    color: "#818CF8"
                }
                Text {
                    text: root.uploadMbps.toFixed(1) + " Mbps"
                    font.pixelSize: 11
                    font.bold: true
                    font.family: Theme.fontMono
                    color: "#818CF8"
                }
            }
        }

        // Live Real-Time Canvas Graph Area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Canvas {
                id: graphCanvas
                anchors.fill: parent
                renderTarget: Canvas.Image
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d");
                    var w = width;
                    var h = height;
                    ctx.clearRect(0, 0, w, h);
                    if (w <= 0 || h <= 0) return;

                    var leftMargin = 55;
                    var rightMargin = 12;
                    var topMargin = 12;
                    var bottomMargin = 20;
                    var plotW = w - leftMargin - rightMargin;
                    var plotH = h - topMargin - bottomMargin;

                    if (plotW <= 0 || plotH <= 0) return;

                    // Calculate max scale dynamically based on peak traffic
                    var maxVal = 10.0;
                    var allPts = root.dlHistory.concat(root.ulHistory);
                    for (var s = 0; s < allPts.length; s++) {
                        if (allPts[s] > maxVal) {
                            maxVal = allPts[s];
                        }
                    }
                    var maxScale = Math.max(10.0, Math.ceil((maxVal * 1.3) / 10.0) * 10.0);

                    // 1. Grid Lines & Y-Axis Labels
                    var steps = 4;
                    ctx.strokeStyle = "#1A2438";
                    ctx.lineWidth = 1;
                    ctx.fillStyle = "#64748B";
                    ctx.font = "10px monospace, sans-serif";

                    for (var i = 0; i <= steps; i++) {
                        var y = topMargin + (plotH / steps) * i;
                        var val = Math.round(maxScale * (1.0 - (i / steps)));

                        ctx.beginPath();
                        ctx.moveTo(leftMargin, y);
                        ctx.lineTo(w - rightMargin, y);
                        ctx.stroke();

                        var labelText = val + " Mbps";
                        ctx.fillText(labelText, 4, y + 3);
                    }

                    var baselineY = topMargin + plotH;

                    function renderSmoothAreaAndLine(dataPts, strokeCol, fillGrad, lineW) {
                        if (!dataPts || dataPts.length < 2) return;
                        var n = dataPts.length;
                        var step = plotW / (n - 1);

                        var pts = [];
                        for (var p = 0; p < n; p++) {
                            var px = leftMargin + p * step;
                            var valPct = Math.max(0, Math.min(1.0, dataPts[p] / maxScale));
                            var py = baselineY - (valPct * plotH);
                            pts.push({ x: px, y: py });
                        }

                        // Gradient Area Fill
                        ctx.beginPath();
                        ctx.moveTo(pts[0].x, baselineY);
                        ctx.lineTo(pts[0].x, pts[0].y);

                        for (var i = 0; i < n - 1; i++) {
                            var p0 = (i > 0) ? pts[i - 1] : pts[i];
                            var p1 = pts[i];
                            var p2 = pts[i + 1];
                            var p3 = (i < n - 2) ? pts[i + 2] : p2;

                            var cp1x = p1.x + (p2.x - p0.x) / 6;
                            var cp1y = p1.y + (p2.y - p0.y) / 6;
                            var cp2x = p2.x - (p3.x - p1.x) / 6;
                            var cp2y = p2.y - (p3.y - p1.y) / 6;

                            ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, p2.x, p2.y);
                        }

                        ctx.lineTo(pts[n - 1].x, baselineY);
                        ctx.closePath();
                        ctx.fillStyle = fillGrad;
                        ctx.fill();

                        // Smooth Line Stroke
                        ctx.beginPath();
                        ctx.moveTo(pts[0].x, pts[0].y);

                        for (var k = 0; k < n - 1; k++) {
                            var q0 = (k > 0) ? pts[k - 1] : pts[k];
                            var q1 = pts[k];
                            var q2 = pts[k + 1];
                            var q3 = (k < n - 2) ? pts[k + 2] : q2;

                            var c1x = q1.x + (q2.x - q0.x) / 6;
                            var c1y = q1.y + (q2.y - q0.y) / 6;
                            var c2x = q2.x - (q3.x - q1.x) / 6;
                            var c2y = q2.y - (q3.y - q1.y) / 6;

                            ctx.bezierCurveTo(c1x, c1y, c2x, c2y, q2.x, q2.y);
                        }
                        ctx.strokeStyle = strokeCol;
                        ctx.lineWidth = lineW;
                        ctx.stroke();

                        // Glow dot and live radar pulse on latest point
                        var lastPt = pts[n - 1];
                        ctx.beginPath();
                        ctx.arc(lastPt.x, lastPt.y, 3.5, 0, 2 * Math.PI);
                        ctx.fillStyle = strokeCol;
                        ctx.fill();

                        // Expanding live pulse ripple ring
                        var rippleR = 3.5 + (root.pulsePhase * 7.0);
                        var rippleAlpha = (1.0 - root.pulsePhase) * 0.6;
                        ctx.beginPath();
                        ctx.arc(lastPt.x, lastPt.y, rippleR, 0, 2 * Math.PI);
                        ctx.strokeStyle = strokeCol;
                        ctx.globalAlpha = rippleAlpha;
                        ctx.lineWidth = 1.2;
                        ctx.stroke();
                        ctx.globalAlpha = 1.0;
                    }

                    // 2. Download Curve (Cyan #38BDF8)
                    var dlGrad = ctx.createLinearGradient(0, topMargin, 0, baselineY);
                    dlGrad.addColorStop(0, "rgba(56, 189, 248, 0.28)");
                    dlGrad.addColorStop(0.7, "rgba(56, 189, 248, 0.08)");
                    dlGrad.addColorStop(1, "rgba(56, 189, 248, 0.0)");
                    renderSmoothAreaAndLine(root.dlHistory, "#38BDF8", dlGrad, 2.0);

                    // 3. Upload Curve (Violet #818CF8)
                    var ulGrad = ctx.createLinearGradient(0, topMargin, 0, baselineY);
                    ulGrad.addColorStop(0, "rgba(129, 140, 248, 0.20)");
                    ulGrad.addColorStop(1, "rgba(129, 140, 248, 0.0)");
                    renderSmoothAreaAndLine(root.ulHistory, "#818CF8", ulGrad, 1.8);
                }
            }

            // Time-based X-Axis Labels at the bottom
            RowLayout {
                anchors.left: parent.left
                anchors.leftMargin: 55
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.bottom: parent.bottom
                spacing: 0

                Repeater {
                    model: root.timeLabels
                    Text {
                        text: modelData
                        font.pixelSize: 9
                        font.family: Theme.fontMono
                        color: "#64748B"
                        horizontalAlignment: (index === 0) ? Text.AlignLeft :
                                             (index === root.timeLabels.length - 1) ? Text.AlignRight : Text.AlignHCenter
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
