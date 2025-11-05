//
//  TabBarView.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import SwiftUI

/// Main tab bar navigation view
struct TabBarView: View {
    @State private var selectedTab: Tab = .feed
    @Namespace private var animation

    enum Tab: String, CaseIterable {
        case feed = "Feed"
        case discover = "Discover"
        case create = "Create"
        case messages = "Messages"
        case profile = "Profile"

        var icon: String {
            switch self {
            case .feed: return "house.fill"
            case .discover: return "safari.fill"
            case .create: return "plus.circle.fill"
            case .messages: return "message.fill"
            case .profile: return "person.fill"
            }
        }

        var selectedIcon: String {
            switch self {
            case .feed: return "house.fill"
            case .discover: return "safari.fill"
            case .create: return "plus.circle.fill"
            case .messages: return "message.fill"
            case .profile: return "person.fill"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Custom tab bar
            customTabBar
                .padding(.horizontal, AppTheme.Spacing.medium)
                .padding(.bottom, AppTheme.Spacing.small)
        }
        .background(
            LinearGradient(
                colors: [
                    AppTheme.Colors.background,
                    AppTheme.Colors.backgroundSecondary
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .feed:
            FeedView()
        case .discover:
            DiscoverView()
        case .create:
            CreateView()
        case .messages:
            MessagesView()
        case .profile:
            ProfileView()
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xSmall)
        .padding(.vertical, AppTheme.Spacing.small)
        .background(
            ZStack {
                Color.white.opacity(0.1)
                    .background(.ultraThinMaterial)

                LinearGradient(
                    colors: [
                        Color.white.opacity(0.1),
                        Color.white.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xLarge))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xLarge)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }

    private func tabButton(for tab: Tab) -> some View {
        Button(action: {
            withAnimation(AppTheme.Animation.spring) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: AppTheme.Spacing.xxSmall) {
                ZStack {
                    if selectedTab == tab {
                        // Selected background
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        AppTheme.Colors.accent.opacity(0.3),
                                        AppTheme.Colors.accent.opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 36)
                            .shadow(color: AppTheme.Colors.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                            .matchedGeometryEffect(id: "tab_background", in: animation)
                    }

                    Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                        .font(.system(size: tab == .create ? 28 : 20))
                        .foregroundColor(
                            selectedTab == tab
                                ? AppTheme.Colors.textPrimary
                                : AppTheme.Colors.textSecondary
                        )
                        .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                }

                if selectedTab == tab {
                    Text(tab.rawValue)
                        .font(AppTheme.Typography.labelSmall)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .transition(.opacity)
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Placeholder Views
struct FeedView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.large) {
                    Text("Feed")
                        .font(AppTheme.Typography.displaySmall)
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    ForEach(0..<5) { index in
                        GlassCard {
                            VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
                                HStack {
                                    Circle()
                                        .fill(AppTheme.Colors.accent.opacity(0.3))
                                        .frame(width: 40, height: 40)

                                    VStack(alignment: .leading) {
                                        Text("Business Name")
                                            .font(AppTheme.Typography.titleMedium)
                                            .foregroundColor(AppTheme.Colors.textPrimary)

                                        Text("2 hours ago")
                                            .font(AppTheme.Typography.labelSmall)
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                    }

                                    Spacer()
                                }

                                Text("This is a sample post in the feed. The glassmorphic design creates a beautiful, modern interface.")
                                    .font(AppTheme.Typography.bodyMedium)
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DiscoverView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.large) {
                    Text("Discover")
                        .font(AppTheme.Typography.displaySmall)
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text("Explore local businesses")
                        .font(AppTheme.Typography.bodyLarge)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding()
            }
        }
    }
}

struct CreateView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: AppTheme.Spacing.large) {
                Text("Create Post")
                    .font(AppTheme.Typography.displaySmall)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("Share something with your community")
                    .font(AppTheme.Typography.bodyLarge)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding()
        }
    }
}

struct MessagesView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.large) {
                    Text("Messages")
                        .font(AppTheme.Typography.displaySmall)
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text("Your conversations")
                        .font(AppTheme.Typography.bodyLarge)
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
                .padding()
            }
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.large) {
                    Text("Profile")
                        .font(AppTheme.Typography.displaySmall)
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    GlassCard {
                        VStack(spacing: AppTheme.Spacing.medium) {
                            Circle()
                                .fill(AppTheme.Colors.accent.opacity(0.3))
                                .frame(width: 80, height: 80)

                            Text("User Name")
                                .font(AppTheme.Typography.headlineSmall)
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Text("user@example.com")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    TabBarView()
}
