import QtQuick
import QtQuick.Layouts
import NexusNOC
import "../components"

Item {
    id: root
    clip: true

    implicitWidth: 1400
    implicitHeight: 245
    Layout.fillWidth: true
    Layout.preferredHeight: 245

    // Properties bound to C++ SystemMonitor with real live values
    property real cpuLoad: (typeof systemMonitor !== "undefined" && systemMonitor) ?
                               Math.round(systemMonitor.cpuLoad) : 0
    property real cpuTemp: (typeof systemMonitor !== "undefined" && systemMonitor) ?
                               Math.round(systemMonitor.cpuTemp) : 0

    property real ramPct: {
        if (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.ramTotalGb > 0) {
            return Math.round((systemMonitor.ramUsedGb / systemMonitor.ramTotalGb) * 100.0);
        }
        return 0;
    }

    property real storagePct: {
        if (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.storageTotalGb > 0) {
            return Math.round((systemMonitor.storageUsedGb / systemMonitor.storageTotalGb) * 100.0);
        }
        return 0;
    }

    // Historical buffers for mini sparklines (populated from live readings)
    property var cpuHistory: []
    property var ramHistory: []
    property var storageHistory: []
    property var tempHistory: []

    Component.onCompleted: {
        var ch = [];
        var rh = [];
        var sh = [];
        var th = [];
        for (var i = 0; i < 8; i++) {
            ch.push(root.cpuLoad);
            rh.push(root.ramPct);
            sh.push(root.storagePct);
            th.push(root.cpuTemp);
        }
        root.cpuHistory = ch;
        root.ramHistory = rh;
        root.storageHistory = sh;
        root.tempHistory = th;
    }

    // Live update timer for sparkline histories (fast 500ms real-time update)
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            updateHistories();
        }
    }

    function updateHistories() {
        // CPU
        var ch = root.cpuHistory.slice();
        if (ch.length >= 10) ch.shift();
        ch.push(root.cpuLoad);
        root.cpuHistory = ch;

        // RAM
        var rh = root.ramHistory.slice();
        if (rh.length >= 10) rh.shift();
        rh.push(root.ramPct);
        root.ramHistory = rh;

        // Storage
        var sh = root.storageHistory.slice();
        if (sh.length >= 10) sh.shift();
        sh.push(root.storagePct);
        root.storageHistory = sh;

        // Temp
        var th = root.tempHistory.slice();
        if (th.length >= 10) th.shift();
        th.push(root.cpuTemp);
        root.tempHistory = th;
    }

    RowLayout {
        anchors.fill: parent
        spacing: 12

        // ==========================================
        // 1. NETWORK TRAFFIC PANEL (Large Left Chart)
        // ==========================================
        NetworkTrafficGraph {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 440
        }

        // ==========================================
        // 2. SYSTEM RESOURCES PANEL (4 Donut Gauges)
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 390
            radius: 10
            color: "#0F172A"
            border.color: "#1E293B"
            border.width: 1
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                // Header Row
                RowLayout {
                    Layout.fillWidth: true

                    RowLayout {
                        spacing: 8
                        Rectangle {
                            width: 7
                            height: 7
                            radius: 3.5
                            color: "#38BDF8"
                        }
                        Text {
                            text: "SYSTEM RESOURCES"
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
                            color: (root.cpuLoad > 85 || root.ramPct > 85) ? "#EF4444" :
                                   (root.cpuLoad > 70 || root.ramPct > 70) ? "#F59E0B" : "#10B981"
                        }
                        Text {
                            text: (root.cpuLoad > 85 || root.ramPct > 85) ? "Critical" :
                                  (root.cpuLoad > 70 || root.ramPct > 70) ? "Warning" : "Optimal"
                            font.pixelSize: 11
                            font.bold: true
                            color: (root.cpuLoad > 85 || root.ramPct > 85) ? "#EF4444" :
                                   (root.cpuLoad > 70 || root.ramPct > 70) ? "#F59E0B" : "#10B981"
                        }
                    }
                }

                // 4 Donut Gauges Row: CPU, RAM, STORAGE, TEMP
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8

                    // 1. CPU
                    ResourceGauge {
                        title: "CPU"
                        valueText: Math.round(root.cpuLoad) + "%"
                        percentage: root.cpuLoad / 100.0
                        subtext: (typeof systemMonitor !== "undefined" && systemMonitor) ?
                                     systemMonitor.cpuCores + " Cores" : "—"
                        gaugeColor: root.cpuLoad > 85 ? "#EF4444" :
                                    root.cpuLoad > 70 ? "#F59E0B" : "#10B981"
                        history: root.cpuHistory
                    }

                    // 2. RAM
                    ResourceGauge {
                        title: "RAM"
                        valueText: Math.round(root.ramPct) + "%"
                        percentage: root.ramPct / 100.0
                        subtext: (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.ramTotalGb > 0) ?
                                     systemMonitor.ramUsedGb.toFixed(1) + " / " + systemMonitor.ramTotalGb.toFixed(0) + " GB" : "—"
                        gaugeColor: root.ramPct > 85 ? "#EF4444" :
                                    root.ramPct > 70 ? "#F59E0B" : "#38BDF8"
                        history: root.ramHistory
                    }

                    // 3. STORAGE
                    ResourceGauge {
                        title: "STORAGE"
                        valueText: Math.round(root.storagePct) + "%"
                        percentage: root.storagePct / 100.0
                        subtext: (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.storageTotalGb > 0) ?
                                     systemMonitor.storageUsedGb.toFixed(0) + " / " + systemMonitor.storageTotalGb.toFixed(0) + " GB" : "—"
                        gaugeColor: root.storagePct > 90 ? "#EF4444" :
                                    root.storagePct > 75 ? "#F59E0B" : "#818CF8"
                        history: root.storageHistory
                    }

                    // 4. TEMPERATURE
                    ResourceGauge {
                        title: "TEMP"
                        valueText: Math.round(root.cpuTemp) + "°C"
                        percentage: Math.min(1.0, root.cpuTemp / 90.0)
                        subtext: root.cpuTemp === 0 ? "—" :
                                 (root.cpuTemp < 60 ? "Normal" : (root.cpuTemp < 75 ? "Warm" : "Critical"))
                        gaugeColor: root.cpuTemp > 75 ? "#EF4444" :
                                    root.cpuTemp > 60 ? "#F59E0B" : "#38BDF8"
                        history: root.tempHistory
                    }
                }
            }
        }

        // ==========================================
        // 3. INTERNET LATENCY PANEL (Right Chart)
        // ==========================================
        LatencyGraph {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 320
        }
    }
}
