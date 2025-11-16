//
//  StatusComponents.swift
//  Socoto
//
//  Status badges and indicators
//

import SwiftUI

// MARK: - Status Pill

/// Status pill/badge component
struct StatusPill: View {
    let text: String
    let status: Status

    enum Status {
        case success
        case warning
        case error
        case info
        case pending
        case custom(background: Color, foreground: Color)

        var backgroundColor: Color {
            switch self {
            case .success: return DesignTokens.Colors.statusSuccessBackground
            case .warning: return DesignTokens.Colors.statusWarningBackground
            case .error: return DesignTokens.Colors.statusErrorBackground
            case .info: return DesignTokens.Colors.statusInfoBackground
            case .pending: return DesignTokens.Colors.statusPendingBackground
            case .custom(let bg, _): return bg
            }
        }

        var foregroundColor: Color {
            switch self {
            case .success: return DesignTokens.Colors.statusSuccessForeground
            case .warning: return DesignTokens.Colors.statusWarningForeground
            case .error: return DesignTokens.Colors.statusErrorForeground
            case .info: return DesignTokens.Colors.statusInfoForeground
            case .pending: return DesignTokens.Colors.statusPendingForeground
            case .custom(_, let fg): return fg
            }
        }

        var icon: String? {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            case .pending: return "clock.fill"
            case .custom: return nil
            }
        }
    }

    var showIcon: Bool = true

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xxSmall) {
            if showIcon, let icon = status.icon {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
            }

            Text(text)
                .labelSmall()
        }
        .foregroundColor(status.foregroundColor)
        .padding(.horizontal, DesignTokens.Spacing.small)
        .padding(.vertical, DesignTokens.Spacing.xxSmall)
        .background(
            Capsule()
                .fill(status.backgroundColor)
        )
    }
}

// MARK: - Dot Indicator

/// Small colored dot indicator
struct DotIndicator: View {
    let status: StatusPill.Status
    var size: CGFloat = 8

    var body: some View {
        Circle()
            .fill(status.foregroundColor)
            .frame(width: size, height: size)
    }
}

// MARK: - Status Banner

/// Full-width status banner for important messages
struct StatusBanner: View {
    let message: String
    let status: StatusPill.Status
    let dismissAction: (() -> Void)?

    @State private var isVisible = true

    init(
        message: String,
        status: StatusPill.Status,
        dismissAction: (() -> Void)? = nil
    ) {
        self.message = message
        self.status = status
        self.dismissAction = dismissAction
    }

    var body: some View {
        if isVisible {
            HStack(spacing: DesignTokens.Spacing.small) {
                if let icon = status.icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(message)
                    .bodySmall()

                Spacer()

                if dismissAction != nil {
                    Button {
                        withAnimation(DesignTokens.Animation.medium) {
                            isVisible = false
                            dismissAction?()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
            }
            .foregroundColor(status.foregroundColor)
            .padding(DesignTokens.Spacing.medium)
            .background(status.backgroundColor)
            .cornerRadius(DesignTokens.Radius.medium)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Progress Indicator

/// Linear progress indicator
struct ProgressIndicator: View {
    let progress: Double // 0.0 to 1.0
    var height: CGFloat = 4
    var color: Color = DesignTokens.Colors.brandPrimary
    var backgroundColor: Color = DesignTokens.Colors.border

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                    .frame(height: height)

                // Progress
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(color)
                    .frame(width: geometry.size.width * CGFloat(min(max(progress, 0), 1)), height: height)
                    .animation(DesignTokens.Animation.medium, value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Loading Spinner

/// Activity indicator / loading spinner
struct LoadingSpinner: View {
    var size: CGFloat = 24
    var color: Color = DesignTokens.Colors.brandPrimary

    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: color))
            .scaleEffect(size / 24)
            .frame(width: size, height: size)
    }
}

// MARK: - Skeleton Loader

/// Skeleton loading placeholder
struct SkeletonLoader: View {
    var width: CGFloat? = nil
    var height: CGFloat = 16
    var cornerRadius: CGFloat = DesignTokens.Radius.xSmall

    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: [
                        DesignTokens.Colors.border,
                        DesignTokens.Colors.borderSubtle,
                        DesignTokens.Colors.border
                    ],
                    startPoint: isAnimating ? .leading : .trailing,
                    endPoint: isAnimating ? .trailing : .leading
                )
            )
            .frame(width: width, height: height)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - Badge

/// Notification badge (e.g., count indicator)
struct Badge: View {
    let count: Int
    var size: CGFloat = 18

    var body: some View {
        if count > 0 {
            Text(count > 99 ? "99+" : "\(count)")
                .font(.system(size: size * 0.55, weight: .semibold))
                .foregroundColor(DesignTokens.Colors.inkContrast)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(DesignTokens.Colors.statusErrorForeground)
                )
        }
    }
}

// MARK: - Preview

#Preview("Status Components") {
    ScrollView {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
            Text("Status Components")
                .headlineLarge()

            // Status Pills
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                Text("Status Pills")
                    .headlineSmall()

                HStack(spacing: DesignTokens.Spacing.small) {
                    StatusPill(text: "Success", status: .success)
                    StatusPill(text: "Warning", status: .warning)
                    StatusPill(text: "Error", status: .error)
                }

                HStack(spacing: DesignTokens.Spacing.small) {
                    StatusPill(text: "Info", status: .info)
                    StatusPill(text: "Pending", status: .pending)
                }
            }

            // Dot Indicators
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                Text("Dot Indicators")
                    .headlineSmall()

                HStack(spacing: DesignTokens.Spacing.medium) {
                    HStack(spacing: DesignTokens.Spacing.xxSmall) {
                        DotIndicator(status: .success)
                        Text("Online").bodySmall()
                    }

                    HStack(spacing: DesignTokens.Spacing.xxSmall) {
                        DotIndicator(status: .error)
                        Text("Offline").bodySmall()
                    }

                    HStack(spacing: DesignTokens.Spacing.xxSmall) {
                        DotIndicator(status: .warning)
                        Text("Away").bodySmall()
                    }
                }
            }

            // Status Banner
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                Text("Status Banners")
                    .headlineSmall()

                StatusBanner(
                    message: "Your changes have been saved successfully",
                    status: .success,
                    dismissAction: {}
                )

                StatusBanner(
                    message: "Please verify your email address",
                    status: .warning
                )

                StatusBanner(
                    message: "An error occurred. Please try again.",
                    status: .error,
                    dismissAction: {}
                )
            }

            // Progress Indicators
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                Text("Progress Indicators")
                    .headlineSmall()

                ProgressIndicator(progress: 0.3)
                ProgressIndicator(progress: 0.65, color: DesignTokens.Colors.statusSuccessForeground)
                ProgressIndicator(progress: 0.9, height: 8)
            }

            // Loading States
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                Text("Loading States")
                    .headlineSmall()

                HStack(spacing: DesignTokens.Spacing.medium) {
                    LoadingSpinner()
                    LoadingSpinner(size: 32)
                    LoadingSpinner(size: 48, color: DesignTokens.Colors.statusSuccessForeground)
                }

                SkeletonLoader(width: 200)
                SkeletonLoader(width: 150, height: 20)
                SkeletonLoader(width: 100, height: 40, cornerRadius: DesignTokens.Radius.small)
            }

            // Badges
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                Text("Badges")
                    .headlineSmall()

                HStack(spacing: DesignTokens.Spacing.medium) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 32))
                            .foregroundColor(DesignTokens.Colors.inkPrimary)

                        Badge(count: 3)
                            .offset(x: 4, y: -4)
                    }

                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 32))
                            .foregroundColor(DesignTokens.Colors.inkPrimary)

                        Badge(count: 128)
                            .offset(x: 4, y: -4)
                    }
                }
            }
        }
        .padding(DesignTokens.Spacing.page)
    }
    .background(DesignTokens.Colors.surfacePage)
}
