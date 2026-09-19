import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import NexusNOC
import "components"
import "navigation"
import "pages"

ApplicationWindow {
    id: appWindow
    width: Math.min(Theme.defaultWidth, (Screen.desktopAvailableWidth > 0 ? Screen.desktopAvailableWidth - 20 : Theme.defaultWidth))
    height: Math.min(Theme.defaultHeight, (Screen.desktopAvailableHeight > 0 ? Screen.desktopAvailableHeight - 40 : Theme.defaultHeight))
    minimumWidth: Theme.minWidth
    minimumHeight: Theme.minHeight
    visible: true
    title: "NEXUS NOC – Network Operations & Control Console"
    color: Theme.bgApp

    property string currentDateStr: ""
    property string currentTimeStr: ""
    property bool isExiting: false

    onClosing: function(close) {
        if (!isExiting) {
            close.accepted = false;
            goodbyeOverlay.startShutdown();
        }
    }

    Component.onCompleted: {
        updateDateTime();
    }

    function updateDateTime() {
        var now = new Date();
        var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
        var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        var dayName = days[now.getDay()];
        var mName = months[now.getMonth()];
        var d = now.getDate();
        var y = now.getFullYear();
        var hh = String(now.getHours()).padStart(2, '0');
        var mm = String(now.getMinutes()).padStart(2, '0');
        var ss = String(now.getSeconds()).padStart(2, '0');

        currentDateStr = dayName + ", " + d + " " + mName + " " + y;
        currentTimeStr = hh + ":" + mm + ":" + ss;
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: appWindow.updateDateTime()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // TOP HEADER BAR (MODERN FROSTED GLASS NOC APPLIANCE HEADER)
        Rectangle {
            id: headerBar
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            color: "#0B111E"

            // Multi-Layer Frosted Glass Background
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#172338" }
                GradientStop { position: 0.12; color: "#0F1A2D" }
                GradientStop { position: 0.88; color: "#0A1220" }
                GradientStop { position: 1.0; color: "#060A14" }
            }

            // Specular Top Highlight Edge (Gleam reflection)
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.18; color: Qt.rgba(56/255, 189/255, 248/255, 0.45) }
                    GradientStop { position: 0.50; color: Qt.rgba(255, 255, 255, 0.40) }
                    GradientStop { position: 0.82; color: Qt.rgba(56/255, 189/255, 248/255, 0.45) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // Glass Bottom Border
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: Qt.rgba(255, 255, 255, 0.08)
            }
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -1
                width: parent.width
                height: 1
                color: Qt.rgba(0, 0, 0, 0.6)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 36
                anchors.rightMargin: 20
                spacing: 14

                // Logo & Platform Branding
                RowLayout {
                    spacing: 14
                    Layout.alignment: Qt.AlignVCenter

                    Image {
                        id: appLogo
                        Layout.preferredHeight: 38
                        Layout.preferredWidth: 125
                        source: "qrc:/qt/qml/NexusNOC/qml/assets/logo.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    Rectangle {
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 28
                        color: Qt.rgba(255, 255, 255, 0.12)
                    }

                    Text {
                        text: "Real-Time Network & System Intelligence Platform"
                        font.pixelSize: 11
                        font.family: Theme.fontFamily
                        color: "#94A3B8"
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                Item { Layout.fillWidth: true }

                // Live Clock (Borderless, Transparent)
                RowLayout {
                    spacing: 9
                    Layout.alignment: Qt.AlignVCenter

                    Image {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        source: "qrc:/qt/qml/NexusNOC/qml/assets/icon_clock.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    ColumnLayout {
                        spacing: 1
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text: appWindow.currentDateStr !== "" ? appWindow.currentDateStr : "Tue, 16 Sep 2025"
                            font.pixelSize: 10
                            font.family: Theme.fontFamily
                            color: "#94A3B8"
                        }
                        Text {
                            text: appWindow.currentTimeStr !== "" ? appWindow.currentTimeStr : "23:42:17"
                            font.pixelSize: 13
                            font.bold: true
                            font.family: Theme.fontMono
                            color: "#F8FAFC"
                        }
                    }
                }

                // Subtle Vertical Divider
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 22
                    Layout.alignment: Qt.AlignVCenter
                    color: Qt.rgba(255, 255, 255, 0.12)
                }

                // System Uptime (Borderless, Transparent)
                RowLayout {
                    spacing: 9
                    Layout.alignment: Qt.AlignVCenter

                    Image {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        source: "qrc:/qt/qml/NexusNOC/qml/assets/icon_uptime.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    ColumnLayout {
                        spacing: 1
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            text: "System Uptime"
                            font.pixelSize: 10
                            font.family: Theme.fontFamily
                            color: "#64748B"
                        }
                        Text {
                            text: (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.uptimeFormatted)
                                  ? systemMonitor.uptimeFormatted
                                  : "5d 14h 32m"
                            font.pixelSize: 13
                            font.bold: true
                            font.family: Theme.fontMono
                            color: "#F8FAFC"
                        }
                    }
                }

                // Overall Health Status Pill (Soft green pill capsule)
                Rectangle {
                    Layout.preferredHeight: 34
                    Layout.preferredWidth: healthContent.implicitWidth + 24
                    Layout.alignment: Qt.AlignVCenter
                    radius: 17
                    color: Qt.rgba(16/255, 185/255, 129/255, 0.12)
                    border.color: Qt.rgba(16/255, 185/255, 129/255, 0.35)
                    border.width: 1

                    RowLayout {
                        id: healthContent
                        anchors.centerIn: parent
                        spacing: 8

                        Image {
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            source: "qrc:/qt/qml/NexusNOC/qml/assets/icon_status_check.png"
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                        }

                        Text {
                            text: "All Systems Operational"
                            font.pixelSize: 11
                            font.bold: true
                            font.family: Theme.fontFamily
                            color: "#10B981"
                        }
                    }
                }

                // Settings Button (Clean icon)
                Item {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    Layout.alignment: Qt.AlignVCenter

                    IconDraw {
                        anchors.centerIn: parent
                        iconName: "services"
                        iconSize: 19
                        iconColor: settingsBtnArea.containsMouse ? "#38BDF8" : "#94A3B8"
                    }

                    MouseArea {
                        id: settingsBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            pageStack.currentIndex = 8;
                            navSidebar.currentIndex = 8;
                        }
                    }
                }

                // Host Hardware Info (Borderless, Clean Text)
                ColumnLayout {
                    spacing: 1
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: (typeof systemMonitor !== "undefined" && systemMonitor && systemMonitor.deviceShortName)
                              ? systemMonitor.deviceShortName
                              : "NEXUS-Pi"
                        font.pixelSize: 11
                        font.bold: true
                        font.family: Theme.fontFamily
                        color: "#F1F5F9"
                    }
                    Text {
                        text: "v1.0.0"
                        font.pixelSize: 9
                        font.family: Theme.fontMono
                        color: "#64748B"
                    }
                }

                // Subtle Vertical Divider
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 22
                    Layout.alignment: Qt.AlignVCenter
                    color: Qt.rgba(255, 255, 255, 0.12)
                }

                // Shutdown / Power Button (Sleek button on far right)
                Rectangle {
                    id: powerBtn
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    Layout.alignment: Qt.AlignVCenter
                    radius: 10
                    color: powerArea.containsMouse ? Qt.rgba(239/255, 68/255, 68/255, 0.22) : Qt.rgba(255, 255, 255, 0.05)
                    border.color: powerArea.containsMouse ? "#EF4444" : Qt.rgba(255, 255, 255, 0.12)
                    border.width: 1

                    IconDraw {
                        anchors.centerIn: parent
                        iconName: "power"
                        iconSize: 20
                        iconColor: powerArea.containsMouse ? "#EF4444" : "#93C5FD"
                    }

                    MouseArea {
                        id: powerArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: goodbyeOverlay.startShutdown()
                    }
                }

                Shortcut {
                    sequences: [ "Ctrl+Q", "Meta+Q" ]
                    onActivated: goodbyeOverlay.startShutdown()
                }
            }
        }

        // MAIN BODY
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Left Sidebar
            Sidebar {
                id: navSidebar
                Layout.fillHeight: true
                currentIndex: pageStack.currentIndex
                onPageSelected: function(idx, name) {
                    pageStack.currentIndex = idx;
                    navSidebar.currentIndex = idx;
                }
            }

            // Main Pages Stack with Smooth Page Entrance Animation
            StackLayout {
                id: pageStack
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0

                onCurrentIndexChanged: {
                    navSidebar.currentIndex = pageStack.currentIndex;
                    pageEntranceAnim.restart();
                }

                transform: Translate {
                    id: pageTranslate
                    y: 0
                }

                ParallelAnimation {
                    id: pageEntranceAnim
                    NumberAnimation {
                        target: pageStack
                        property: "opacity"
                        from: 0.25
                        to: 1.0
                        duration: 240
                        easing.type: Easing.OutCubic
                    }
                    NumberAnimation {
                        target: pageTranslate
                        property: "y"
                        from: 8
                        to: 0
                        duration: 240
                        easing.type: Easing.OutCubic
                    }
                }

                OverviewPage {
                    id: overviewPage
                    onNavigateToPage: function(idx) {
                        pageStack.currentIndex = idx;
                        navSidebar.currentIndex = idx;
                    }
                }
                NetworkPage { id: networkPage }
                DevicesPage { id: devicesPage }
                ServicesPage { id: servicesPage }
                DockerPage { id: dockerPage }
                SystemPage { id: systemPage }
                LogsPage { id: logsPage }
                AlertsPage { id: alertsPage }
                SettingsPage { id: settingsPage }
            }
        }

        // BOTTOM STATUS BAR (FOOTER)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            color: Theme.bgApp
            border.color: Theme.borderSubtle
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                RowLayout {
                    spacing: 12
                    Text {
                        text: "NEXUS NOC   v1.0.0"
                        font.pixelSize: 10
                        font.family: Theme.fontMono
                        color: "#64748B"
                    }
                    Text { text: "•"; font.pixelSize: 10; color: "#334155" }
                    Text {
                        text: (typeof systemMonitor !== "undefined" && systemMonitor) ? systemMonitor.deviceName : "Detected Host"
                        font.pixelSize: 10
                        font.family: Theme.fontMono
                        color: "#38BDF8"
                    }
                    Text { text: "•"; font.pixelSize: 10; color: "#334155" }
                    Text {
                        text: appWindow.width + " × " + appWindow.height
                        font.pixelSize: 10
                        font.family: Theme.fontMono
                        color: "#64748B"
                    }
                }

                Item { Layout.fillWidth: true }

                RowLayout {
                    spacing: 8
                    Text {
                        text: "Built for makers. Inspired by real systems."
                        font.pixelSize: 10
                        color: "#475569"
                    }
                    Rectangle {
                        Layout.preferredWidth: 6
                        Layout.preferredHeight: 6
                        radius: 3
                        color: "#10B981"
                    }
                }
            }
        }
    }

    // ====================================================
    // STARTUP PRESENTATION OVERLAY (LOGO + NAME LEFT-TO-RIGHT)
    // ====================================================
    Rectangle {
        id: startupOverlay
        anchors.fill: parent
        z: 999998
        color: "#050914"
        visible: true

        // Center Row: Logo Emblem + Left-to-Right Animated Name Reveal
        Row {
            anchors.centerIn: parent
            spacing: 22

            // Emblem
            Item {
                width: 92
                height: 92
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: splashLogo
                    anchors.fill: parent
                    source: "qrc:/qt/qml/NexusNOC/qml/assets/icon_nexus_logo.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                    opacity: 0.0
                    scale: 0.65
                }
            }

            // Left-to-Right Clipping Mask for "NEXUS NOC"
            Item {
                id: nameRevealClip
                anchors.verticalCenter: parent.verticalCenter
                height: 92
                width: 0
                clip: true

                Row {
                    id: nameRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 14

                    Text {
                        text: "NEXUS"
                        font.pixelSize: 46
                        font.bold: true
                        font.letterSpacing: 3.5
                        font.family: Theme.fontFamily
                        color: "#FFFFFF"
                    }

                    Text {
                        text: "NOC"
                        font.pixelSize: 46
                        font.bold: true
                        font.letterSpacing: 3.5
                        font.family: Theme.fontFamily
                        color: "#38BDF8"
                    }
                }
            }
        }

        // Click anywhere to skip directly into console
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                startupTimeline.stop();
                startupOverlay.visible = false;
            }
        }

        // Orchestrated ~3.2s Startup Sequence: Logo -> Name Left to Right -> Dissolve
        SequentialAnimation {
            id: startupTimeline
            running: true

            // 1. Logo fades & scales in (0 - 650ms)
            ParallelAnimation {
                NumberAnimation {
                    target: splashLogo
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: 650
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: splashLogo
                    property: "scale"
                    from: 0.65
                    to: 1.0
                    duration: 650
                    easing.type: Easing.OutBack
                }
            }

            PauseAnimation { duration: 80 }

            // 2. Name "NEXUS NOC" reveals from left to right (730ms - 1730ms)
            NumberAnimation {
                target: nameRevealClip
                property: "width"
                from: 0
                to: nameRow.implicitWidth
                duration: 1000
                easing.type: Easing.OutCubic
            }

            // 3. Hold presentation cleanly (~1.1s hold)
            PauseAnimation { duration: 1100 }

            // 4. Cinematic Dissolve into live NOC Dashboard (450ms)
            NumberAnimation {
                target: startupOverlay
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: 450
                easing.type: Easing.InOutQuad
            }

            ScriptAction {
                script: startupOverlay.visible = false
            }
        }
    }

    // ====================================================
    // SHUTDOWN: SLOW SLIDE SHINE EFFECT LOGO ONLY (NO SQUARE)
    // ====================================================
    Rectangle {
        id: goodbyeOverlay
        anchors.fill: parent
        z: 999999
        visible: false
        opacity: 0.0
        color: "#030712"

        function startShutdown() {
            if (goodbyeOverlay.visible) return;
            appWindow.isExiting = true;
            goodbyeOverlay.opacity = 1.0;
            goodbyeOverlay.visible = true;
            slideShineBar.x = -110;
            shutdownTimeline.restart();
        }

        // 1. Base Logo Emblem (Only the logo emblem, no borders, no square)
        Image {
            id: shutdownLogo
            anchors.centerIn: parent
            width: 140
            height: 140
            source: "qrc:/qt/qml/NexusNOC/qml/assets/icon_nexus_logo.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
            opacity: 0.0
        }

        // 2. Slow Slide Shine Light Beam Source (Layer to be masked)
        Item {
            id: shineSourceItem
            anchors.fill: shutdownLogo
            layer.enabled: true
            visible: false

            Rectangle {
                id: slideShineBar
                width: 44
                height: parent.height * 2.5
                anchors.verticalCenter: parent.verticalCenter
                rotation: 25
                x: -110

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.30; color: Qt.rgba(0.22, 0.74, 0.97, 0.30) }
                    GradientStop { position: 0.45; color: Qt.rgba(1.0, 1.0, 1.0, 0.75) }
                    GradientStop { position: 0.50; color: Qt.rgba(1.0, 1.0, 1.0, 1.0) }
                    GradientStop { position: 0.55; color: Qt.rgba(1.0, 1.0, 1.0, 0.75) }
                    GradientStop { position: 0.70; color: Qt.rgba(0.22, 0.74, 0.97, 0.30) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }
        }

        // 3. MultiEffect: Masks the slow sliding shine strictly to the logo pixels (no square)
        MultiEffect {
            anchors.fill: shutdownLogo
            source: shineSourceItem
            maskEnabled: true
            maskSource: shutdownLogo
            maskThresholdMin: 0.1
            opacity: shutdownLogo.opacity * 0.95
        }

        // Quick click to exit instantly if in a hurry
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                appWindow.isExiting = true;
                Qt.quit();
            }
        }

        // Orchestrated Slow Slide Shine Sequence: Fade In Logo -> Slow Shine Across Logo -> Fade Out -> Quit
        SequentialAnimation {
            id: shutdownTimeline

            // 1. Logo fades in softly (300ms)
            NumberAnimation {
                target: shutdownLogo
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: 300
                easing.type: Easing.OutQuad
            }

            PauseAnimation { duration: 150 }

            // 2. Slow, cinematic shine sweep strictly across the logo emblem (3.0 seconds)
            NumberAnimation {
                target: slideShineBar
                property: "x"
                from: -110
                to: 170
                duration: 3000
                easing.type: Easing.InOutSine
            }

            // 3. Hold calm logo briefly (350ms)
            PauseAnimation { duration: 350 }

            // 4. Soft dissolve of logo into deep obsidian background (400ms)
            NumberAnimation {
                target: shutdownLogo
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: 400
                easing.type: Easing.InQuad
            }

            PauseAnimation { duration: 100 }

            ScriptAction {
                script: {
                    appWindow.isExiting = true;
                    Qt.quit();
                }
            }
        }
    }
}
