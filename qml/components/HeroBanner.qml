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
import QtQuick.Effects
import NexusNOC

Rectangle {
    id: root

    readonly property color bannerBg: "#050B14"
    readonly property color bannerBorder: "#1B3252"

    implicitWidth: 1600
    implicitHeight: 165
    Layout.fillWidth: true
    Layout.preferredHeight: 165

    radius: 10
    color: bannerBg
    border.color: bannerBorder
    border.width: 1
    clip: true

    // Background Hero Artwork: High-Resolution Uncropped Panoramic Network Canvas
    Image {
        id: heroBgImage
        anchors.fill: parent
        source: "qrc:/qt/qml/NexusNOC/qml/assets/hero_bg.png"
        fillMode: Image.PreserveAspectCrop
        horizontalAlignment: Image.AlignRight
        verticalAlignment: Image.AlignVCenter
        smooth: true
        mipmap: true
    }

    // ----------------------------------------------------
    // Shining Lights & Orbital Telemetry Beacons near the Globe
    // ----------------------------------------------------
    // ----------------------------------------------------
    // Glowing Dots with Names over the Globe
    // ----------------------------------------------------
    Item {
        id: globeEffects
        anchors.fill: parent
        z: 2
        clip: true

        component SubtleBeaconLight: Rectangle {
            id: beacon
            property int pulseDelay: 0
            property int cycleDuration: 2200
            property color lightColor: "#FFFFFF"

            width: 4
            height: 4
            radius: 2
            color: lightColor

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                PauseAnimation { duration: beacon.pulseDelay }
                NumberAnimation { from: 0.25; to: 0.95; duration: beacon.cycleDuration * 0.5; easing.type: Easing.InOutSine }
                NumberAnimation { from: 0.95; to: 0.25; duration: beacon.cycleDuration * 0.5; easing.type: Easing.InOutSine }
            }
        }

        // Subtle pinpoint network lights across the globe
        SubtleBeaconLight { x: parent.width * 0.60; y: parent.height * 0.36; lightColor: "#38BDF8"; pulseDelay: 0; cycleDuration: 2200 }
        SubtleBeaconLight { x: parent.width * 0.74; y: parent.height * 0.25; lightColor: "#60A5FA"; pulseDelay: 400; cycleDuration: 2500 }
        SubtleBeaconLight { x: parent.width * 0.79; y: parent.height * 0.40; lightColor: "#34D399"; pulseDelay: 900; cycleDuration: 2100 }
        SubtleBeaconLight { x: parent.width * 0.65; y: parent.height * 0.58; lightColor: "#A78BFA"; pulseDelay: 1300; cycleDuration: 2600 }
        SubtleBeaconLight { x: parent.width * 0.71; y: parent.height * 0.72; lightColor: "#38BDF8"; pulseDelay: 700; cycleDuration: 2300 }
        SubtleBeaconLight { x: parent.width * 0.68; y: parent.height * 0.46; lightColor: "#FFFFFF"; pulseDelay: 1100; cycleDuration: 2000 }
        SubtleBeaconLight { x: parent.width * 0.83; y: parent.height * 0.32; lightColor: "#93C5FD"; pulseDelay: 1600; cycleDuration: 2400 }
        SubtleBeaconLight { x: parent.width * 0.76; y: parent.height * 0.62; lightColor: "#6EE7B7"; pulseDelay: 300; cycleDuration: 2700 }
    }

    // Left Atmospheric Vignette: Deepens left side for crisp text readability
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * 0.48
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#F0050914" }
            GradientStop { position: 0.45; color: "#AA050914" }
            GradientStop { position: 0.75; color: "#33050914" }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // Subtle edge softening at top and bottom borders
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "#40050914" }
            GradientStop { position: 0.18; color: "transparent" }
            GradientStop { position: 0.82; color: "transparent" }
            GradientStop { position: 1.0; color: "#60050914" }
        }
    }

    // Left Console Header: "Welcome to", Gradient "NEXUS NOC", Subtitle & Status Pillars
    ColumnLayout {
        anchors.left: parent.left
        anchors.leftMargin: 36
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5
        z: 3

        Text {
            text: "Welcome to"
            font.pixelSize: 13
            font.weight: Font.Normal
            font.family: Theme.fontFamily
            color: "#94A3B8"
        }

        // Native GPU Gradient Text for "NEXUS NOC"
        Item {
            implicitWidth: titleMask.width
            implicitHeight: titleMask.height

            Item {
                id: titleMask
                width: titleText.implicitWidth
                height: titleText.implicitHeight
                layer.enabled: true
                visible: false

                Text {
                    id: titleText
                    text: "NEXUS NOC"
                    font.pixelSize: 31
                    font.bold: true
                    font.letterSpacing: 2.2
                    font.family: Theme.fontFamily
                    color: "black"
                }
            }

            Rectangle {
                id: titleGradient
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#FFFFFF" }
                    GradientStop { position: 0.42; color: "#E0F2FE" }
                    GradientStop { position: 0.62; color: "#7DD3FC" }
                    GradientStop { position: 1.0; color: "#38BDF8" }
                }
                visible: false
            }

            MultiEffect {
                source: titleGradient
                anchors.fill: titleGradient
                maskEnabled: true
                maskSource: titleMask
            }
        }

        Text {
            text: "Network Operations & Control Console"
            font.pixelSize: 13
            font.weight: Font.Normal
            font.family: Theme.fontFamily
            color: "#94A3B8"
        }

        Item {
            Layout.preferredHeight: 3
        }

        Text {
            text: "Monitor  ·  Control  ·  Stay Connected"
            font.pixelSize: 11
            font.weight: Font.Medium
            font.letterSpacing: 0.8
            font.family: Theme.fontFamily
            color: "#38BDF8"
        }
    }

    // Right Atmospheric Softening: Seamless full-height gradient
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * 0.38
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.50; color: "#22050B14" }
            GradientStop { position: 0.80; color: "#66050B14" }
            GradientStop { position: 1.0; color: "#99050B14" }
        }
    }

    // Bottom Ambient Softening: Seamless full-width gradient for natural lower depth
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height * 0.55
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.50; color: "#25050B14" }
            GradientStop { position: 1.0; color: "#77050B14" }
        }
    }

    // Right-Side Enterprise Motto & Cyan Gradient Accent: Kept in down (bottom right)
    ColumnLayout {
        anchors.right: parent.right
        anchors.rightMargin: 36
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 18
        spacing: 6
        z: 3

        Text {
            text: "A SMALL DEVICE.\nA BIGGER PICTURE."
            font.pixelSize: 13
            font.bold: true
            font.letterSpacing: 1.8
            font.family: Theme.fontFamily
            color: "#FFFFFF"
            lineHeight: 1.3
            horizontalAlignment: Text.AlignRight
            Layout.alignment: Qt.AlignRight
        }

        Rectangle {
            Layout.alignment: Qt.AlignRight
            width: 46
            height: 3
            radius: 1.5
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#38BDF8" }
                GradientStop { position: 1.0; color: "#1D4ED8" }
            }
        }
    }
}
