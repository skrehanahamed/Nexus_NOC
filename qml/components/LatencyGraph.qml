import QtQuick
import QtQuick.Layouts
import NexusNOC

Rectangle {
    id: root

    property color panelBg: "#0F172A"
    property color panelBorder: "#1E293B"

    property real latencyMs: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.latencyMs : 0.0
    property real jitterMs: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.jitterMs : 0.0
    property real packetLoss: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.packetLoss : 0.0

    readonly property int latencyBars: {
        if (packetLoss > 0 || latencyMs >= 150) return 1;
        if (latencyMs >= 90) return 2;
        if (latencyMs >= 45) return 3;
        return 4;
    }

    readonly property string statusText: {
        if (latencyBars === 4) return "OPTIMAL";
        if (latencyBars === 3) return "STABLE";
        if (latencyBars === 2) return "ELEVATED";
        return "DEGRADED";
    }

    readonly property color statusColor: {
        if (latencyBars >= 3) return "#10B981";
        if (latencyBars === 2) return "#F59E0B";
        return "#EF4444";
    }

    // Live latency history from backend
    property var history: (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.latencyHistory && networkMonitor.latencyHistory.length > 0) ?
                          networkMonitor.latencyHistory : []

    readonly property var timeLabels: ["30s", "20s", "10s", "Now"]

    color: panelBg
    border.color: panelBorder
    border.width: 1
    radius: 10
    clip: true

    implicitWidth: 340
    implicitHeight: 235
    Layout.fillWidth: true
    Layout.fillHeight: true

    // Smooth value interpolation
    Behavior on latencyMs {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }
    Behavior on jitterMs {
        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
    }

    // Continuous live pulse animation for real-time oscilloscope feedback
    property real pulsePhase: 0.0
    NumberAnimation on pulsePhase {
        from: 0.0; to: 1.0; duration: 1500; loops: Animation.Infinite; running: true
    }
    onPulsePhaseChanged: latencyCanvas.requestPaint()

    Connections {
        target: typeof networkMonitor !== "undefined" ? networkMonitor : null
        function onLatencyChanged() {
            root.latencyMs = networkMonitor.latencyMs;
            root.jitterMs = networkMonitor.jitterMs;
            root.packetLoss = networkMonitor.packetLoss;

            // Update rolling history buffer smoothly
            var currentHistory = root.history.slice();
            if (currentHistory.length >= 20) currentHistory.shift();
            currentHistory.push(networkMonitor.latencyMs);
            root.history = currentHistory;

            latencyCanvas.requestPaint();
        }
    }

    Component.onCompleted: {
        initHistory();
        latencyCanvas.requestPaint();
    }

    function initHistory() {
        var baseLat = (root.latencyMs > 0) ? root.latencyMs :
                      (typeof networkMonitor !== "undefined" && networkMonitor && networkMonitor.latencyMs > 0 ? networkMonitor.latencyMs : 16.8);
        var initial = [];
        for (var i = 0; i < 20; i++) {
            var subtleVar = Math.sin(i * 0.7) * 0.6;
            initial.push(Math.round((baseLat + subtleVar) * 10) / 10);
        }
        root.history = initial;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 8

        // 1. Header Row: Title & Quality Indicator
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            RowLayout {
                spacing: 7
                Rectangle {
                    width: 7
                    height: 7
                    radius: 3.5
                    color: root.statusColor
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { from: 1.0; to: 0.4; duration: 1200; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 0.4; to: 1.0; duration: 1200; easing.type: Easing.InOutQuad }
                    }
                }
                Text {
                    text: "INTERNET LATENCY"
                    font.pixelSize: 12
                    font.bold: true
                    font.letterSpacing: 1.2
                    font.family: Theme.fontFamily
                    color: "#F1F5F9"
                }
            }

            Item { Layout.fillWidth: true }

            // Simple, clean status indicator
            RowLayout {
                spacing: 5
                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: root.statusColor
                }
                Text {
                    text: root.latencyBars >= 3 ? "Stable" : (root.latencyBars === 2 ? "Warning" : "Critical")
                    font.pixelSize: 11
                    font.bold: true
                    color: root.statusColor
                }
            }
        }

        // 2. Metrics Readout: '18 ms', Jitter, Packet Loss
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Current Ping
            Text {
                text: root.latencyMs > 0 ? (root.latencyMs.toFixed(1) + " ms") : "—"
                font.pixelSize: 18
                font.bold: true
                font.family: Theme.fontMono
                color: root.statusColor
            }

            Item { Layout.fillWidth: true }

            // Jitter & Loss Badges
            RowLayout {
                spacing: 8

                RowLayout {
                    spacing: 4
                    Text { text: "Jitter"; font.pixelSize: 10; color: "#64748B" }
                    Text {
                        text: root.jitterMs.toFixed(1) + " ms"
                        font.pixelSize: 11
                        font.bold: true
                        font.family: Theme.fontMono
                        color: "#94A3B8"
                    }
                }

                Rectangle {
                    width: 1
                    height: 12
                    color: "#334155"
                }

                RowLayout {
                    spacing: 4
                    Text { text: "Loss"; font.pixelSize: 10; color: "#64748B" }
                    Text {
                        text: root.packetLoss.toFixed(0) + "%"
                        font.pixelSize: 11
                        font.bold: true
                        font.family: Theme.fontMono
                        color: root.packetLoss === 0 ? "#10B981" : "#EF4444"
                    }
                }
            }
        }

        // 3. Real-Time Latency Line Graph Canvas
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Canvas {
                id: latencyCanvas
                anchors.fill: parent
                renderTarget: Canvas.Image
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d");
                    var w = width;
                    var h = height;
                    ctx.clearRect(0, 0, w, h);
                    if (w <= 0 || h <= 0) return;

                    var leftMargin = 38;
                    var rightMargin = 10;
                    var topMargin = 12;
                    var bottomMargin = 18;
                    var plotW = w - leftMargin - rightMargin;
                    var plotH = h - topMargin - bottomMargin;

                    if (plotW <= 0 || plotH <= 0) return;

                    // Calculate max scale dynamically
                    var maxScale = 50.0;
                    var data = root.history;
                    for (var d = 0; d < data.length; d++) {
                        if (data[d] > maxScale * 0.8) {
                            maxScale = Math.ceil(data[d] / 25.0) * 25.0;
                        }
                    }

                    // 1. Grid Lines & Y-Axis Labels
                    var steps = 3;
                    ctx.strokeStyle = "#1A2438";
                    ctx.lineWidth = 1;
                    ctx.fillStyle = "#64748B";
                    ctx.font = "9px monospace, sans-serif";

                    for (var i = 0; i <= steps; i++) {
                        var y = topMargin + (plotH / steps) * i;
                        var val = Math.round(maxScale * (1.0 - (i / steps)));

                        ctx.beginPath();
                        ctx.moveTo(leftMargin, y);
                        ctx.lineTo(w - rightMargin, y);
                        ctx.stroke();

                        ctx.fillText(val + "ms", 2, y + 3);
                    }

                    var baselineY = topMargin + plotH;

                    // 2. Latency Curve & Gradient Area Fill (Smooth Spline)
                    if (data && data.length >= 2) {
                        var n = data.length;
                        var stepX = plotW / (n - 1);

                        var pts = [];
                        for (var p = 0; p < n; p++) {
                            var px = leftMargin + p * stepX;
                            var valPct = Math.max(0, Math.min(1.0, data[p] / maxScale));
                            var py = baselineY - (valPct * plotH);
                            pts.push({ x: px, y: py });
                        }

                        // Gradient Area Fill
                        ctx.beginPath();
                        ctx.moveTo(pts[0].x, baselineY);
                        ctx.lineTo(pts[0].x, pts[0].y);

                        for (var j = 0; j < n - 1; j++) {
                            var p0 = (j > 0) ? pts[j - 1] : pts[j];
                            var p1 = pts[j];
                            var p2 = pts[j + 1];
                            var p3 = (j < n - 2) ? pts[j + 2] : p2;

                            var cp1x = p1.x + (p2.x - p0.x) / 6;
                            var cp1y = p1.y + (p2.y - p0.y) / 6;
                            var cp2x = p2.x - (p3.x - p1.x) / 6;
                            var cp2y = p2.y - (p3.y - p1.y) / 6;

                            ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, p2.x, p2.y);
                        }
                        ctx.lineTo(pts[n - 1].x, baselineY);
                        ctx.closePath();

                        var grad = ctx.createLinearGradient(0, topMargin, 0, baselineY);
                        grad.addColorStop(0, "rgba(16, 185, 129, 0.28)");
                        grad.addColorStop(1, "rgba(16, 185, 129, 0.0)");
                        ctx.fillStyle = grad;
                        ctx.fill();

                        // Main Smooth Curve Stroke
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
                        ctx.strokeStyle = "#10B981";
                        ctx.lineWidth = 2;
                        ctx.stroke();

                        // Glow dot and live radar pulse on latest point
                        var lastPt = pts[n - 1];
                        ctx.beginPath();
                        ctx.arc(lastPt.x, lastPt.y, 3.5, 0, 2 * Math.PI);
                        ctx.fillStyle = root.statusColor;
                        ctx.fill();

                        // Expanding live radar pulse ring
                        var rippleR = 3.5 + (root.pulsePhase * 7.5);
                        var rippleAlpha = (1.0 - root.pulsePhase) * 0.65;
                        ctx.beginPath();
                        ctx.arc(lastPt.x, lastPt.y, rippleR, 0, 2 * Math.PI);
                        ctx.strokeStyle = root.statusColor;
                        ctx.globalAlpha = rippleAlpha;
                        ctx.lineWidth = 1.2;
                        ctx.stroke();
                        ctx.globalAlpha = 1.0;
                    }

                    // 3. Time-Based X-Axis Labels
                    ctx.fillStyle = "#64748B";
                    ctx.font = "9px monospace, sans-serif";
                    var xLabels = root.timeLabels;
                    for (var t = 0; t < xLabels.length; t++) {
                        var tx = leftMargin + (plotW / (xLabels.length - 1)) * t;
                        var textW = ctx.measureText(xLabels[t]).width;
                        var drawX = Math.max(leftMargin, Math.min(w - rightMargin - textW, tx - (textW / 2)));
                        ctx.fillText(xLabels[t], drawX, h - 2);
                    }
                }
            }
        }
    }
}
