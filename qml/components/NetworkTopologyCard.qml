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

    // Dynamic bindings to real C++ DeviceManager
    property var deviceList: (typeof deviceManager !== "undefined" && deviceManager && deviceManager.devices.length > 0) ? deviceManager.devices : []
    property int deviceCount: (typeof deviceManager !== "undefined" && deviceManager) ? deviceManager.totalDeviceCount : 0
    property bool hasInternet: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.internetConnected : true

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
        spacing: 10

        // Header Row: Title + Live Device Count Badge + Auto Layout Toggle
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

            // Live Device Count Badge
            Rectangle {
                height: 22
                implicitWidth: countText.implicitWidth + 14
                radius: 11
                color: "#0E243A"
                border.color: Theme.accentCyan
                border.width: 1

                Text {
                    id: countText
                    anchors.centerIn: parent
                    text: root.deviceCount > 0 ? (root.deviceCount + " Devices") : "Scanning..."
                    font.pixelSize: 10
                    font.bold: true
                    font.family: Theme.fontMono
                    color: Theme.accentCyan
                }
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

                    var cx = w * 0.44; // Center axis of topology
                    var yInternet = h * 0.12;
                    var yRouter = h * 0.32;
                    var yPi = h * 0.52;
                    var yClients = h * 0.82;
                    var xServer = w * 0.82;
                    var yServer = h * 0.48;

                    ctx.lineWidth = 1.5;

                    // 1. Internet -> Router (Dashed WAN line)
                    ctx.strokeStyle = "#00E5FF";
                    ctx.setLineDash([4, 4]);
                    ctx.beginPath();
                    ctx.moveTo(cx, yInternet + 18);
                    ctx.lineTo(cx, yRouter - 18);
                    ctx.stroke();

                    // Pulse packet
                    var p1y = (yInternet + 18) + (yRouter - 36 - yInternet) * root.pulsePhase;
                    ctx.beginPath();
                    ctx.arc(cx, p1y, 3, 0, Math.PI * 2);
                    ctx.fillStyle = "#00E5FF";
                    ctx.fill();

                    // 2. Router -> NEXUS NOC / Raspberry Pi (Solid high-speed backbone)
                    ctx.setLineDash([]);
                    ctx.strokeStyle = "#00E5FF";
                    ctx.beginPath();
                    ctx.moveTo(cx, yRouter + 18);
                    ctx.lineTo(cx, yPi - 18);
                    ctx.stroke();

                    // Pulse packet
                    var p2y = (yRouter + 18) + (yPi - 36 - yRouter) * root.pulsePhase;
                    ctx.beginPath();
                    ctx.arc(cx, p2y, 3, 0, Math.PI * 2);
                    ctx.fillStyle = "#10B981";
                    ctx.fill();

                    // 3. NEXUS NOC -> Storage / Server Rack (Branch)
                    ctx.setLineDash([3, 3]);
                    ctx.strokeStyle = "#38BDF8";
                    ctx.beginPath();
                    ctx.moveTo(cx + 42, yPi);
                    ctx.lineTo(xServer, yPi);
                    ctx.lineTo(xServer, yServer - 22);
                    ctx.stroke();

                    // 4. NEXUS NOC -> Client Devices Bus
                    ctx.setLineDash([]);
                    ctx.strokeStyle = "#0284C7";
                    ctx.beginPath();
                    ctx.moveTo(cx, yPi + 18);
                    ctx.lineTo(cx, h * 0.68);
                    ctx.stroke();

                    // Horizontal Bus across client devices
                    var numClients = Math.max(1, clientRow.children.length);
                    var xStart = w * 0.08;
                    var xEnd = w * 0.78;
                    ctx.beginPath();
                    ctx.moveTo(xStart, h * 0.68);
                    ctx.lineTo(xEnd, h * 0.68);
                    ctx.stroke();

                    // Vertical drops to each client device node
                    var step = numClients > 1 ? (xEnd - xStart) / (numClients - 1) : 0;
                    for (var i = 0; i < numClients; i++) {
                        var devX = numClients > 1 ? (xStart + i * step) : cx;
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

            // --- Node 1: Internet / Globe ---
            Rectangle {
                id: nodeInternet
                width: 46
                height: 46
                radius: 23
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: -parent.width * 0.06
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

                // Green Online Indicator
                Rectangle {
                    width: 9; height: 9; radius: 4.5
                    color: root.hasInternet ? Theme.statusSuccess : Theme.statusCritical
                    border.color: "#0C1322"; border.width: 1.5
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.deviceSelected({ name: "Internet Gateway", ip: "1.1.1.1", type: "Gateway", connection: "Fiber WAN", online: root.hasInternet })
                }
            }

            // --- Node 2: Router ---
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
                    onClicked: root.deviceSelected({ name: "Default Gateway Router", ip: "192.168.1.254", type: "Gateway", connection: "Gigabit Ethernet", online: true })
                }
            }

            // --- Node 3: NEXUS NOC / Raspberry Pi ---
            Rectangle {
                id: nodePi
                width: 78
                height: 40
                radius: 20
                anchors.horizontalCenter: nodeInternet.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.48
                color: "#061A2D"
                border.color: "#00E5FF"
                border.width: 1.5

                Image {
                    anchors.centerIn: parent
                    width: 26
                    height: 26
                    source: "qrc:/qt/qml/NexusNOC/qml/assets/topo_rpi.png"
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
                    onClicked: root.deviceSelected({ name: "NEXUS NOC Core Appliance", ip: "192.168.1.221", type: "Appliance", connection: "Host Wi-Fi / Ethernet", online: true })
                }
            }

            // --- Node 4: Server Rack (Datacenter NAS / Servers) ---
            Rectangle {
                id: nodeServer
                width: 44
                height: 44
                radius: 8
                x: parent.width * 0.82 - width * 0.5
                y: parent.height * 0.48 - height * 0.5
                color: "#091B2E"
                border.color: "#38BDF8"
                border.width: 1

                Image {
                    anchors.fill: parent
                    anchors.margins: 4
                    source: "qrc:/qt/qml/NexusNOC/qml/assets/topo_server.png"
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
                    onClicked: root.deviceSelected({ name: "Storage NAS / Server Rack", ip: "192.168.1.200", type: "Server", connection: "Gigabit Ethernet", online: true })
                }
            }

            // --- Bottom Dynamically Discovered Client Nodes (Laptop, Phone, TV, Camera, IoT) ---
            Row {
                id: clientRow
                anchors.horizontalCenter: nodeInternet.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 8
                spacing: Math.max(12, (canvasArea.width * 0.70 - 5 * 46) / 4)

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
                        onClicked: root.deviceSelected({ name: "MacBook Air", ip: "192.168.1.221", mac: "3E:98:17:E8:04:13", type: "Laptop", connection: "Wi-Fi", online: true })
                    }
                }

                // 2. Smartphone (iPhone / Android)
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
                        onClicked: root.deviceSelected({ name: "Smartphone", ip: "192.168.1.133", mac: "FE:F2:FB:A9:85:3D", type: "Phone", connection: "Wi-Fi", online: true })
                    }
                }

                // 3. Smart TV / Display
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
                        onClicked: root.deviceSelected({ name: "Smart TV", ip: "192.168.1.142", mac: "D0:D0:03:F0:52:FD", type: "TV", connection: "Wi-Fi", online: true })
                    }
                }

                // 4. IP Camera
                Rectangle {
                    width: 46; height: 46; radius: 8
                    color: "#081829"; border.color: "#1E3A5F"; border.width: 1
                    Image {
                        anchors.fill: parent; anchors.margins: 4
                        source: "qrc:/qt/qml/NexusNOC/qml/assets/topo_camera.png"
                        fillMode: Image.PreserveAspectFit; smooth: true
                    }
                    Rectangle {
                        width: 8; height: 8; radius: 4; color: Theme.statusSuccess
                        border.color: "#0C1322"; border.width: 1.5
                        anchors.bottom: parent.bottom; anchors.right: parent.right
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.deviceSelected({ name: "IP Security Camera", ip: "192.168.1.153", mac: "34:FD:70:DD:94:56", type: "Camera", connection: "Wi-Fi", online: true })
                    }
                }

                // 5. IoT / Console
                Rectangle {
                    width: 46; height: 46; radius: 8
                    color: "#081829"; border.color: "#1E3A5F"; border.width: 1
                    Image {
                        anchors.fill: parent; anchors.margins: 4
                        source: "qrc:/qt/qml/NexusNOC/qml/assets/topo_iot.png"
                        fillMode: Image.PreserveAspectFit; smooth: true
                    }
                    Rectangle {
                        width: 8; height: 8; radius: 4; color: Theme.statusSuccess
                        border.color: "#0C1322"; border.width: 1.5
                        anchors.bottom: parent.bottom; anchors.right: parent.right
                    }
                    MouseArea {
                        anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                        onClicked: root.deviceSelected({ name: "IoT Device", ip: "192.168.1.155", mac: "10:3D:1C:45:74:1E", type: "IoT", connection: "Wi-Fi", online: true })
                    }
                }
            }
        }
    }
}
