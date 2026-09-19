import QtQuick
import QtQuick.Layouts
import NexusNOC

Rectangle {
    id: root
    clip: true

    property string title: "CPU"
    property string valueText: "32%"
    property real percentage: 0.32              // 0.0 to 1.0
    property real animatedPct: percentage
    property string subtext: "4 Cores"
    property color gaugeColor: "#10B981"
    property color trackColor: "#131F33"
    property var history: [22, 25, 24, 28, 30, 31, 29, 32]
    property string trendText: "Stable"
    property bool isPositive: true

    implicitWidth: 100
    implicitHeight: 165
    Layout.fillWidth: true
    Layout.fillHeight: true

    color: "transparent"

    Behavior on animatedPct {
        NumberAnimation { duration: 700; easing.type: Easing.OutCubic }
    }

    onPercentageChanged: root.animatedPct = root.percentage
    onAnimatedPctChanged: gaugeCanvas.requestPaint()
    onHistoryChanged: sparklineCanvas.requestPaint()

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        // 1. Donut / Circular Gauge Canvas
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 80
            Layout.preferredHeight: 80

            Canvas {
                id: gaugeCanvas
                anchors.fill: parent
                renderTarget: Canvas.Image
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d");
                    var w = width;
                    var h = height;
                    var cx = w / 2;
                    var cy = h / 2;
                    var radius = (Math.min(w, h) / 2) - 6;

                    ctx.clearRect(0, 0, w, h);

                    // 270-degree arc from 135deg (0.75 * PI) to 405deg (2.25 * PI)
                    var startAngle = Math.PI * 0.75;
                    var totalAngle = Math.PI * 1.5;
                    var endTrackAngle = startAngle + totalAngle;

                    // Background Track Arc
                    ctx.beginPath();
                    ctx.arc(cx, cy, radius, startAngle, endTrackAngle);
                    ctx.strokeStyle = root.trackColor;
                    ctx.lineWidth = 5.5;
                    ctx.lineCap = "round";
                    ctx.stroke();

                    // Active Progress Arc (Smoothly animated)
                    var pct = Math.max(0.02, Math.min(1.0, root.animatedPct));
                    var currentAngle = startAngle + (totalAngle * pct);

                    ctx.beginPath();
                    ctx.arc(cx, cy, radius, startAngle, currentAngle);
                    ctx.strokeStyle = root.gaugeColor;
                    ctx.lineWidth = 5.5;
                    ctx.lineCap = "round";
                    ctx.stroke();
                }
            }

            // Center Metric Value & Title
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 1

                Text {
                    text: root.valueText
                    font.pixelSize: 16
                    font.bold: true
                    font.family: Theme.fontMono
                    color: "#F1F5F9"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: root.title
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 0.8
                    font.family: Theme.fontFamily
                    color: "#94A3B8"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // 2. Trend Indicator & Mini Sparkline Graph
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 3

            Canvas {
                id: sparklineCanvas
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 72
                Layout.preferredHeight: 18
                renderTarget: Canvas.Image
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d");
                    var w = width;
                    var h = height;
                    ctx.clearRect(0, 0, w, h);

                    var pts = root.history;
                    if (!pts || pts.length < 2) {
                        pts = [20, 24, 22, 26, 28, 25, 30, 32];
                    }

                    var minVal = pts[0];
                    var maxVal = pts[0];
                    for (var i = 0; i < pts.length; i++) {
                        if (pts[i] < minVal) minVal = pts[i];
                        if (pts[i] > maxVal) maxVal = pts[i];
                    }
                    if (maxVal === minVal) {
                        maxVal += 10;
                        minVal -= 10;
                    }
                    var range = maxVal - minVal;

                    var n = pts.length;
                    var stepX = w / (n - 1);

                    var coords = [];
                    for (var m = 0; m < n; m++) {
                        var px = m * stepX;
                        var py = h - 2 - ((pts[m] - minVal) / range) * (h - 6);
                        coords.push({ x: px, y: py });
                    }

                    // Area fill under smooth trend line
                    var grad = ctx.createLinearGradient(0, 0, 0, h);
                    grad.addColorStop(0, Qt.rgba(root.gaugeColor.r, root.gaugeColor.g, root.gaugeColor.b, 0.28));
                    grad.addColorStop(1, Qt.rgba(root.gaugeColor.r, root.gaugeColor.g, root.gaugeColor.b, 0.0));

                    ctx.beginPath();
                    ctx.moveTo(0, h);
                    ctx.lineTo(coords[0].x, coords[0].y);

                    for (var j = 0; j < n - 1; j++) {
                        var p0 = (j > 0) ? coords[j - 1] : coords[j];
                        var p1 = coords[j];
                        var p2 = coords[j + 1];
                        var p3 = (j < n - 2) ? coords[j + 2] : p2;

                        var cp1x = p1.x + (p2.x - p0.x) / 6;
                        var cp1y = p1.y + (p2.y - p0.y) / 6;
                        var cp2x = p2.x - (p3.x - p1.x) / 6;
                        var cp2y = p2.y - (p3.y - p1.y) / 6;

                        ctx.bezierCurveTo(cp1x, cp1y, cp2x, cp2y, p2.x, p2.y);
                    }
                    ctx.lineTo(coords[n - 1].x, h);
                    ctx.closePath();
                    ctx.fillStyle = grad;
                    ctx.fill();

                    // Smooth Stroke line
                    ctx.beginPath();
                    ctx.moveTo(coords[0].x, coords[0].y);
                    for (var k = 0; k < n - 1; k++) {
                        var q0 = (k > 0) ? coords[k - 1] : coords[k];
                        var q1 = coords[k];
                        var q2 = coords[k + 1];
                        var q3 = (k < n - 2) ? coords[k + 2] : q2;

                        var c1x = q1.x + (q2.x - q0.x) / 6;
                        var c1y = q1.y + (q2.y - q0.y) / 6;
                        var c2x = q2.x - (q3.x - q1.x) / 6;
                        var c2y = q2.y - (q3.y - q1.y) / 6;

                        ctx.bezierCurveTo(c1x, c1y, c2x, c2y, q2.x, q2.y);
                    }
                    ctx.strokeStyle = root.gaugeColor;
                    ctx.lineWidth = 1.5;
                    ctx.stroke();
                }
            }

            // Subtext detail e.g. "4 Cores", "18.2 / 32 GB", "48°C Normal"
            Text {
                text: root.subtext
                font.pixelSize: 10
                font.family: Theme.fontMono
                color: "#64748B"
                Layout.alignment: Qt.AlignHCenter
                elide: Text.ElideRight
            }
        }
    }
}
