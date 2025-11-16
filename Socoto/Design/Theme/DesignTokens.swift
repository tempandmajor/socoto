//
//  DesignTokens.swift
//  Socoto
//
//  Comprehensive design system tokens for iOS
//  Translates web design tokens to native iOS implementation
//

import SwiftUI

// MARK: - Design Tokens

/// Central design system tokens for consistent styling across the app
enum DesignTokens {

    // MARK: - Color Tokens

    /// Semantic color tokens mapped to Asset Catalog colors
    enum Colors {

        // MARK: - Surface Colors
        /// Primary background surface (light: white, dark: near-black)
        static let surface = Color("Surface/Surface")

        /// Page/container background (slightly darker/lighter than surface)
        static let surfacePage = Color("Surface/SurfacePage")

        /// Elevated surface for cards, modals
        static let surfaceElevated = Color("Surface/SurfaceElevated")

        /// Overlay/scrim for modals
        static let surfaceOverlay = Color("Surface/SurfaceOverlay")

        // MARK: - Ink (Text) Colors
        /// Primary text color (highest contrast)
        static let inkPrimary = Color("Ink/Primary")

        /// Secondary text (medium contrast)
        static let inkSecondary = Color("Ink/Secondary")

        /// Tertiary text (low contrast, hints)
        static let inkTertiary = Color("Ink/Tertiary")

        /// Muted text (lowest contrast, disabled states)
        static let inkMuted = Color("Ink/Muted")

        /// Contrast text (for colored backgrounds)
        static let inkContrast = Color("Ink/Contrast")

        // MARK: - Border Colors
        /// Default border color
        static let border = Color("Border/Default")

        /// Subtle border (very low contrast)
        static let borderSubtle = Color("Border/Subtle")

        /// Focus border (interactive states)
        static let borderFocus = Color("Border/Focus")

        // MARK: - Brand Colors
        /// Primary brand color
        static let brandPrimary = Color("Brand/Primary")

        /// Secondary brand color
        static let brandSecondary = Color("Brand/Secondary")

        /// Brand accent color
        static let brandAccent = Color("Brand/Accent")

        // MARK: - Status Colors
        /// Success state background
        static let statusSuccessBackground = Color("Status/SuccessBackground")

        /// Success state foreground
        static let statusSuccessForeground = Color("Status/SuccessForeground")

        /// Warning state background
        static let statusWarningBackground = Color("Status/WarningBackground")

        /// Warning state foreground
        static let statusWarningForeground = Color("Status/WarningForeground")

        /// Error state background
        static let statusErrorBackground = Color("Status/ErrorBackground")

        /// Error state foreground
        static let statusErrorForeground = Color("Status/ErrorForeground")

        /// Info state background
        static let statusInfoBackground = Color("Status/InfoBackground")

        /// Info state foreground
        static let statusInfoForeground = Color("Status/InfoForeground")

        /// Pending state background
        static let statusPendingBackground = Color("Status/PendingBackground")

        /// Pending state foreground
        static let statusPendingForeground = Color("Status/PendingForeground")
    }

    // MARK: - Typography

    /// Typography system using Space Grotesk and Inter fonts
    enum Typography {

        // MARK: - Display Styles (Space Grotesk)
        /// Display Large - 56pt, SemiBold, -0.04 tracking
        static let displayLarge = Font.custom("SpaceGrotesk-SemiBold", size: 56)

        /// Display Medium - 48pt, SemiBold, -0.04 tracking
        static let displayMedium = Font.custom("SpaceGrotesk-SemiBold", size: 48)

        /// Display Small - 40pt, SemiBold, -0.04 tracking
        static let displaySmall = Font.custom("SpaceGrotesk-SemiBold", size: 40)

        // MARK: - Headline Styles (Space Grotesk)
        /// Headline Large - 32pt, SemiBold, -0.04 tracking
        static let headlineLarge = Font.custom("SpaceGrotesk-SemiBold", size: 32)

        /// Headline Medium - 28pt, SemiBold, -0.04 tracking
        static let headlineMedium = Font.custom("SpaceGrotesk-SemiBold", size: 28)

        /// Headline Small - 24pt, SemiBold, -0.04 tracking
        static let headlineSmall = Font.custom("SpaceGrotesk-SemiBold", size: 24)

        // MARK: - Title Styles (Space Grotesk)
        /// Title Large - 20pt, SemiBold, -0.02 tracking
        static let titleLarge = Font.custom("SpaceGrotesk-SemiBold", size: 20)

        /// Title Medium - 18pt, Medium, -0.02 tracking
        static let titleMedium = Font.custom("SpaceGrotesk-Medium", size: 18)

        /// Title Small - 16pt, Medium, -0.02 tracking
        static let titleSmall = Font.custom("SpaceGrotesk-Medium", size: 16)

        // MARK: - Body Styles (Inter)
        /// Body Large - 18pt, Regular, 0 tracking
        static let bodyLarge = Font.custom("Inter-Regular", size: 18)

        /// Body Medium - 16pt, Regular, 0 tracking
        static let bodyMedium = Font.custom("Inter-Regular", size: 16)

        /// Body Small - 14pt, Regular, 0 tracking
        static let bodySmall = Font.custom("Inter-Regular", size: 14)

        // MARK: - Label Styles (Inter)
        /// Label Large - 14pt, Medium, 0.01 tracking
        static let labelLarge = Font.custom("Inter-Medium", size: 14)

        /// Label Medium - 12pt, Medium, 0.01 tracking
        static let labelMedium = Font.custom("Inter-Medium", size: 12)

        /// Label Small - 11pt, Medium, 0.02 tracking
        static let labelSmall = Font.custom("Inter-Medium", size: 11)

        // MARK: - Button Styles (Space Grotesk, Uppercase)
        /// Button Large - 16pt, SemiBold, 0.05 tracking, UPPERCASE
        static let buttonLarge = Font.custom("SpaceGrotesk-SemiBold", size: 16)

        /// Button Medium - 14pt, SemiBold, 0.05 tracking, UPPERCASE
        static let buttonMedium = Font.custom("SpaceGrotesk-SemiBold", size: 14)

        /// Button Small - 12pt, SemiBold, 0.05 tracking, UPPERCASE
        static let buttonSmall = Font.custom("SpaceGrotesk-SemiBold", size: 12)

        // MARK: - Caption Styles (Inter)
        /// Caption - 12pt, Regular, 0 tracking
        static let caption = Font.custom("Inter-Regular", size: 12)

        /// Overline - 10pt, Medium, 0.05 tracking, UPPERCASE
        static let overline = Font.custom("Inter-Medium", size: 10)
    }

    // MARK: - Tracking (Letter Spacing)

    /// Letter spacing values (kerning)
    enum Tracking {
        /// Tight tracking for headlines (-0.04)
        static let tight: CGFloat = -0.04

        /// Medium tracking for titles (-0.02)
        static let medium: CGFloat = -0.02

        /// Normal tracking (0)
        static let normal: CGFloat = 0

        /// Loose tracking for labels (0.01)
        static let loose: CGFloat = 0.01

        /// Extra loose tracking for buttons (0.05)
        static let extraLoose: CGFloat = 0.05
    }

    // MARK: - Spacing

    /// Spacing scale for consistent layout
    enum Spacing {
        /// 4pt - Minimal spacing
        static let xxSmall: CGFloat = 4

        /// 8pt - Extra small spacing
        static let xSmall: CGFloat = 8

        /// 12pt - Small spacing
        static let small: CGFloat = 12

        /// 16pt - Medium spacing (base unit)
        static let medium: CGFloat = 16

        /// 20pt - Large spacing
        static let large: CGFloat = 20

        /// 24pt - Page padding
        static let page: CGFloat = 24

        /// 32pt - Extra large spacing
        static let xLarge: CGFloat = 32

        /// 40pt - 2X large spacing
        static let xxLarge: CGFloat = 40

        /// 48pt - 3X large spacing
        static let xxxLarge: CGFloat = 48

        /// 64pt - 4X large spacing
        static let xxxxLarge: CGFloat = 64
    }

    // MARK: - Border Radius

    /// Border radius values for consistent shapes
    enum Radius {
        /// 4pt - Extra small radius (chips, tags)
        static let xSmall: CGFloat = 4

        /// 8pt - Small radius (buttons, inputs)
        static let small: CGFloat = 8

        /// 12pt - Medium radius (cards, small containers)
        static let medium: CGFloat = 12

        /// 16pt - Large radius (panels, modals)
        static let large: CGFloat = 16

        /// 20pt - Base radius (primary cards)
        static let base: CGFloat = 20

        /// 24pt - Extra large radius
        static let xLarge: CGFloat = 24

        /// 999pt - Pill radius (fully rounded)
        static let pill: CGFloat = 999

        /// 0pt - Sharp corners (no radius)
        static let none: CGFloat = 0
    }

    // MARK: - Shadows

    /// Shadow definitions for elevation
    enum Shadow {

        /// Soft shadow for cards (subtle depth)
        static let soft = ShadowStyle(
            color: Color.black.opacity(0.08),
            radius: 24,
            x: 0,
            y: 16
        )

        /// Medium shadow for elevated elements
        static let medium = ShadowStyle(
            color: Color.black.opacity(0.12),
            radius: 32,
            x: 0,
            y: 20
        )

        /// Hard shadow for modals and important elements
        static let hard = ShadowStyle(
            color: Color.black.opacity(0.16),
            radius: 40,
            x: 0,
            y: 24
        )

        /// Subtle shadow for hover states
        static let subtle = ShadowStyle(
            color: Color.black.opacity(0.04),
            radius: 12,
            x: 0,
            y: 8
        )

        /// Focus shadow for interactive elements
        static let focus = ShadowStyle(
            color: Colors.brandPrimary.opacity(0.3),
            radius: 16,
            x: 0,
            y: 4
        )
    }

    // MARK: - Opacity

    /// Opacity values for consistent transparency
    enum Opacity {
        /// Disabled state
        static let disabled: Double = 0.38

        /// Secondary/muted elements
        static let secondary: Double = 0.60

        /// Hover/overlay states
        static let hover: Double = 0.08

        /// Pressed states
        static let pressed: Double = 0.12

        /// Scrim/backdrop
        static let scrim: Double = 0.54

        /// Glass effect background
        static let glass: Double = 0.12

        /// Glass effect border
        static let glassBorder: Double = 0.20
    }

    // MARK: - Animation

    /// Animation durations and curves
    enum Animation {
        /// Quick animation (150ms)
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.15)

        /// Medium animation (250ms)
        static let medium = SwiftUI.Animation.easeInOut(duration: 0.25)

        /// Slow animation (350ms)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.35)

        /// Spring animation for bouncy interactions
        static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.7)

        /// Smooth spring for natural motion
        static let smoothSpring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)
    }

    // MARK: - Z-Index (Layering)

    /// Z-index values for layering elements
    enum ZIndex {
        /// Base layer
        static let base: Double = 0

        /// Elevated elements (cards)
        static let elevated: Double = 10

        /// Dropdown menus
        static let dropdown: Double = 100

        /// Sticky headers
        static let sticky: Double = 200

        /// Fixed overlays
        static let overlay: Double = 300

        /// Modals
        static let modal: Double = 400

        /// Popovers
        static let popover: Double = 500

        /// Tooltips
        static let tooltip: Double = 600

        /// Toasts/notifications
        static let notification: Double = 700

        /// Critical alerts
        static let alert: Double = 800
    }
}

// MARK: - Shadow Style

/// Shadow style definition
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Modifier Extensions

extension View {

    /// Apply a design token shadow
    func shadow(_ shadow: ShadowStyle) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    /// Apply letter spacing (tracking)
    func tracking(_ tracking: CGFloat) -> some View {
        self.kerning(tracking)
    }

    /// Apply design token corner radius
    func cornerRadius(_ radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

// MARK: - Font Extension

extension Font {

    /// Apply tracking to font
    func withTracking(_ tracking: CGFloat) -> Font {
        return self
    }
}

// MARK: - Typography Modifiers

/// View modifier for display text
struct DisplayTextModifier: ViewModifier {
    let size: Font
    let tracking: CGFloat

    func body(content: Content) -> some View {
        content
            .font(size)
            .kerning(tracking)
            .foregroundColor(DesignTokens.Colors.inkPrimary)
    }
}

/// View modifier for headline text
struct HeadlineTextModifier: ViewModifier {
    let size: Font
    let tracking: CGFloat

    func body(content: Content) -> some View {
        content
            .font(size)
            .kerning(tracking)
            .foregroundColor(DesignTokens.Colors.inkPrimary)
    }
}

/// View modifier for body text
struct BodyTextModifier: ViewModifier {
    let size: Font
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(size)
            .foregroundColor(color)
    }
}

/// View modifier for label text
struct LabelTextModifier: ViewModifier {
    let size: Font
    let tracking: CGFloat
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(size)
            .kerning(tracking)
            .foregroundColor(color)
    }
}

/// View modifier for button text
struct ButtonTextModifier: ViewModifier {
    let size: Font
    let tracking: CGFloat

    func body(content: Content) -> some View {
        content
            .font(size)
            .kerning(tracking)
            .textCase(.uppercase)
            .foregroundColor(DesignTokens.Colors.inkContrast)
    }
}

// MARK: - Convenience Extensions

extension View {

    // Display styles
    func displayLarge() -> some View {
        modifier(DisplayTextModifier(size: DesignTokens.Typography.displayLarge, tracking: DesignTokens.Tracking.tight))
    }

    func displayMedium() -> some View {
        modifier(DisplayTextModifier(size: DesignTokens.Typography.displayMedium, tracking: DesignTokens.Tracking.tight))
    }

    func displaySmall() -> some View {
        modifier(DisplayTextModifier(size: DesignTokens.Typography.displaySmall, tracking: DesignTokens.Tracking.tight))
    }

    // Headline styles
    func headlineLarge() -> some View {
        modifier(HeadlineTextModifier(size: DesignTokens.Typography.headlineLarge, tracking: DesignTokens.Tracking.tight))
    }

    func headlineMedium() -> some View {
        modifier(HeadlineTextModifier(size: DesignTokens.Typography.headlineMedium, tracking: DesignTokens.Tracking.tight))
    }

    func headlineSmall() -> some View {
        modifier(HeadlineTextModifier(size: DesignTokens.Typography.headlineSmall, tracking: DesignTokens.Tracking.tight))
    }

    // Body styles
    func bodyLarge(color: Color = DesignTokens.Colors.inkPrimary) -> some View {
        modifier(BodyTextModifier(size: DesignTokens.Typography.bodyLarge, color: color))
    }

    func bodyMedium(color: Color = DesignTokens.Colors.inkSecondary) -> some View {
        modifier(BodyTextModifier(size: DesignTokens.Typography.bodyMedium, color: color))
    }

    func bodySmall(color: Color = DesignTokens.Colors.inkSecondary) -> some View {
        modifier(BodyTextModifier(size: DesignTokens.Typography.bodySmall, color: color))
    }

    // Label styles
    func labelLarge(color: Color = DesignTokens.Colors.inkSecondary) -> some View {
        modifier(LabelTextModifier(size: DesignTokens.Typography.labelLarge, tracking: DesignTokens.Tracking.loose, color: color))
    }

    func labelMedium(color: Color = DesignTokens.Colors.inkMuted) -> some View {
        modifier(LabelTextModifier(size: DesignTokens.Typography.labelMedium, tracking: DesignTokens.Tracking.loose, color: color))
    }

    func labelSmall(color: Color = DesignTokens.Colors.inkMuted) -> some View {
        modifier(LabelTextModifier(size: DesignTokens.Typography.labelSmall, tracking: DesignTokens.Tracking.extraLoose, color: color))
    }

    // Button styles
    func buttonLarge() -> some View {
        modifier(ButtonTextModifier(size: DesignTokens.Typography.buttonLarge, tracking: DesignTokens.Tracking.extraLoose))
    }

    func buttonMedium() -> some View {
        modifier(ButtonTextModifier(size: DesignTokens.Typography.buttonMedium, tracking: DesignTokens.Tracking.extraLoose))
    }

    func buttonSmall() -> some View {
        modifier(ButtonTextModifier(size: DesignTokens.Typography.buttonSmall, tracking: DesignTokens.Tracking.extraLoose))
    }
}
