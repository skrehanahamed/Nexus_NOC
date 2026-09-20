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
import QtQuick.Controls
import NexusNOC

Rectangle {
    id: root

    signal deviceSelected(var device)

    property bool autoLayoutActive: true
    property var selectedDevice: null
    property real pulsePhase: 0.0

    color: "#0C1322"
    border.color: "#1E293B"
    border.width: 1
    radius: 10
    clip: true

    NumberAnimation on pulsePhase {
        from: 0.0; to: 1.0; duration: 2500; loops: Animation.Infinite; running: true
    }

    onPulsePhaseChanged: topoCanvas.requestPaint()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            IconDraw {
                iconName: "wifi"
                iconColor: Theme.accentCyan
                iconSize: 18
            }

            Text {
                text: "Network Topology"
                font.pixelSize: 15
                font.bold: true
                font.family: Theme.fontSans
                color: Theme.textPrimary
            }

            Item { Layout.fillWidth: true }

            // Auto Layout Button
            Rectangle {
                height: 28
                implicitWidth: autoLayoutRow.implicitWidth + 20
                radius: 6
                color: root.autoLayoutActive ? Qt.rgba(0, 229, 255, 0.12) : "#131E33"
                border.color: root.autoLayoutActive ? Theme.accentCyan : "#1E2D4A"
                border.width: 1

                RowLayout {
                    id: autoLayoutRow
                    anchors.centerIn: parent
                    spacing: 6

                    IconDraw {
                        iconName: "overview"
                        iconColor: root.autoLayoutActive ? Theme.accentCyan : Theme.textSecondary
                        iconSize: 12
                    }

                    Text {
                        text: "Auto Layout"
                        font.pixelSize: 11
                        font.bold: true
                        font.family: Theme.fontSans
                        color: root.autoLayoutActive ? Theme.accentCyan : Theme.textSecondary
                    }

                    Text {
                        text: ">"
                        font.pixelSize: 11
                        font.bold: true
                        color: Theme.textMuted
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.autoLayoutActive = !root.autoLayoutActive;
                        topoCanvas.requestPaint();
                    }
                }
            }
        }

        // Interactive Topology Canvas Area
        Item {
            id: canvasArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // Canvas for tree lines and animated packet pulses
            Canvas {
                id: topoCanvas
                anchors.fill: parent
                renderTarget: Canvas.Image
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d");
                    var w = width;
                    var h = height;
                    ctx.clearRect(0, 0, w, h);
                    if (w <= 0 || h <= 0) return;

                    var cx = w * 0.42; // Center axis of tree
                    var yInternet = h * 0.12;
                    var yRouter = h * 0.32;
                    var yPi = h * 0.52;
                    var yClients = h * 0.82;
                    var xServer = w * 0.80;
                    var yServer = h * 0.45;

                    ctx.lineWidth = 1.5;

                    // 1. Internet -> Router
                    ctx.strokeStyle = "#00E5FF";
                    ctx.setLineDash([4, 4]);
                    ctx.beginPath();
                    ctx.moveTo(cx, yInternet + 16);
                    ctx.lineTo(cx, yRouter - 16);
                    ctx.stroke();

                    // Pulse packet
                    var p1y = (yInternet + 16) + (yRouter - 32 - yInternet) * root.pulsePhase;
                    ctx.beginPath();
                    ctx.arc(cx, p1y, 3, 0, Math.PI * 2);
                    ctx.fillStyle = "#00E5FF";
                    ctx.fill();

                    // 2. Router -> Raspberry Pi
                    ctx.setLineDash([]);
                    ctx.strokeStyle = "#00E5FF";
                    ctx.beginPath();
                    ctx.moveTo(cx, yRouter + 16);
                    ctx.lineTo(cx, yPi - 18);
                    ctx.stroke();

                    // Pulse packet
                    var p2y = (yRouter + 16) + (yPi - 34 - yRouter) * root.pulsePhase;
                    ctx.beginPath();
                    ctx.arc(cx, p2y, 3, 0, Math.PI * 2);
                    ctx.fillStyle = "#10B981";
                    ctx.fill();

                    // 3. Raspberry Pi -> Server Rack (Dotted branch)
                    ctx.setLineDash([3, 3]);
                    ctx.strokeStyle = "#38BDF8";
                    ctx.beginPath();
                    ctx.moveTo(cx + 42, yPi);
                    ctx.lineTo(xServer, yPi);
                    ctx.lineTo(xServer, yServer + 20);
                    ctx.stroke();

                    // 4. Raspberry Pi -> 5 Client Devices (Solid tree bus)
                    ctx.setLineDash([]);
                    ctx.strokeStyle = "#0284C7";
                    ctx.beginPath();
                    ctx.moveTo(cx, yPi + 18);
                    ctx.lineTo(cx, h * 0.68);
                    ctx.stroke();

                    // Horizontal bus
                    var xStart = w * 0.10;
                    var xEnd = w * 0.74;
                    ctx.beginPath();
                    ctx.moveTo(xStart, h * 0.68);
                    ctx.lineTo(xEnd, h * 0.68);
                    ctx.stroke();

                    // Drops to each client
                    var clientCols = 5;
                    var spacing = (xEnd - xStart) / (clientCols - 1);
                    for (var i = 0; i < clientCols; i++) {
                        var devX = xStart + i * spacing;
                        ctx.beginPath();
                        ctx.moveTo(devX, h * 0.68);
                        ctx.lineTo(devX, yClients - 24);
                        ctx.stroke();

                        // Packet pulse down each branch
                        var pY = (h * 0.68) + ((yClients - 24) - (h * 0.68)) * ((root.pulsePhase + i * 0.2) % 1.0);
                        ctx.beginPath();
                        ctx.arc(devX, pY, 2.5, 0, Math.PI * 2);
                        ctx.fillStyle = "#00E5FF";
                        ctx.fill();
                    }
                }
            }

            // --- Top Node: Internet / Globe ---
            Rectangle {
                id: nodeInternet
                width: 48
                height: 48
                radius: 24
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -parent.width * 0.08
                anchors.top: parent.top
                anchors.topMargin: 4
                color: "#071B2F"
                border.color: "#00E5FF"
                border.width: 1.5

                Image {
                    anchors.fill: parent
                    anchors.margins: 4
                    source: "qrc:/qt/qml/NexusNOC/qml/assets/topo_globe.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                // Green Status Dot
                Rectangle {
                    width: 9; height: 9; radius: 4.5
                    color: Theme.statusSuccess
                    border.color: "#0C1322"; border.width: 1.5
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.deviceSelected({ name: "Internet WAN Gateway", ip: "1.1.1.1", type: "Gateway", connection: "Fiber WAN", status: "Online" })
                }
            }

            // --- Second Node: Router ---
            Rectangle {
                id: nodeRouter
                width: 52
                height: 38
                radius: 6
                anchors.horizontalCenter: nodeInternet.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.26
                color: "#0B192C"
                border.color: "#0284C7"
                border.width: 1

                Image {
                    anchors.fill: parent
                    anchors.margins: 4
                    source: "qrc:/qt/qml/NexusNOC/qml/assets/topo_router.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                Rectangle {
                    width: 9; height: 9; radius: 4.5
                    color: Theme.statusSuccess
                    border.color: "#0C1322"; border.width: 1.5
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.deviceSelected({ name: "Core Gateway Router", ip: "192.168.1.1", type: "Router", connection: "Gigabit Ethernet", status: "Online" })
                }
            }

            // --- Third Node: Raspberry Pi / NEXUS NOC ---
            Rectangle {
                id: nodePi
                width: 74
                height: 38
                radius: 19
                anchors.horizontalCenter: nodeInternet.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.48
                color: "#061A2D"
                border.color: "#00E5FF"
                border.width: 1.5

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Image {
                        width: 20
                        height: 20
                        source: "qrc:/qt/qml/NexusNOC/qml/assets/raspberry_pi_logo.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                }

                Rectangle {
                    width: 9; height: 9; radius: 4.5
                    color: Theme.statusSuccess
                    border.color: "#0C1322"; border.width: 1.5
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.deviceSelected({ name: "Raspberry Pi (NEXUS NOC Core)", ip: "192.168.1.159", type: "Appliance", connection: "Host Ethernet / Wi-Fi", status: "Online" })
                }
            }

            // --- Right Node: Server Rack ---
            Rectangle {
                id: nodeServer
                width: 44
                height: 44
                radius: 8
                x: parent.width * 0.80 - width * 0.5
                y: parent.height * 0.45 - height * 0.5
                color: "#091B2E"
                border.color: "#38BDF8"
                border.width: 1

                IconDraw {
                    anchors.centerIn: parent
                    iconName: "server"
                    iconColor: Theme.accentCyan
                    iconSize: 24
                }

                Rectangle {
                    width: 9; height: 9; radius: 4.5
                    color: Theme.statusSuccess
                    border.color: "#0C1322"; border.width: 1.5
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.deviceSelected({ name: "Enterprise Server Rack", ip: "192.168.1.200", type: "Server", connection: "Gigabit Ethernet", status: "Online" })
                }
            }

            // --- Bottom Client Nodes (Laptop, Phone, TV, Camera, Console) ---
            Row {
                anchors.horizontalCenter: nodeInternet.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                spacing: Math.max(14, (canvasArea.width * 0.64 - 5 * 46) / 4)

                // 1. Laptop (MacBook Air)
                Rectangle {
                    width: 46; height: 46; radius: 8
                    color: "#081829"; border.color: "#1E3A5F"; border.width: 1
                    Image {
                        anchors.fill: parent; anchors.margins: 4
                        source: "qrc:/qt/qml/NexusNOC/qml/assets/topo_laptop.png"
                        fillMode: Image.PreserveAspectFit; smooth: true
                    }
                    Rectangle {
                        width: 8; height: 8; radius: 4; color: Theme.statusSuccess
                        border.color: "#0C1322"; border.width: 1.5
                        anchors.bottom: parent.bottom; anchors.right: parent.right
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.deviceSelected({ name: "MacBook Air", ip: "192.168.1.45", mac: "F0:18:98:C2:55:10", type: "Laptop", connection: "Wi-Fi 6", status: "Online" })
                    }
                }

                // 2. iPhone / Phone
                Rectangle {
                    width: 46; height: 46; radius: 8
                    color: "#081829"; border.color: "#1E3A5F"; border.width: 1
                    Image {
                        anchors.fill: parent; anchors.margins: 4
                        source: "qrc:/qt/qml/NexusNOC/qml/assets/topo_phone.png"
                        fillMode: Image.PreserveAspectFit; smooth: true
                    }
                    Rectangle {
                        width: 8; height: 8; radius: 4; color: Theme.statusSuccess
                        border.color: "#0C1322"; border.width: 1.5
                        anchors.bottom: parent.bottom; anchors.right: parent.right
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.deviceSelected({ name: "iPhone 15 Pro", ip: "192.168.1.56", mac: "3C:06:30:4A:21:BC", type: "Phone", connection: "Wi-Fi 6", status: "Online" })
                    }
                }

                // 3. Samsung TV
                Rectangle {
                    width: 46; height: 46; radius: 8
                    color: "#081829"; border.color: "#1E3A5F"; border.width: 1
                    Image {
                        anchors.fill: parent; anchors.margins: 4
                        source: "qrc:/qt/qml/NexusNOC/qml/assets/topo_tv.png"
                        fillMode: Image.PreserveAspectFit; smooth: true
                    }
                    Rectangle {
                        width: 8; height: 8; radius: 4; color: Theme.statusSuccess
                        border.color: "#0C1322"; border.width: 1.5
                        anchors.bottom: parent.bottom; anchors.right: parent.right
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.deviceSelected({ name: "Samsung Smart TV", ip: "192.168.1.78", mac: "E4:58:B8:31:09:88", type: "TV", connection: "Wi-Fi 5", status: "Online" })
                    }
                }

                // 4. IP Camera
                Rectangle {
                    width: 46; height: 46; radius: 8
                    color: "#081829"; border.color: "#1E3A5F"; border.width: 1
                    IconDraw {
                        anchors.centerIn: parent
                        iconName: "camera"
                        iconColor: Theme.accentCyan
                        iconSize: 22
                    }
                    Rectangle {
                        width: 8; height: 8; radius: 4; color: Theme.statusSuccess
                        border.color: "#0C1322"; border.width: 1.5
                        anchors.bottom: parent.bottom; anchors.right: parent.right
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.deviceSelected({ name: "IP Security Camera", ip: "192.168.1.90", mac: "A0:92:08:74:33:41", type: "Camera", connection: "Wi-Fi", status: "Online" })
                    }
                }

                // 5. PlayStation / Console
                Rectangle {
                    width: 46; height: 46; radius: 8
                    color: "#081829"; border.color: "#1E3A5F"; border.width: 1
                    IconDraw {
                        anchors.centerIn: parent
                        iconName: "gamepad"
                        iconColor: Theme.accentCyan
                        iconSize: 22
                    }
                    Rectangle {
                        width: 8; height: 8; radius: 4; color: Theme.statusSuccess
                        border.color: "#0C1322"; border.width: 1.5
                        anchors.bottom: parent.bottom; anchors.right: parent.right
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.deviceSelected({ name: "PlayStation 5 Console", ip: "192.168.1.102", mac: "00:D9:D1:6C:5F:AA", type: "Console", connection: "Wi-Fi", status: "Online" })
                    }
                }
            }
        }
    }
}
