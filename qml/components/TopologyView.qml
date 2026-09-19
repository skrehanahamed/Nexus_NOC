import QtQuick
import QtQuick.Layouts
import NexusNOC

Item {
    id: root
    clip: true

    property string coreIp: (typeof systemMonitor !== "undefined" && systemMonitor) ? systemMonitor.localIp : "192.168.1.159"
    property string gatewayIp: (typeof systemMonitor !== "undefined" && systemMonitor) ? systemMonitor.gatewayIp : "192.168.1.1"
    property real pulseProgress: 0.0

    signal deviceSelected(string deviceName)
    signal pageRequested(int pageIndex)

    readonly property bool isInternetOnline: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.internetConnected : true
    readonly property bool isWifiOnline: (typeof networkMonitor !== "undefined" && networkMonitor) ? networkMonitor.wifiConnected : true
    readonly property bool hasNetworkError: !isInternetOnline || !isWifiOnline

    NumberAnimation on pulseProgress {
        from: 0.0; to: 1.0; duration: 2500; loops: Animation.Infinite
        running: !root.hasNetworkError
    }

    onPulseProgressChanged: topoCanvas.requestPaint()

    Connections {
        target: (typeof networkMonitor !== "undefined") ? networkMonitor : null
        function onWifiChanged() { topoCanvas.requestPaint(); }
        function onLatencyChanged() { topoCanvas.requestPaint(); }
    }

    // Compute device type counts from deviceManager
    function getDeviceTypeCount(deviceType) {
        if (typeof deviceManager === "undefined" || !deviceManager || !deviceManager.devices) return 0;
        var devices = deviceManager.devices;
        var count = 0;
        for (var i = 0; i < devices.length; i++) {
            if (devices[i].type === deviceType) count++;
        }
        return count;
    }

    readonly property int laptopCount: (typeof deviceManager !== "undefined" && deviceManager && deviceManager.devices) ?
                                       Math.max(1, getDeviceTypeCount("Laptop")) : 1
    readonly property int phoneCount: (typeof deviceManager !== "undefined" && deviceManager && deviceManager.devices) ?
                                      Math.max(1, getDeviceTypeCount("Phone")) : 2
    readonly property int tvCount: (typeof deviceManager !== "undefined" && deviceManager && deviceManager.devices) ?
                                   getDeviceTypeCount("TV / Media") : 0
    readonly property int otherCount: (typeof deviceManager !== "undefined" && deviceManager && deviceManager.devices) ?
                                      Math.max(1, deviceManager.devices.length - laptopCount - phoneCount - tvCount) : 2
    readonly property int totalDeviceCount: (typeof deviceManager !== "undefined" && deviceManager && deviceManager.connectedDeviceCount > 0) ?
                                            deviceManager.connectedDeviceCount : (laptopCount + phoneCount + tvCount + otherCount)

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        // Diagram Area
        Item {
            id: diagramArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            readonly property real devWidth: Math.min(155, Math.max(130, width * 0.28))

            // Canvas for connection lines & animated packet pulses
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

                    var xInternet = w * 0.08;
                    var yCenter = h * 0.44;
                    var xRouter = w * 0.24;
                    var xNexus = w * 0.42;
                    var xDevices = w - 6 - diagramArea.devWidth;

                    // 1. Internet -> Router
                    ctx.beginPath();
                    ctx.setLineDash(root.isInternetOnline ? [4, 4] : [5, 5]);
                    ctx.moveTo(xInternet + 22, yCenter);
                    ctx.lineTo(xRouter - 22, yCenter);
                    ctx.strokeStyle = root.isInternetOnline ? "#10B981" : "#EF4444";
                    ctx.lineWidth = root.isInternetOnline ? 1.8 : 2.2;
                    ctx.stroke();
                    ctx.setLineDash([]);

                    if (root.isInternetOnline && !root.hasNetworkError) {
                        // Pulse on Internet -> Router
                        var p1X = (xInternet + 22) + ((xRouter - 22) - (xInternet + 22)) * root.pulseProgress;
                        ctx.beginPath();
                        ctx.arc(p1X, yCenter, 3.5, 0, 2 * Math.PI);
                        ctx.fillStyle = "#34D399";
                        ctx.fill();
                    } else if (!root.isInternetOnline) {
                        // Error Cross Badge on severed link
                        var midX1 = (xInternet + 22 + xRouter - 22) / 2;
                        ctx.beginPath();
                        ctx.arc(midX1, yCenter, 9, 0, 2 * Math.PI);
                        ctx.fillStyle = "#EF4444";
                        ctx.fill();
                        ctx.strokeStyle = "#FCA5A5";
                        ctx.lineWidth = 1.5;
                        ctx.stroke();

                        ctx.beginPath();
                        ctx.moveTo(midX1 - 3.5, yCenter - 3.5);
                        ctx.lineTo(midX1 + 3.5, yCenter + 3.5);
                        ctx.moveTo(midX1 + 3.5, yCenter - 3.5);
                        ctx.lineTo(midX1 - 3.5, yCenter + 3.5);
                        ctx.strokeStyle = "#FFFFFF";
                        ctx.lineWidth = 1.8;
                        ctx.stroke();
                    }

                    // 2. Router -> Host/NEXUS NOC
                    ctx.beginPath();
                    if (!root.isWifiOnline) ctx.setLineDash([5, 5]);
                    ctx.moveTo(xRouter + 22, yCenter);
                    ctx.lineTo(xNexus - 26, yCenter);
                    ctx.strokeStyle = root.isWifiOnline ? "#10B981" : "#EF4444";
                    ctx.lineWidth = root.isWifiOnline ? 2.0 : 2.2;
                    ctx.stroke();
                    ctx.setLineDash([]);

                    if (root.isWifiOnline && !root.hasNetworkError) {
                        // Pulse on Router -> NEXUS
                        var p2X = (xRouter + 22) + ((xNexus - 26) - (xRouter + 22)) * root.pulseProgress;
                        ctx.beginPath();
                        ctx.arc(p2X, yCenter, 3.5, 0, 2 * Math.PI);
                        ctx.fillStyle = "#6EE7B7";
                        ctx.fill();
                    } else if (!root.isWifiOnline) {
                        // Error Cross Badge on severed link
                        var midX2 = (xRouter + 22 + xNexus - 26) / 2;
                        ctx.beginPath();
                        ctx.arc(midX2, yCenter, 9, 0, 2 * Math.PI);
                        ctx.fillStyle = "#EF4444";
                        ctx.fill();
                        ctx.strokeStyle = "#FCA5A5";
                        ctx.lineWidth = 1.5;
                        ctx.stroke();

                        ctx.beginPath();
                        ctx.moveTo(midX2 - 3.5, yCenter - 3.5);
                        ctx.lineTo(midX2 + 3.5, yCenter + 3.5);
                        ctx.moveTo(midX2 + 3.5, yCenter - 3.5);
                        ctx.lineTo(midX2 - 3.5, yCenter + 3.5);
                        ctx.strokeStyle = "#FFFFFF";
                        ctx.lineWidth = 1.8;
                        ctx.stroke();
                    }

                    // 3. NEXUS -> Fan-out devices (dashed curves)
                    var devY = [h * 0.16, h * 0.37, h * 0.58, h * 0.79];
                    for (var i = 0; i < devY.length; i++) {
                        var dy = devY[i];
                        ctx.beginPath();
                        ctx.setLineDash([4, 4]);
                        ctx.moveTo(xNexus + 26, yCenter);
                        ctx.bezierCurveTo((xNexus + xDevices) / 2, yCenter, (xNexus + xDevices) / 2, dy, xDevices - 2, dy);
                        ctx.strokeStyle = root.isWifiOnline ? "#38BDF8" : "#475569";
                        ctx.lineWidth = 1.5;
                        ctx.stroke();
                        ctx.setLineDash([]);

                        // Connection dot
                        ctx.beginPath();
                        ctx.arc(xDevices, dy, 4.0, 0, 2 * Math.PI);
                        ctx.fillStyle = root.isWifiOnline ? "#10B981" : "#64748B";
                        ctx.fill();

                        if (root.isWifiOnline && !root.hasNetworkError) {
                            var t = (root.pulseProgress + (i * 0.25)) % 1.0;
                            var midX = (xNexus + xDevices) / 2;
                            var bx = Math.pow(1 - t, 3) * (xNexus + 26) + 3 * Math.pow(1 - t, 2) * t * midX + 3 * (1 - t) * Math.pow(t, 2) * midX + Math.pow(t, 3) * (xDevices - 2);
                            var byy = Math.pow(1 - t, 3) * yCenter + 3 * Math.pow(1 - t, 2) * t * yCenter + 3 * (1 - t) * Math.pow(t, 2) * dy + Math.pow(t, 3) * dy;
                            ctx.beginPath();
                            ctx.arc(bx, byy, 3, 0, 2 * Math.PI);
                            ctx.fillStyle = "#67E8F9";
                            ctx.fill();
                        }
                    }
                }
            }

            // Node 1: Internet
            Item {
                id: nodeInternet
                width: 64
                height: 68
                x: diagramArea.width * 0.08 - 32
                y: diagramArea.height * 0.44 - 22
                scale: inetMouse.pressed ? 0.95 : (inetMouse.containsMouse ? 1.06 : 1.0)
                Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutQuad } }

                Rectangle {
                    id: circleInternet
                    width: 44
                    height: 44
                    radius: 22
                    color: inetMouse.containsMouse ? "#0F284A" : (root.isInternetOnline ? "#0B1E38" : "#2A0E14")
                    border.color: inetMouse.containsMouse ? "#38BDF8" : (root.isInternetOnline ? "#38BDF8" : "#EF4444")
                    border.width: (root.isInternetOnline || inetMouse.containsMouse) ? 1.5 : 2.0
                    anchors.horizontalCenter: parent.horizontalCenter
                    Behavior on color { ColorAnimation { duration: 130 } }

                    Image {
                        source: "qrc:/qt/qml/NexusNOC/qml/assets/topo_globe.png"
                        width: 28
                        height: 28
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        opacity: root.isInternetOnline ? 1.0 : 0.4
                    }

                    // Error Cross Badge
                    Rectangle {
                        visible: !root.isInternetOnline
                        width: 14
                        height: 14
                        radius: 7
                        color: "#EF4444"
                        border.color: "#FFFFFF"
                        border.width: 1
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: -2
                        anchors.rightMargin: -2
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 8
                            font.bold: true
                            color: "#FFFFFF"
                        }
                    }
                }

                Text {
                    anchors.top: circleInternet.bottom
                    anchors.topMargin: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.isInternetOnline ? "Internet" : "Internet\nOffline"
                    font.pixelSize: 10
                    font.bold: true
                    color: inetMouse.containsMouse ? "#38BDF8" : (root.isInternetOnline ? Theme.textSecondary : "#EF4444")
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    id: inetMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.pageRequested(1);
                        root.deviceSelected("Internet");
                    }
                }
            }

            // Node 2: Router
            Item {
                id: nodeRouter
                width: 70
                height: 72
                x: diagramArea.width * 0.24 - 35
                y: diagramArea.height * 0.44 - 22
                scale: routerMouse.pressed ? 0.95 : (routerMouse.containsMouse ? 1.06 : 1.0)
                Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutQuad } }

                Rectangle {
                    id: circleRouter
                    width: 44
                    height: 44
                    radius: 22
                    color: routerMouse.containsMouse ? "#0F284A" : (root.isWifiOnline ? "#0B1E38" : "#2A0E14")
                    border.color: routerMouse.containsMouse ? "#38BDF8" : (root.isWifiOnline ? "#1E3A5F" : "#EF4444")
                    border.width: (root.isWifiOnline || routerMouse.containsMouse) ? 1.5 : 2.0
                    anchors.horizontalCenter: parent.horizontalCenter
                    Behavior on color { ColorAnimation { duration: 130 } }

                    Image {
                        source: "qrc:/qt/qml/NexusNOC/qml/assets/topo_router.png"
                        width: 28
                        height: 24
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        opacity: root.isWifiOnline ? 1.0 : 0.4
                    }

                    // Error Cross Badge
                    Rectangle {
                        visible: !root.isWifiOnline
                        width: 14
                        height: 14
                        radius: 7
                        color: "#EF4444"
                        border.color: "#FFFFFF"
                        border.width: 1
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: -2
                        anchors.rightMargin: -2
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 8
                            font.bold: true
                            color: "#FFFFFF"
                        }
                    }
                }

                Text {
                    anchors.top: circleRouter.bottom
                    anchors.topMargin: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.isWifiOnline ? ("Router\n" + root.gatewayIp) : "Router\nUnreachable"
                    font.pixelSize: 9
                    font.family: Theme.fontMono
                    color: routerMouse.containsMouse ? "#38BDF8" : (root.isWifiOnline ? Theme.textSecondary : "#EF4444")
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    id: routerMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.pageRequested(1);
                        root.deviceSelected("Router");
                    }
                }
            }

            // Node 3: Device Node with Device Hardware Logo on top and NEXUS NOC App Icon inside
            Item {
                id: nodeNexus
                width: 76
                height: 86
                x: diagramArea.width * 0.42 - 38
                y: diagramArea.height * 0.44 - 24
                scale: nexusMouse.pressed ? 0.95 : (nexusMouse.containsMouse ? 1.05 : 1.0)
                Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutQuad } }

                // Device Hardware Logo perched right on top (Apple logo on Mac, Raspberry Pi logo on Pi)
                Image {
                    id: deviceLogo
                    source: (typeof systemMonitor !== "undefined" && systemMonitor && (systemMonitor.deviceType === "apple" || systemMonitor.deviceName.indexOf("Mac") !== -1)) ?
                            "qrc:/qt/qml/NexusNOC/qml/assets/apple_logo_white.png" : "qrc:/qt/qml/NexusNOC/qml/assets/raspberry_pi_logo.png"
                    width: 15
                    height: 17
                    anchors.bottom: circleNexus.top
                    anchors.bottomMargin: 3
                    anchors.horizontalCenter: parent.horizontalCenter
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }

                Rectangle {
                    id: circleNexus
                    width: 48
                    height: 48
                    radius: 24
                    color: nexusMouse.containsMouse ? "#0C274A" : "#081B33"
                    border.color: "#38BDF8"
                    border.width: nexusMouse.containsMouse ? 2.5 : 2
                    anchors.horizontalCenter: parent.horizontalCenter

                    Behavior on color { ColorAnimation { duration: 130 } }
                    Behavior on border.width { NumberAnimation { duration: 130 } }

                    // Subtle pulsing halo
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: nexusMouse.containsMouse ? -5 : -3
                        radius: 27
                        color: "transparent"
                        border.color: nexusMouse.containsMouse ? Qt.rgba(56/255, 189/255, 248/255, 0.70) : Qt.rgba(56/255, 189/255, 248/255, 0.40)
                        border.width: 1
                        Behavior on anchors.margins { NumberAnimation { duration: 130 } }
                    }

                    // Official NEXUS NOC Application Icon
                    Image {
                        source: "qrc:/qt/qml/NexusNOC/qml/assets/icon_nexus_logo.png"
                        width: 30
                        height: 30
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }
                }

                Text {
                    anchors.top: circleNexus.bottom
                    anchors.topMargin: 5
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "NEXUS NOC\n" + root.coreIp
                    font.pixelSize: 10
                    font.family: Theme.fontMono
                    font.bold: true
                    color: nexusMouse.containsMouse ? "#38BDF8" : Theme.textPrimary
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    id: nexusMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.pageRequested(2);
                        root.deviceSelected("Host Appliance");
                    }
                }
            }

            // Right Fan-out Devices (4 rows) — Real counts from deviceManager
            Repeater {
                model: [
                    { icon: "qrc:/qt/qml/NexusNOC/qml/assets/topo_laptop.png", name: "Laptops (" + root.laptopCount + ")", yFrac: 0.16 },
                    { icon: "qrc:/qt/qml/NexusNOC/qml/assets/topo_phone.png", name: "Phones (" + root.phoneCount + ")", yFrac: 0.37 },
                    { icon: "qrc:/qt/qml/NexusNOC/qml/assets/topo_tv.png", name: "TV / Media (" + root.tvCount + ")", yFrac: 0.58 },
                    { icon: "qrc:/qt/qml/NexusNOC/qml/assets/topo_iot.png", name: "IoT Devices (" + root.otherCount + ")", yFrac: 0.79 }
                ]

                Rectangle {
                    x: diagramArea.width - diagramArea.devWidth - 4
                    y: diagramArea.height * modelData.yFrac - 14
                    width: diagramArea.devWidth
                    height: 28
                    radius: 6
                    color: devMouse.pressed ? "#1E3A5F" : (devMouse.containsMouse ? "#16253F" : "#0D1929")
                    border.color: devMouse.containsMouse ? "#38BDF8" : "#1B2F4C"
                    border.width: devMouse.containsMouse ? 1.5 : 1
                    scale: devMouse.pressed ? 0.95 : (devMouse.containsMouse ? 1.04 : 1.0)

                    Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutQuad } }
                    Behavior on color { ColorAnimation { duration: 130 } }
                    Behavior on border.color { ColorAnimation { duration: 130 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Image {
                            source: modelData.icon
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 16
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                        }

                        Text {
                            text: modelData.name
                            font.pixelSize: 11
                            font.bold: true
                            color: devMouse.containsMouse ? "#38BDF8" : Theme.textPrimary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "›"
                            font.pixelSize: 13
                            font.bold: true
                            color: devMouse.containsMouse ? "#38BDF8" : "#475569"
                        }
                    }

                    MouseArea {
                        id: devMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.pageRequested(2);
                            root.deviceSelected(modelData.name);
                        }
                    }
                }
            }
        }

        // Bottom Legend Row
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 12
            Layout.rightMargin: 12
            spacing: 16

            RowLayout {
                spacing: 5
                Rectangle { width: 7; height: 7; radius: 3.5; color: "#10B981" }
                Text { text: "Online"; font.pixelSize: 10; color: Theme.textMuted }
            }

            RowLayout {
                spacing: 5
                Rectangle { width: 7; height: 7; radius: 3.5; color: "#EF4444" }
                Text { text: "Offline"; font.pixelSize: 10; color: Theme.textMuted }
            }

            RowLayout {
                spacing: 5
                Rectangle { width: 14; height: 2; color: "#2563EB" }
                Text { text: "Connection"; font.pixelSize: 10; color: Theme.textMuted }
            }

            RowLayout {
                spacing: 5
                Rectangle { width: 14; height: 2; color: "#38BDF8" }
                Text { text: "Wireless"; font.pixelSize: 10; color: Theme.textMuted }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "Tap on a device for details"
                font.pixelSize: 10
                color: Theme.textDim
            }
        }
    }
}
