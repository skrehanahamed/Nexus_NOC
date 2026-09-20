pragma Singleton

/**
 * ============================================================================
 * Nexus NOC - Enterprise Network Operations Center Appliance
 * Copyright (c) 2026 Sk Rehan Ahamed
 * Developer: Sk Rehan Ahamed (https://github.com/skrehanahamed)
 * Licensed under the MIT License
 * ============================================================================
 */

import QtQuick

QtObject {
    id: theme

    // Base Dimensions (Dynamic laptop and monitor scaling)
    readonly property int defaultWidth: 1440
    readonly property int defaultHeight: 820
    readonly property int minWidth: 1080
    readonly property int minHeight: 620

    // Palette: Deep Dark Enterprise Charcoal Aesthetic
    readonly property color bgApp: "#0B0E14"          // Ultra-deep dark console background
    readonly property color bgSidebar: "#0E121B"      // Slightly lighter sidebar
    readonly property color bgHeader: "#0E131E"       // Header background
    readonly property color bgCard: "#131824"         // Card / Panel background
    readonly property color bgCardHover: "#182030"    // Card hover state
    readonly property color bgCardActive: "#1C2538"   // Card active/selected state
    readonly property color bgInput: "#0D111A"        // Input & well background
    readonly property color bgPill: "#192233"         // Pill / badge background

    // Borders & Dividers
    readonly property color borderSubtle: "#1C2333"   // Subtle card border
    readonly property color borderCard: "#232D42"     // Standard panel border
    readonly property color borderBright: "#33415D"   // Focused/Hovered border
    readonly property color borderHighlight: "#3B82F6"// Active highlight border

    // Typography Colors
    readonly property color textPrimary: "#F1F5F9"    // High contrast crisp white/slate
    readonly property color textSecondary: "#94A3B8"  // Muted silver/slate
    readonly property color textMuted: "#64748B"      // Subtle label text
    readonly property color textDim: "#475569"        // Very dim technical text

    // Semantic Status Colors (Network Appliance Standard)
    readonly property color statusSuccess: "#10B981"  // Healthy / Online Green
    readonly property color statusSuccessBg: "#0B2E24"// Green pill background
    readonly property color statusWarning: "#F59E0B"  // Warning Amber
    readonly property color statusWarningBg: "#342207"// Amber pill background
    readonly property color statusCritical: "#EF4444" // Critical / Down Red
    readonly property color statusCriticalBg: "#371317"// Red pill background
    readonly property color statusInfo: "#06B6D4"     // Info Cyan
    readonly property color statusInfoBg: "#072B38"   // Cyan pill background

    // Restrained Tech Accents
    readonly property color accentPrimary: "#2563EB"  // Nexus Primary Cobalt Blue
    readonly property color accentCyan: "#06B6D4"     // Technical Cyan (Download)
    readonly property color accentPurple: "#8B5CF6"   // Metric Purple (Upload)
    readonly property color accentEmerald: "#10B981"  // Network link green
    readonly property color accentAmber: "#F59E0B"    // Alert Amber

    // Touch Screen Ergonomics
    readonly property int touchMinHeight: 48          // Minimum touch target (48px)
    readonly property int touchButtonHeight: 52       // Standard button touch height
    readonly property int sidebarWidth: 260           // Comfortable sidebar width
    readonly property int headerHeight: 72            // Prominent appliance header height
    readonly property int radiusSmall: 6
    readonly property int radiusMedium: 10
    readonly property int radiusLarge: 14

    // Typography Sizing
    readonly property string fontMono: "Courier New"
    readonly property string fontSans: "Helvetica"
    readonly property string fontFamily: "Helvetica"
    
    readonly property int fontTitle: 22
    readonly property int fontHeader: 17
    readonly property int fontBody: 14
    readonly property int fontCaption: 12
    readonly property int fontSmall: 11
    readonly property int fontTelemetry: 32           // For big numeric counters
}
