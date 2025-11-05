//
//  GlassButton.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import SwiftUI

/// Glassmorphic button with various styles
struct GlassButton: View {
    enum ButtonStyle {
        case primary
        case secondary
        case accent
        case destructive
    }

    enum ButtonSize {
        case small
        case medium
        case large

        var height: CGFloat {
            switch self {
            case .small: return 40
            case .medium: return 48
            case .large: return 56
            }
        }

        var font: Font {
            switch self {
            case .small: return AppTheme.Typography.labelSmall
            case .medium: return AppTheme.Typography.labelMedium
            case .large: return AppTheme.Typography.labelLarge
            }
        }
    }

    let title: String
    let icon: String?
    let style: ButtonStyle
    let size: ButtonSize
    let isLoading: Bool
    let action: () -> Void

    @State private var isPressed = false

    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: {
            if !isLoading {
                action()
            }
        }) {
            HStack(spacing: AppTheme.Spacing.small) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: textColor))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(size.font)
                    }
                }

                Text(title)
                    .font(size.font)
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: size.height)
            .background(backgroundGradient)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(borderGradient, lineWidth: 1)
            )
            .shadow(
                color: shadowColor,
                radius: isPressed ? 4 : 8,
                x: 0,
                y: isPressed ? 2 : 4
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .opacity(isLoading ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isLoading {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .animation(AppTheme.Animation.spring, value: isPressed)
        .animation(AppTheme.Animation.medium, value: isLoading)
        .disabled(isLoading)
    }

    private var textColor: Color {
        switch style {
        case .primary, .accent, .destructive:
            return AppTheme.Colors.textPrimary
        case .secondary:
            return AppTheme.Colors.textSecondary
        }
    }

    private var backgroundGradient: LinearGradient {
        switch style {
        case .primary:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.accent.opacity(0.3),
                    AppTheme.Colors.accent.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.1),
                    Color.white.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .accent:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.accent.opacity(0.4),
                    AppTheme.Colors.accentLight.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .destructive:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.error.opacity(0.3),
                    AppTheme.Colors.error.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var borderGradient: LinearGradient {
        switch style {
        case .primary, .accent:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.accent.opacity(0.5),
                    AppTheme.Colors.accent.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .destructive:
            return LinearGradient(
                colors: [
                    AppTheme.Colors.error.opacity(0.5),
                    AppTheme.Colors.error.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var shadowColor: Color {
        switch style {
        case .primary, .accent:
            return AppTheme.Colors.accent.opacity(0.3)
        case .secondary:
            return Color.black.opacity(0.1)
        case .destructive:
            return AppTheme.Colors.error.opacity(0.3)
        }
    }
}

// MARK: - Previews
#Preview("Button Styles") {
    ZStack {
        AppTheme.Colors.background
            .ignoresSafeArea()

        VStack(spacing: AppTheme.Spacing.large) {
            GlassButton("Primary Button", icon: "star.fill", style: .primary) {
                print("Primary tapped")
            }

            GlassButton("Secondary Button", icon: "heart", style: .secondary) {
                print("Secondary tapped")
            }

            GlassButton("Accent Button", icon: "sparkles", style: .accent) {
                print("Accent tapped")
            }

            GlassButton("Destructive", icon: "trash", style: .destructive) {
                print("Delete tapped")
            }

            GlassButton("Loading...", style: .primary, isLoading: true) {
                print("Loading")
            }
        }
        .padding()
    }
}
