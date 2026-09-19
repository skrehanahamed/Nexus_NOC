import QtQuick
import NexusNOC

Canvas {
    id: root

    property string iconName: "wifi"
    property color iconColor: "#94A3B8"
    property int iconSize: 20

    width: iconSize
    height: iconSize
    renderTarget: Canvas.Image

    onIconNameChanged: requestPaint()
    onIconColorChanged: requestPaint()
    onIconSizeChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        var s = iconSize;
        ctx.clearRect(0, 0, s, s);
        ctx.strokeStyle = iconColor;
        ctx.fillStyle = iconColor;
        ctx.lineWidth = 1.5;
        ctx.lineCap = "round";
        ctx.lineJoin = "round";

        // Helper: draw rounded rectangle (Qt Canvas lacks roundRect)
        function rRect(x, y, w, h, r) {
            ctx.beginPath();
            ctx.moveTo(x + r, y);
            ctx.lineTo(x + w - r, y);
            ctx.arc(x + w - r, y + r, r, -Math.PI / 2, 0);
            ctx.lineTo(x + w, y + h - r);
            ctx.arc(x + w - r, y + h - r, r, 0, Math.PI / 2);
            ctx.lineTo(x + r, y + h);
            ctx.arc(x + r, y + h - r, r, Math.PI / 2, Math.PI);
            ctx.lineTo(x, y + r);
            ctx.arc(x + r, y + r, r, Math.PI, Math.PI * 1.5);
            ctx.closePath();
        }

        switch (iconName) {

        case "wifi":
            ctx.lineWidth = 1.8;
            var cx = s * 0.5;
            var by = s * 0.78;
            ctx.beginPath();
            ctx.arc(cx, by, s * 0.38, -Math.PI * 0.8, -Math.PI * 0.2);
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(cx, by, s * 0.26, -Math.PI * 0.75, -Math.PI * 0.25);
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(cx, by, s * 0.14, -Math.PI * 0.7, -Math.PI * 0.3);
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(cx, by, 2, 0, Math.PI * 2);
            ctx.fill();
            break;

        case "ethernet":
            ctx.lineWidth = 1.6;
            var ex = s * 0.2, ey = s * 0.25, ew = s * 0.6, eh = s * 0.4;
            ctx.beginPath();
            ctx.rect(ex, ey, ew, eh);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(s * 0.4, ey + eh);
            ctx.lineTo(s * 0.4, s * 0.82);
            ctx.moveTo(s * 0.6, ey + eh);
            ctx.lineTo(s * 0.6, s * 0.82);
            ctx.stroke();
            for (var ei = 0; ei < 4; ei++) {
                var px = ex + ew * 0.18 + (ew * 0.64 / 3) * ei;
                ctx.beginPath();
                ctx.moveTo(px, ey + 3);
                ctx.lineTo(px, ey + eh * 0.45);
                ctx.stroke();
            }
            break;

        case "globe":
            ctx.lineWidth = 1.5;
            var gr = s * 0.38;
            var gcx = s * 0.5, gcy = s * 0.5;
            ctx.beginPath();
            ctx.arc(gcx, gcy, gr, 0, Math.PI * 2);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(gcx - gr, gcy);
            ctx.lineTo(gcx + gr, gcy);
            ctx.stroke();
            ctx.beginPath();
            ctx.ellipse(gcx - gr * 0.35, gcy - gr, gr * 0.7, gr * 2);
            ctx.stroke();
            break;

        case "devices":
            ctx.lineWidth = 1.5;
            var dx = s * 0.12, dy = s * 0.18, dw = s * 0.76, dh = s * 0.42;
            rRect(dx, dy, dw, dh, 3);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(s * 0.5, dy + dh);
            ctx.lineTo(s * 0.5, s * 0.78);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(s * 0.3, s * 0.78);
            ctx.lineTo(s * 0.7, s * 0.78);
            ctx.stroke();
            break;

        case "docker":
            ctx.lineWidth = 1.4;
            ctx.beginPath();
            ctx.moveTo(s * 0.08, s * 0.56);
            ctx.lineTo(s * 0.92, s * 0.56);
            ctx.quadraticCurveTo(s * 0.92, s * 0.78, s * 0.5, s * 0.78);
            ctx.quadraticCurveTo(s * 0.08, s * 0.78, s * 0.08, s * 0.56);
            ctx.stroke();
            var bw = s * 0.13, bh = s * 0.1;
            for (var row = 0; row < 2; row++) {
                for (var col = 0; col < 3; col++) {
                    ctx.strokeRect(s * 0.26 + col * (bw + 2), s * 0.28 + row * (bh + 2), bw, bh);
                }
            }
            break;

        case "gear":
        case "services":
            ctx.lineWidth = 1.5;
            var scx = s * 0.5, scy = s * 0.5;
            var outerR = s * 0.38, innerR = s * 0.26;
            var teeth = 8;
            ctx.beginPath();
            for (var ti = 0; ti < teeth; ti++) {
                var a1 = (ti / teeth) * Math.PI * 2 - Math.PI / 2;
                var a2 = ((ti + 0.35) / teeth) * Math.PI * 2 - Math.PI / 2;
                var a3 = ((ti + 0.5) / teeth) * Math.PI * 2 - Math.PI / 2;
                var a4 = ((ti + 0.85) / teeth) * Math.PI * 2 - Math.PI / 2;
                if (ti === 0) ctx.moveTo(scx + outerR * Math.cos(a1), scy + outerR * Math.sin(a1));
                ctx.lineTo(scx + outerR * Math.cos(a2), scy + outerR * Math.sin(a2));
                ctx.lineTo(scx + innerR * Math.cos(a3), scy + innerR * Math.sin(a3));
                ctx.lineTo(scx + innerR * Math.cos(a4), scy + innerR * Math.sin(a4));
            }
            ctx.closePath();
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(scx, scy, s * 0.1, 0, Math.PI * 2);
            ctx.stroke();
            break;

        case "cpu":
            ctx.lineWidth = 1.4;
            var chipX = s * 0.24, chipY = s * 0.24, chipS = s * 0.52;
            rRect(chipX, chipY, chipS, chipS, 3);
            ctx.stroke();
            for (var pi = 0; pi < 3; pi++) {
                var offset = chipY + chipS * 0.2 + (chipS * 0.6 / 2) * pi;
                ctx.beginPath(); ctx.moveTo(chipX + chipS * 0.2 + (chipS * 0.6 / 2) * pi, chipY); ctx.lineTo(chipX + chipS * 0.2 + (chipS * 0.6 / 2) * pi, chipY - s * 0.1); ctx.stroke();
                ctx.beginPath(); ctx.moveTo(chipX + chipS * 0.2 + (chipS * 0.6 / 2) * pi, chipY + chipS); ctx.lineTo(chipX + chipS * 0.2 + (chipS * 0.6 / 2) * pi, chipY + chipS + s * 0.1); ctx.stroke();
                ctx.beginPath(); ctx.moveTo(chipX, offset); ctx.lineTo(chipX - s * 0.1, offset); ctx.stroke();
                ctx.beginPath(); ctx.moveTo(chipX + chipS, offset); ctx.lineTo(chipX + chipS + s * 0.1, offset); ctx.stroke();
            }
            break;

        case "ram":
            ctx.lineWidth = 1.4;
            rRect(s * 0.1, s * 0.3, s * 0.8, s * 0.4, 2);
            ctx.stroke();
            for (var ri = 0; ri < 4; ri++) {
                ctx.strokeRect(s * 0.18 + ri * s * 0.18, s * 0.38, s * 0.1, s * 0.24);
            }
            break;

        case "storage":
            ctx.lineWidth = 1.5;
            rRect(s * 0.12, s * 0.2, s * 0.76, s * 0.6, 4);
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(s * 0.44, s * 0.5, s * 0.16, 0, Math.PI * 2);
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(s * 0.44, s * 0.5, 2, 0, Math.PI * 2);
            ctx.fill();
            ctx.beginPath();
            ctx.arc(s * 0.76, s * 0.68, 2.5, 0, Math.PI * 2);
            ctx.fill();
            break;

        case "temp":
            ctx.lineWidth = 1.5;
            var ttx = s * 0.5;
            ctx.beginPath();
            ctx.arc(ttx, s * 0.72, s * 0.12, 0, Math.PI * 2);
            ctx.fill();
            rRect(ttx - s * 0.06, s * 0.15, s * 0.12, s * 0.5, 3);
            ctx.stroke();
            ctx.beginPath();
            ctx.rect(ttx - s * 0.03, s * 0.32, s * 0.06, s * 0.3);
            ctx.fill();
            break;

        case "clock":
            ctx.lineWidth = 1.5;
            var clcx = s * 0.5, clcy = s * 0.5, clr = s * 0.38;
            ctx.beginPath();
            ctx.arc(clcx, clcy, clr, 0, Math.PI * 2);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(clcx, clcy);
            ctx.lineTo(clcx + s * 0.12, clcy - s * 0.14);
            ctx.stroke();
            ctx.lineWidth = 1.2;
            ctx.beginPath();
            ctx.moveTo(clcx, clcy);
            ctx.lineTo(clcx - s * 0.05, clcy - s * 0.24);
            ctx.stroke();
            ctx.beginPath();
            ctx.arc(clcx, clcy, 2, 0, Math.PI * 2);
            ctx.fill();
            break;

        case "uptime":
            ctx.lineWidth = 1.8;
            var ucx = s * 0.5, ucy = s * 0.52, ur = s * 0.38;
            ctx.beginPath();
            ctx.arc(ucx, ucy, ur, -Math.PI * 0.35, Math.PI * 1.35, false);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(ucx, s * 0.12);
            ctx.lineTo(ucx, s * 0.44);
            ctx.stroke();
            ctx.lineWidth = 1.3;
            ctx.beginPath();
            ctx.arc(ucx, ucy + s * 0.05, ur * 0.5, -Math.PI * 0.25, Math.PI * 1.25, false);
            ctx.stroke();
            break;

        case "check":
            ctx.lineWidth = 2.2;
            ctx.beginPath();
            ctx.moveTo(s * 0.2, s * 0.52);
            ctx.lineTo(s * 0.42, s * 0.74);
            ctx.lineTo(s * 0.8, s * 0.26);
            ctx.stroke();
            break;

        case "check-circle":
            ctx.lineWidth = 1.6;
            ctx.beginPath();
            ctx.arc(s * 0.5, s * 0.5, s * 0.42, 0, Math.PI * 2);
            ctx.stroke();
            ctx.lineWidth = 2.0;
            ctx.beginPath();
            ctx.moveTo(s * 0.28, s * 0.52);
            ctx.lineTo(s * 0.44, s * 0.68);
            ctx.lineTo(s * 0.72, s * 0.34);
            ctx.stroke();
            break;

        case "power":
            ctx.lineWidth = 1.8;
            var pcx2 = s * 0.5;
            var pcy2 = s * 0.54;
            var pr2 = s * 0.35;
            ctx.beginPath();
            ctx.arc(pcx2, pcy2, pr2, -Math.PI * 0.28, Math.PI * 1.28, false);
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(pcx2, s * 0.14);
            ctx.lineTo(pcx2, s * 0.50);
            ctx.stroke();
            break;

        case "overview":
            ctx.lineWidth = 1.5;
            rRect(s * 0.12, s * 0.12, s * 0.32, s * 0.32, 2); ctx.stroke();
            rRect(s * 0.56, s * 0.12, s * 0.32, s * 0.32, 2); ctx.stroke();
            rRect(s * 0.12, s * 0.56, s * 0.32, s * 0.32, 2); ctx.stroke();
            rRect(s * 0.56, s * 0.56, s * 0.32, s * 0.32, 2); ctx.stroke();
            break;

        case "network":
            ctx.lineWidth = 1.4;
            var ncx2 = s * 0.5, ncy2 = s * 0.5;
            ctx.beginPath();
            ctx.arc(ncx2, ncy2, s * 0.08, 0, Math.PI * 2);
            ctx.fill();
            var nNodes2 = [[0.2, 0.22], [0.8, 0.22], [0.2, 0.78], [0.8, 0.78]];
            for (var ni2 = 0; ni2 < nNodes2.length; ni2++) {
                var nnx = s * nNodes2[ni2][0], nny = s * nNodes2[ni2][1];
                ctx.beginPath(); ctx.moveTo(ncx2, ncy2); ctx.lineTo(nnx, nny); ctx.stroke();
                ctx.beginPath(); ctx.arc(nnx, nny, s * 0.06, 0, Math.PI * 2); ctx.fill();
            }
            break;

        case "laptop":
            ctx.lineWidth = 1.5;
            rRect(s * 0.18, s * 0.16, s * 0.64, s * 0.42, 3); ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(s * 0.1, s * 0.62);
            ctx.lineTo(s * 0.9, s * 0.62);
            ctx.lineTo(s * 0.84, s * 0.76);
            ctx.lineTo(s * 0.16, s * 0.76);
            ctx.closePath();
            ctx.stroke();
            break;

        case "phone":
            ctx.lineWidth = 1.5;
            rRect(s * 0.3, s * 0.1, s * 0.4, s * 0.8, 4); ctx.stroke();
            ctx.beginPath(); ctx.moveTo(s * 0.42, s * 0.8); ctx.lineTo(s * 0.58, s * 0.8); ctx.stroke();
            break;

        case "tv":
            ctx.lineWidth = 1.5;
            rRect(s * 0.1, s * 0.16, s * 0.8, s * 0.5, 3); ctx.stroke();
            ctx.beginPath(); ctx.moveTo(s * 0.35, s * 0.7); ctx.lineTo(s * 0.2, s * 0.84); ctx.stroke();
            ctx.beginPath(); ctx.moveTo(s * 0.65, s * 0.7); ctx.lineTo(s * 0.8, s * 0.84); ctx.stroke();
            break;

        case "iot":
            ctx.lineWidth = 1.4;
            ctx.beginPath();
            ctx.arc(s * 0.5, s * 0.5, s * 0.2, 0, Math.PI * 2);
            ctx.stroke();
            var rays2 = [[-0.25, -0.3], [0.25, -0.3], [-0.35, 0.1], [0.35, 0.1], [0, 0.35]];
            for (var ri3 = 0; ri3 < rays2.length; ri3++) {
                ctx.beginPath();
                ctx.moveTo(s * (0.5 + rays2[ri3][0] * 0.58), s * (0.5 + rays2[ri3][1] * 0.58));
                ctx.lineTo(s * (0.5 + rays2[ri3][0] * 0.9), s * (0.5 + rays2[ri3][1] * 0.9));
                ctx.stroke();
                ctx.beginPath();
                ctx.arc(s * (0.5 + rays2[ri3][0] * 0.9), s * (0.5 + rays2[ri3][1] * 0.9), 2, 0, Math.PI * 2);
                ctx.fill();
            }
            ctx.beginPath();
            ctx.arc(s * 0.5, s * 0.5, 2.5, 0, Math.PI * 2);
            ctx.fill();
            break;

        case "logs":
            ctx.lineWidth = 1.5;
            rRect(s * 0.16, s * 0.1, s * 0.68, s * 0.8, 3); ctx.stroke();
            for (var li2 = 0; li2 < 4; li2++) {
                ctx.beginPath();
                ctx.moveTo(s * 0.26, s * 0.28 + li2 * s * 0.14);
                ctx.lineTo(s * (0.58 + (li2 % 2 === 0 ? 0.16 : 0)), s * 0.28 + li2 * s * 0.14);
                ctx.stroke();
            }
            break;

        case "alerts":
            ctx.lineWidth = 1.5;
            var bcx2 = s * 0.5;
            ctx.beginPath();
            ctx.moveTo(s * 0.2, s * 0.62);
            ctx.quadraticCurveTo(s * 0.2, s * 0.28, bcx2, s * 0.18);
            ctx.quadraticCurveTo(s * 0.8, s * 0.28, s * 0.8, s * 0.62);
            ctx.lineTo(s * 0.2, s * 0.62);
            ctx.stroke();
            ctx.beginPath(); ctx.moveTo(s * 0.15, s * 0.66); ctx.lineTo(s * 0.85, s * 0.66); ctx.stroke();
            ctx.beginPath(); ctx.arc(bcx2, s * 0.78, s * 0.06, 0, Math.PI * 2); ctx.stroke();
            ctx.beginPath(); ctx.arc(bcx2, s * 0.15, s * 0.03, 0, Math.PI * 2); ctx.fill();
            break;

        case "settings":
            ctx.lineWidth = 1.6;
            var sliderYs2 = [s * 0.25, s * 0.5, s * 0.75];
            var sliderXs2 = [s * 0.6, s * 0.35, s * 0.55];
            for (var si2 = 0; si2 < 3; si2++) {
                ctx.beginPath();
                ctx.moveTo(s * 0.15, sliderYs2[si2]);
                ctx.lineTo(s * 0.85, sliderYs2[si2]);
                ctx.strokeStyle = Qt.darker(iconColor, 1.8);
                ctx.stroke();
                ctx.strokeStyle = iconColor;
                ctx.beginPath();
                ctx.arc(sliderXs2[si2], sliderYs2[si2], s * 0.05, 0, Math.PI * 2);
                ctx.fillStyle = iconColor;
                ctx.fill();
            }
            break;

        case "router":
            ctx.lineWidth = 1.5;
            rRect(s * 0.12, s * 0.42, s * 0.76, s * 0.34, 3); ctx.stroke();
            ctx.beginPath(); ctx.moveTo(s * 0.3, s * 0.42); ctx.lineTo(s * 0.22, s * 0.16); ctx.stroke();
            ctx.beginPath(); ctx.moveTo(s * 0.7, s * 0.42); ctx.lineTo(s * 0.78, s * 0.16); ctx.stroke();
            ctx.beginPath(); ctx.arc(s * 0.22, s * 0.14, 2.5, 0, Math.PI * 2); ctx.fill();
            ctx.beginPath(); ctx.arc(s * 0.78, s * 0.14, 2.5, 0, Math.PI * 2); ctx.fill();
            for (var led2 = 0; led2 < 3; led2++) {
                ctx.beginPath(); ctx.arc(s * 0.35 + led2 * s * 0.15, s * 0.59, 2, 0, Math.PI * 2); ctx.fill();
            }
            break;

        case "server":
            ctx.lineWidth = 1.5;
            for (var rk2 = 0; rk2 < 3; rk2++) {
                var ry2 = s * 0.14 + rk2 * s * 0.24;
                rRect(s * 0.14, ry2, s * 0.72, s * 0.2, 2); ctx.stroke();
                ctx.beginPath(); ctx.arc(s * 0.26, ry2 + s * 0.1, 2, 0, Math.PI * 2); ctx.fill();
                ctx.beginPath(); ctx.moveTo(s * 0.5, ry2 + 3); ctx.lineTo(s * 0.5, ry2 + s * 0.2 - 3); ctx.stroke();
            }
            break;

        case "shield":
            ctx.lineWidth = 1.5;
            ctx.beginPath();
            ctx.moveTo(s * 0.5, s * 0.1);
            ctx.quadraticCurveTo(s * 0.85, s * 0.18, s * 0.82, s * 0.48);
            ctx.quadraticCurveTo(s * 0.78, s * 0.72, s * 0.5, s * 0.9);
            ctx.quadraticCurveTo(s * 0.22, s * 0.72, s * 0.18, s * 0.48);
            ctx.quadraticCurveTo(s * 0.15, s * 0.18, s * 0.5, s * 0.1);
            ctx.closePath();
            ctx.stroke();
            ctx.lineWidth = 2;
            ctx.beginPath();
            ctx.moveTo(s * 0.34, s * 0.5);
            ctx.lineTo(s * 0.46, s * 0.62);
            ctx.lineTo(s * 0.66, s * 0.38);
            ctx.stroke();
            break;

        case "gateway":
            ctx.lineWidth = 1.5;
            rRect(s * 0.2, s * 0.14, s * 0.6, s * 0.72, 3); ctx.stroke();
            ctx.beginPath(); ctx.moveTo(s * 0.32, s * 0.5); ctx.lineTo(s * 0.68, s * 0.5); ctx.stroke();
            ctx.beginPath(); ctx.moveTo(s * 0.58, s * 0.4); ctx.lineTo(s * 0.68, s * 0.5); ctx.lineTo(s * 0.58, s * 0.6); ctx.stroke();
            break;

        case "system":
            ctx.lineWidth = 1.5;
            rRect(s * 0.1, s * 0.14, s * 0.8, s * 0.72, 4); ctx.stroke();
            ctx.lineWidth = 1.8;
            ctx.beginPath(); ctx.moveTo(s * 0.24, s * 0.42); ctx.lineTo(s * 0.38, s * 0.52); ctx.lineTo(s * 0.24, s * 0.62); ctx.stroke();
            ctx.beginPath(); ctx.moveTo(s * 0.44, s * 0.62); ctx.lineTo(s * 0.62, s * 0.62); ctx.stroke();
            break;

        default:
            ctx.beginPath();
            ctx.arc(s * 0.5, s * 0.5, s * 0.3, 0, Math.PI * 2);
            ctx.stroke();
            break;
        }
    }
}
