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

    property string title: ""
    property string subtitle: ""
    property string badgeText: ""
    property color badgeColor: Theme.statusSuccess
    property color badgeBgColor: Theme.statusSuccessBg
    property bool showHeader: true
    default property alias content: contentArea.children

    color: Theme.bgCard
    border.color: Theme.borderCard
    border.width: 1
    radius: Theme.radiusMedium

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Card Header
        RowLayout {
            id: headerRow
            Layout.fillWidth: true
            visible: root.showHeader
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: root.title.toUpperCase()
                    font.pixelSize: Theme.fontCaption
                    font.bold: true
                    font.family: Theme.fontSans
                    color: Theme.textSecondary
                    font.letterSpacing: 1.2
                }

                Text {
                    text: root.subtitle
                    visible: root.subtitle.length > 0
                    font.pixelSize: Theme.fontSmall
                    font.family: Theme.fontSans
                    color: Theme.textMuted
                }
            }

            // Status Badge
            Rectangle {
                visible: root.badgeText.length > 0
                height: 24
                width: badgeTextItem.implicitWidth + 16
                radius: 12
                color: root.badgeBgColor
                border.color: Qt.rgba(root.badgeColor.r, root.badgeColor.g, root.badgeColor.b, 0.4)
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: root.badgeColor
                    }

                    Text {
                        id: badgeTextItem
                        text: root.badgeText
                        font.pixelSize: Theme.fontSmall
                        font.bold: true
                        font.family: Theme.fontMono
                        color: root.badgeColor
                    }
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.borderSubtle
            visible: root.showHeader
        }

        // Body Content Slot
        Item {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
