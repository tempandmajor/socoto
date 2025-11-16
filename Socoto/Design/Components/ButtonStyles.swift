//
//  ButtonStyles.swift
//  Socoto
//
//  Reusable button styles following design system
//

import SwiftUI

// MARK: - Primary Button Style

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonMedium()
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.vertical, DesignTokens.Spacing.small)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.small)
                    .fill(
                        isEnabled
                            ? DesignTokens.Colors.brandPrimary
                            : DesignTokens.Colors.inkMuted.opacity(DesignTokens.Opacity.disabled)
                    )
            )
            .shadow(
                configuration.isPressed
                    ? DesignTokens.Shadow.subtle
                    : DesignTokens.Shadow.soft
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignTokens.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonMedium()
            .foregroundColor(DesignTokens.Colors.brandPrimary)
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.vertical, DesignTokens.Spacing.small)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.small)
                    .stroke(
                        isEnabled
                            ? DesignTokens.Colors.brandPrimary
                            : DesignTokens.Colors.inkMuted.opacity(DesignTokens.Opacity.disabled),
                        lineWidth: 2
                    )
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.small)
                            .fill(
                                configuration.isPressed
                                    ? DesignTokens.Colors.brandPrimary.opacity(DesignTokens.Opacity.hover)
                                    : Color.clear
                            )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignTokens.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Tertiary Button Style

struct TertiaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonSmall()
            .foregroundColor(DesignTokens.Colors.brandPrimary)
            .padding(.horizontal, DesignTokens.Spacing.medium)
            .padding(.vertical, DesignTokens.Spacing.xSmall)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.small)
                    .fill(
                        configuration.isPressed
                            ? DesignTokens.Colors.brandPrimary.opacity(DesignTokens.Opacity.hover)
                            : Color.clear
                    )
            )
            .opacity(isEnabled ? 1.0 : DesignTokens.Opacity.disabled)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(DesignTokens.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Pill Button Style

struct PillButtonStyle: ButtonStyle {
    var variant: Variant = .primary

    enum Variant {
        case primary
        case secondary
        case ghost
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonSmall()
            .padding(.horizontal, DesignTokens.Spacing.medium)
            .padding(.vertical, DesignTokens.Spacing.xSmall)
            .background(
                Capsule()
                    .fill(backgroundColor(configuration: configuration))
            )
            .foregroundColor(foregroundColor)
            .overlay(
                Capsule()
                    .stroke(borderColor, lineWidth: variant == .secondary ? 1.5 : 0)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(DesignTokens.Animation.quick, value: configuration.isPressed)
    }

    private func backgroundColor(configuration: Configuration) -> Color {
        switch variant {
        case .primary:
            return configuration.isPressed
                ? DesignTokens.Colors.brandPrimary.opacity(0.9)
                : DesignTokens.Colors.brandPrimary
        case .secondary:
            return configuration.isPressed
                ? DesignTokens.Colors.brandPrimary.opacity(DesignTokens.Opacity.hover)
                : Color.clear
        case .ghost:
            return configuration.isPressed
                ? DesignTokens.Colors.surfaceElevated
                : DesignTokens.Colors.surfacePage
        }
    }

    private var foregroundColor: Color {
        variant == .primary ? DesignTokens.Colors.inkContrast : DesignTokens.Colors.brandPrimary
    }

    private var borderColor: Color {
        variant == .secondary ? DesignTokens.Colors.brandPrimary : Color.clear
    }
}

// MARK: - Icon Button Style

struct IconButtonStyle: ButtonStyle {
    var size: CGFloat = 44
    var variant: Variant = .ghost

    enum Variant {
        case ghost
        case filled
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 20))
            .foregroundColor(
                variant == .filled
                    ? DesignTokens.Colors.inkContrast
                    : DesignTokens.Colors.inkPrimary
            )
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(backgroundColor(configuration: configuration))
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(DesignTokens.Animation.spring, value: configuration.isPressed)
    }

    private func backgroundColor(configuration: Configuration) -> Color {
        switch variant {
        case .ghost:
            return configuration.isPressed
                ? DesignTokens.Colors.surfaceElevated
                : Color.clear
        case .filled:
            return configuration.isPressed
                ? DesignTokens.Colors.brandPrimary.opacity(0.9)
                : DesignTokens.Colors.brandPrimary
        }
    }
}

// MARK: - Destructive Button Style

struct DestructiveButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .buttonMedium()
            .padding(.horizontal, DesignTokens.Spacing.large)
            .padding(.vertical, DesignTokens.Spacing.small)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.small)
                    .fill(
                        isEnabled
                            ? DesignTokens.Colors.statusErrorForeground
                            : DesignTokens.Colors.inkMuted.opacity(DesignTokens.Opacity.disabled)
                    )
            )
            .shadow(
                configuration.isPressed
                    ? DesignTokens.Shadow.subtle
                    : DesignTokens.Shadow.soft
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(DesignTokens.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    /// Apply primary button style
    func primaryButton() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }

    /// Apply secondary button style
    func secondaryButton() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }

    /// Apply tertiary button style
    func tertiaryButton() -> some View {
        self.buttonStyle(TertiaryButtonStyle())
    }

    /// Apply pill button style
    func pillButton(variant: PillButtonStyle.Variant = .primary) -> some View {
        self.buttonStyle(PillButtonStyle(variant: variant))
    }

    /// Apply icon button style
    func iconButton(size: CGFloat = 44, variant: IconButtonStyle.Variant = .ghost) -> some View {
        self.buttonStyle(IconButtonStyle(size: size, variant: variant))
    }

    /// Apply destructive button style
    func destructiveButton() -> some View {
        self.buttonStyle(DestructiveButtonStyle())
    }
}

// MARK: - Preview

#Preview("Button Styles") {
    ScrollView {
        VStack(spacing: DesignTokens.Spacing.large) {
            Text("Button Styles")
                .headlineLarge()

            VStack(spacing: DesignTokens.Spacing.medium) {
                Button("Primary Button") {}
                    .primaryButton()

                Button("Secondary Button") {}
                    .secondaryButton()

                Button("Tertiary Button") {}
                    .tertiaryButton()

                HStack(spacing: DesignTokens.Spacing.small) {
                    Button("Pill Primary") {}
                        .pillButton()

                    Button("Pill Secondary") {}
                        .pillButton(variant: .secondary)

                    Button("Pill Ghost") {}
                        .pillButton(variant: .ghost)
                }

                HStack(spacing: DesignTokens.Spacing.medium) {
                    Button {
                    } label: {
                        Image(systemName: "heart.fill")
                    }
                    .iconButton()

                    Button {
                    } label: {
                        Image(systemName: "star.fill")
                    }
                    .iconButton(variant: .filled)
                }

                Button("Destructive Action") {}
                    .destructiveButton()

                Button("Disabled Button") {}
                    .primaryButton()
                    .disabled(true)
            }
        }
        .padding(DesignTokens.Spacing.page)
    }
    .background(DesignTokens.Colors.surfacePage)
}
