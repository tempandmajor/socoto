//
//  SurfaceComponents.swift
//  Socoto
//
//  Surface components: cards, panels, and containers
//

import SwiftUI

// MARK: - Surface Card

/// Modern card component with elevation and shadows
struct SurfaceCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = DesignTokens.Spacing.medium
    var elevation: Elevation = .medium

    enum Elevation {
        case subtle
        case medium
        case high

        var shadow: ShadowStyle {
            switch self {
            case .subtle: return DesignTokens.Shadow.subtle
            case .medium: return DesignTokens.Shadow.soft
            case .high: return DesignTokens.Shadow.hard
            }
        }
    }

    init(
        padding: CGFloat = DesignTokens.Spacing.medium,
        elevation: Elevation = .medium,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.elevation = elevation
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(DesignTokens.Colors.surfaceElevated)
            .cornerRadius(DesignTokens.Radius.base)
            .shadow(elevation.shadow)
    }
}

// MARK: - Surface Panel

/// Panel component for grouping related content
struct SurfacePanel<Content: View>: View {
    let title: String?
    let content: Content
    var showDivider: Bool = true

    init(
        title: String? = nil,
        showDivider: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.showDivider = showDivider
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.medium) {
            if let title = title {
                Text(title)
                    .headlineSmall()
                    .padding(.horizontal, DesignTokens.Spacing.medium)
                    .padding(.top, DesignTokens.Spacing.medium)

                if showDivider {
                    Divider()
                        .background(DesignTokens.Colors.border)
                }
            }

            content
                .padding(.horizontal, DesignTokens.Spacing.medium)
                .padding(.bottom, DesignTokens.Spacing.medium)
        }
        .background(DesignTokens.Colors.surfaceElevated)
        .cornerRadius(DesignTokens.Radius.large)
        .shadow(DesignTokens.Shadow.soft)
    }
}

// MARK: - Glass Card (Glassmorphism)

/// Glassmorphic card with blur effect
struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = DesignTokens.Spacing.medium

    init(
        padding: CGFloat = DesignTokens.Spacing.medium,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    DesignTokens.Colors.surfaceElevated
                        .opacity(DesignTokens.Opacity.glass)

                    Color.white
                        .opacity(DesignTokens.Opacity.glass / 2)
                        .blur(radius: 10)
                }
            )
            .background(.ultraThinMaterial)
            .cornerRadius(DesignTokens.Radius.base)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.base)
                    .stroke(
                        Color.white.opacity(DesignTokens.Opacity.glassBorder),
                        lineWidth: 1
                    )
            )
            .shadow(DesignTokens.Shadow.soft)
    }
}

// MARK: - Summary Card

/// Card for displaying summary information with optional icon
struct SummaryCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String?
    let trend: Trend?

    enum Trend {
        case up(String)
        case down(String)
        case neutral(String)

        var color: Color {
            switch self {
            case .up: return DesignTokens.Colors.statusSuccessForeground
            case .down: return DesignTokens.Colors.statusErrorForeground
            case .neutral: return DesignTokens.Colors.inkSecondary
            }
        }

        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }

        var text: String {
            switch self {
            case .up(let value), .down(let value), .neutral(let value):
                return value
            }
        }
    }

    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String? = nil,
        trend: Trend? = nil
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.trend = trend
    }

    var body: some View {
        SurfaceCard {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                // Header
                HStack {
                    Text(title)
                        .labelLarge()

                    Spacer()

                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundColor(DesignTokens.Colors.brandPrimary)
                    }
                }

                // Value
                Text(value)
                    .headlineLarge()

                // Subtitle and Trend
                HStack(spacing: DesignTokens.Spacing.xSmall) {
                    if let trend = trend {
                        HStack(spacing: 2) {
                            Image(systemName: trend.icon)
                                .font(.system(size: 10, weight: .semibold))

                            Text(trend.text)
                                .labelSmall()
                        }
                        .foregroundColor(trend.color)
                    }

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .labelSmall(color: DesignTokens.Colors.inkTertiary)
                    }
                }
            }
        }
    }
}

// MARK: - List Item Surface

/// Styled list item with consistent formatting
struct ListItemSurface<Content: View>: View {
    let content: Content
    var showChevron: Bool = false
    var isFirst: Bool = false
    var isLast: Bool = false

    init(
        showChevron: Bool = false,
        isFirst: Bool = false,
        isLast: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.showChevron = showChevron
        self.isFirst = isFirst
        self.isLast = isLast
        self.content = content()
    }

    var body: some View {
        HStack {
            content

            Spacer()

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignTokens.Colors.inkTertiary)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.medium)
        .padding(.vertical, DesignTokens.Spacing.small)
        .background(DesignTokens.Colors.surfaceElevated)
        .cornerRadius(cornerRadius, corners: corners)
    }

    private var cornerRadius: CGFloat {
        if isFirst || isLast {
            return DesignTokens.Radius.medium
        }
        return 0
    }

    private var corners: UIRectCorner {
        if isFirst && isLast {
            return .allCorners
        } else if isFirst {
            return [.topLeft, .topRight]
        } else if isLast {
            return [.bottomLeft, .bottomRight]
        }
        return []
    }
}

// MARK: - Empty State Surface

/// Empty state component with icon and message
struct EmptyStateSurface: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(DesignTokens.Colors.inkTertiary)

            VStack(spacing: DesignTokens.Spacing.small) {
                Text(title)
                    .headlineSmall()
                    .multilineTextAlignment(.center)

                Text(message)
                    .bodyMedium()
                    .multilineTextAlignment(.center)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .primaryButton()
                    .frame(maxWidth: 200)
            }
        }
        .padding(DesignTokens.Spacing.xLarge)
    }
}

// MARK: - Helper Extensions

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview("Surface Components") {
    ScrollView {
        VStack(spacing: DesignTokens.Spacing.large) {
            Text("Surface Components")
                .headlineLarge()

            SurfaceCard {
                Text("Basic Surface Card")
                    .bodyMedium()
            }

            SurfacePanel(title: "Panel with Title") {
                Text("Panel content goes here")
                    .bodyMedium()
            }

            GlassCard {
                Text("Glassmorphic Card")
                    .bodyMedium()
            }

            SummaryCard(
                title: "Total Revenue",
                value: "$12,450",
                subtitle: "Last 30 days",
                icon: "dollarsign.circle.fill",
                trend: .up("+12.5%")
            )

            EmptyStateSurface(
                icon: "tray",
                title: "No Items",
                message: "You don't have any items yet. Start by adding your first item.",
                actionTitle: "Add Item",
                action: {}
            )
        }
        .padding(DesignTokens.Spacing.page)
    }
    .background(DesignTokens.Colors.surfacePage)
}
