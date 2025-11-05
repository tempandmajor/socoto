//
//  AppTheme.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import SwiftUI

/// App-wide theme configuration with glassmorphism design
struct AppTheme {

    // MARK: - Colors
    struct Colors {
        // Primary gradient colors for glassmorphism
        static let primaryGradient = LinearGradient(
            colors: [
                Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.3),
                Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Accent colors
        static let accent = Color(red: 0.5, green: 0.5, blue: 1.0)
        static let accentLight = Color(red: 0.6, green: 0.6, blue: 1.0).opacity(0.6)

        // Neutral colors
        static let background = Color(red: 0.05, green: 0.05, blue: 0.1)
        static let backgroundSecondary = Color(red: 0.1, green: 0.1, blue: 0.15)

        // Glass effect colors
        static let glassBackground = Color.white.opacity(0.1)
        static let glassBorder = Color.white.opacity(0.2)
        static let glassHighlight = Color.white.opacity(0.05)

        // Text colors
        static let textPrimary = Color.white
        static let textSecondary = Color.white.opacity(0.7)
        static let textTertiary = Color.white.opacity(0.5)

        // Status colors
        static let success = Color.green.opacity(0.8)
        static let warning = Color.orange.opacity(0.8)
        static let error = Color.red.opacity(0.8)
        static let info = Color.blue.opacity(0.8)

        // Business category colors (for tags and icons)
        static let category1 = Color(red: 1.0, green: 0.6, blue: 0.4) // Restaurants
        static let category2 = Color(red: 1.0, green: 0.4, blue: 0.6) // Beauty
        static let category3 = Color(red: 0.6, green: 0.4, blue: 1.0) // Fitness
        static let category4 = Color(red: 0.4, green: 1.0, blue: 0.6) // Healthcare
    }

    // MARK: - Typography
    struct Typography {
        // Display
        static let displayLarge = Font.system(size: 57, weight: .bold, design: .rounded)
        static let displayMedium = Font.system(size: 45, weight: .bold, design: .rounded)
        static let displaySmall = Font.system(size: 36, weight: .bold, design: .rounded)

        // Headlines
        static let headlineLarge = Font.system(size: 32, weight: .semibold, design: .rounded)
        static let headlineMedium = Font.system(size: 28, weight: .semibold, design: .rounded)
        static let headlineSmall = Font.system(size: 24, weight: .semibold, design: .rounded)

        // Titles
        static let titleLarge = Font.system(size: 22, weight: .medium, design: .rounded)
        static let titleMedium = Font.system(size: 16, weight: .medium, design: .rounded)
        static let titleSmall = Font.system(size: 14, weight: .medium, design: .rounded)

        // Body
        static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
        static let bodyMedium = Font.system(size: 14, weight: .regular, design: .default)
        static let bodySmall = Font.system(size: 12, weight: .regular, design: .default)

        // Labels
        static let labelLarge = Font.system(size: 14, weight: .semibold, design: .default)
        static let labelMedium = Font.system(size: 12, weight: .semibold, design: .default)
        static let labelSmall = Font.system(size: 11, weight: .semibold, design: .default)
    }

    // MARK: - Spacing
    struct Spacing {
        static let xxxSmall: CGFloat = 2
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 48
        static let xxxLarge: CGFloat = 64
    }

    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 24
        static let xxLarge: CGFloat = 32
        static let round: CGFloat = 9999
    }

    // MARK: - Shadows
    struct Shadow {
        static let small = (color: Color.black.opacity(0.1), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Color.black.opacity(0.15), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let large = (color: Color.black.opacity(0.2), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
        static let glow = (color: AppTheme.Colors.accent.opacity(0.3), radius: CGFloat(20), x: CGFloat(0), y: CGFloat(0))
    }

    // MARK: - Animation
    struct Animation {
        static let fast = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let medium = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
    }

    // MARK: - Blur
    struct Blur {
        static let light: CGFloat = 5
        static let medium: CGFloat = 10
        static let heavy: CGFloat = 20
        static let extraHeavy: CGFloat = 30
    }
}

// MARK: - Environment Key
struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme.Type = AppTheme.self
}

extension EnvironmentValues {
    var appTheme: AppTheme.Type {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}
