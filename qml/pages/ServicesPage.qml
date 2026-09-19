import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import NexusNOC
import "../components"

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            Text {
                text: "SYSTEM SERVICES & DAEMONS"
                font.pixelSize: Theme.fontTitle
                font.bold: true
                color: Theme.textPrimary
            }

            Rectangle {
                height: 24
                width: 110
                radius: 12
                color: Theme.statusSuccessBg
                border.color: Theme.statusSuccess
                Text {
                    anchors.centerIn: parent
                    text: "7 / 7 RUNNING"
                    font.pixelSize: 10
                    font.bold: true
                    font.family: Theme.fontMono
                    color: Theme.statusSuccess
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "INIT SYSTEM: systemd 254 (cgroup v2)"
                font.pixelSize: Theme.fontSmall
                font.family: Theme.fontMono
                color: Theme.textMuted
            }
        }

        // Services List
        ListView {
            id: servicesList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8

            model: [
                { name: "pihole-FTL", desc: "DNS Sinkhole, authoritative local resolver & DHCP", status: "active", mem: "48.2 MB", cpu: "0.8%", uptime: "4d 12h", port: 53 },
                { name: "unbound", desc: "Validating, recursive, caching DNS resolver", status: "active", mem: "32.1 MB", cpu: "0.4%", uptime: "4d 12h", port: 5335 },
                { name: "kea-dhcp4-server", desc: "Modern IPv4 dynamic host configuration protocol daemon", status: "active", mem: "24.6 MB", cpu: "0.2%", uptime: "4d 12h", port: 67 },
                { name: "wg-quick@wg0", desc: "WireGuard kernel VPN secure site-to-site endpoint", status: "active", mem: "8.4 MB", cpu: "1.1%", uptime: "4d 12h", port: 51820 },
                { name: "sshd", desc: "OpenSSH secure shell daemon (Key-only authentication)", status: "active", mem: "12.0 MB", cpu: "0.1%", uptime: "4d 12h", port: 22 },
                { name: "ufw", desc: "Uncomplicated Firewall with stateful packet inspection", status: "active", mem: "6.2 MB", cpu: "0.1%", uptime: "4d 12h", port: 0 },
                { name: "chronyd", desc: "Chrony NTP daemon for precision hardware clock synchronization", status: "active", mem: "4.1 MB", cpu: "0.1%", uptime: "4d 12h", port: 123 }
            ]

            delegate: ServiceCard {
                required property var modelData
                width: servicesList.width
                serviceName: modelData.name
                description: modelData.desc
                status: modelData.status
                memoryUsage: modelData.mem
                cpuUsage: modelData.cpu
                uptime: modelData.uptime
                port: modelData.port
            }
        }
    }
}
