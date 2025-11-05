//
//  GlassCard.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import SwiftUI

/// Glassmorphic card container for content
struct GlassCard<Content: View>: View {
    enum CardStyle {
        case standard
        case elevated
        case subtle
    }

    let style: CardStyle
    let cornerRadius: CGFloat
    let padding: CGFloat
    let content: Content

    init(
        style: CardStyle = .standard,
        cornerRadius: CGFloat = AppTheme.CornerRadius.medium,
        padding: CGFloat = AppTheme.Spacing.medium,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderGradient, lineWidth: borderWidth)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowOffset
            )
    }

    @ViewBuilder
    private var backgroundView: some View {
        ZStack {
            switch style {
            case .standard:
                Color.white.opacity(0.1)
                    .background(.ultraThinMaterial)
            case .elevated:
                Color.white.opacity(0.15)
                    .background(.thinMaterial)
            case .subtle:
                Color.white.opacity(0.05)
                    .background(.ultraThinMaterial)
            }

            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var gradientColors: [Color] {
        switch style {
        case .standard:
            return [
                Color.white.opacity(0.1),
                Color.white.opacity(0.05)
            ]
        case .elevated:
            return [
                Color.white.opacity(0.15),
                Color.white.opacity(0.1)
            ]
        case .subtle:
            return [
                Color.white.opacity(0.05),
                Color.white.opacity(0.02)
            ]
        }
    }

    private var borderGradient: LinearGradient {
        switch style {
        case .standard:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .elevated:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.3),
                    Color.white.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .subtle:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.15),
                    Color.white.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .standard: return 1
        case .elevated: return 1.5
        case .subtle: return 0.5
        }
    }

    private var shadowColor: Color {
        switch style {
        case .standard: return Color.black.opacity(0.1)
        case .elevated: return Color.black.opacity(0.15)
        case .subtle: return Color.black.opacity(0.05)
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .standard: return 8
        case .elevated: return 12
        case .subtle: return 4
        }
    }

    private var shadowOffset: CGFloat {
        switch style {
        case .standard: return 4
        case .elevated: return 6
        case .subtle: return 2
        }
    }
}

/// Tappable glassmorphic card with press animation
struct TappableGlassCard<Content: View>: View {
    let style: GlassCard<Content>.CardStyle
    let cornerRadius: CGFloat
    let padding: CGFloat
    let action: () -> Void
    let content: Content

    @State private var isPressed = false

    init(
        style: GlassCard<Content>.CardStyle = .standard,
        cornerRadius: CGFloat = AppTheme.CornerRadius.medium,
        padding: CGFloat = AppTheme.Spacing.medium,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            GlassCard(style: style, cornerRadius: cornerRadius, padding: padding) {
                content
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AppTheme.Animation.spring, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Previews
#Preview("Card Styles") {
    ZStack {
        AppTheme.Colors.background
            .ignoresSafeArea()

        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                GlassCard(style: .standard) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Standard Card")
                            .font(AppTheme.Typography.headlineSmall)
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Text("This is a standard glassmorphic card with default styling")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }

                GlassCard(style: .elevated) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Elevated Card")
                            .font(AppTheme.Typography.headlineSmall)
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Text("This card has more prominence with elevated styling")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }

                GlassCard(style: .subtle) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                        Text("Subtle Card")
                            .font(AppTheme.Typography.headlineSmall)
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Text("This card has minimal visual weight for background elements")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }

                TappableGlassCard(action: {
                    print("Card tapped")
                }) {
                    HStack {
                        Image(systemName: "hand.tap")
                            .font(.largeTitle)
                            .foregroundColor(AppTheme.Colors.accent)

                        VStack(alignment: .leading) {
                            Text("Tappable Card")
                                .font(AppTheme.Typography.headlineSmall)
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Text("Tap me!")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }

                        Spacer()
                    }
                }
            }
            .padding()
        }
    }
}
