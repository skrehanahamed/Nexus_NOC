import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import NexusNOC
import "../components"

Item {
    id: root

    property string currentFilter: "ALL"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Page Header & Stats
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                text: "CONNECTED DEVICES"
                font.pixelSize: Theme.fontTitle
                font.bold: true
                color: Theme.textPrimary
            }

            Rectangle {
                height: 24
                width: 90
                radius: 12
                color: Theme.statusSuccessBg
                border.color: Theme.statusSuccess
                Text {
                    anchors.centerIn: parent
                    text: (typeof deviceManager !== "undefined" && deviceManager && deviceManager.connectedDeviceCount > 0)
                          ? deviceManager.connectedDeviceCount + " DISCOVERED"
                          : "10 MONITORED"
                    font.pixelSize: 10
                    font.bold: true
                    font.family: Theme.fontMono
                    color: Theme.statusSuccess
                }
            }

            Item { Layout.fillWidth: true }

            // Filter Tabs (Touch buttons)
            RowLayout {
                spacing: 6

                Repeater {
                    model: ["ALL", "ETHERNET", "WI-FI 5G", "WI-FI 2.4G", "IOT"]
                    Rectangle {
                        height: 36
                        width: tabText.implicitWidth + 24
                        radius: Theme.radiusSmall
                        color: root.currentFilter === modelData ? Theme.accentCyan : Theme.bgInput
                        border.color: root.currentFilter === modelData ? Theme.accentCyan : Theme.borderSubtle

                        Text {
                            id: tabText
                            anchors.centerIn: parent
                            text: modelData
                            font.pixelSize: 11
                            font.bold: true
                            color: root.currentFilter === modelData ? "#0B0E14" : Theme.textSecondary
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.currentFilter = modelData
                        }
                    }
                }
            }
        }

        // Devices List
        ListView {
            id: devicesList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8

            model: [
                { name: "Workstation Pro (M3 Max)", ip: "192.168.1.105", mac: "A4:83:E7:4F:29:1A", conn: "1000M Ethernet", icon: "laptop", rx: "184.2 Mbps", tx: "14.5 Mbps", online: true, blocked: false, cat: "ETHERNET" },
                { name: "iPhone 15 Pro", ip: "192.168.1.142", mac: "F0:18:98:C2:55:01", conn: "Wi-Fi 6 (5GHz)", icon: "phone", rx: "38.1 Mbps", tx: "3.2 Mbps", online: true, blocked: false, cat: "WI-FI 5G" },
                { name: "Smart TV 4K OLED", ip: "192.168.1.118", mac: "00:E0:4C:68:01:23", conn: "Wi-Fi (5GHz)", icon: "tv", rx: "62.4 Mbps", tx: "1.1 Mbps", online: true, blocked: false, cat: "WI-FI 5G" },
                { name: "TrueNAS Core Server", ip: "192.168.1.50", mac: "00:25:90:91:AB:CC", conn: "2.5G Ethernet", icon: "server", rx: "98.5 Mbps", tx: "23.4 Mbps", online: true, blocked: false, cat: "ETHERNET" },
                { name: "iPad Air", ip: "192.168.1.155", mac: "BC:D1:D3:88:14:EF", conn: "Wi-Fi 6 (5GHz)", icon: "phone", rx: "12.8 Mbps", tx: "0.8 Mbps", online: true, blocked: false, cat: "WI-FI 5G" },
                { name: "Home Assistant Yellow", ip: "192.168.1.200", mac: "DC:A6:32:00:19:90", conn: "100M Ethernet", icon: "gateway", rx: "2.4 Mbps", tx: "1.9 Mbps", online: true, blocked: false, cat: "ETHERNET" },
                { name: "Smart Thermostat", ip: "192.168.1.201", mac: "68:C6:3A:44:91:02", conn: "Wi-Fi (2.4GHz)", icon: "iot", rx: "0.1 Mbps", tx: "0.1 Mbps", online: true, blocked: false, cat: "IOT" },
                { name: "Security Camera Yard", ip: "192.168.1.202", mac: "18:E8:29:4F:33:88", conn: "PoE Ethernet", icon: "devices", rx: "0.2 Mbps", tx: "8.4 Mbps", online: true, blocked: false, cat: "ETHERNET" },
                { name: "Smart Speaker", ip: "192.168.1.203", mac: "44:65:0D:33:12:45", conn: "Wi-Fi (2.4GHz)", icon: "wifi", rx: "4.8 Mbps", tx: "0.2 Mbps", online: true, blocked: false, cat: "IOT" },
                { name: "Suspicious Guest Device", ip: "192.168.1.240", mac: "94:E9:79:01:23:45", conn: "Wi-Fi (2.4GHz)", icon: "alerts", rx: "0.0 Mbps", tx: "0.0 Mbps", online: false, blocked: true, cat: "WI-FI 2.4G" }
            ]

            delegate: DeviceCard {
                required property var modelData
                width: devicesList.width
                visible: root.currentFilter === "ALL" || modelData.cat === root.currentFilter
                height: visible ? 76 : 0

                deviceName: modelData.name
                ipAddress: modelData.ip
                macAddress: modelData.mac
                connectionType: modelData.conn
                iconName: modelData.icon
                rxRate: modelData.rx
                txRate: modelData.tx
                isOnline: modelData.online
                isBlocked: modelData.blocked
                onToggleBlock: {
                    if (typeof deviceManager !== "undefined") {
                        if (isBlocked) deviceManager.blockDevice(macAddress)
                        else deviceManager.unblockDevice(macAddress)
                    }
                }
            }
        }
    }
}
