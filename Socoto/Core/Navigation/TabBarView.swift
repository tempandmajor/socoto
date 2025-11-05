//
//  TabBarView.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import SwiftUI

/// Main tab bar navigation view
struct TabBarView: View {
    @State private var selectedTab: Tab = .home
    @Namespace private var animation

    enum Tab: String, CaseIterable {
        case home = "Home"
        case search = "Search"
        case messages = "Messages"
        case profile = "Profile"

        var icon: String {
            switch self {
            case .home: return "house"
            case .search: return "magnifyingglass"
            case .messages: return "message"
            case .profile: return "person"
            }
        }

        var selectedIcon: String {
            switch self {
            case .home: return "house.fill"
            case .search: return "magnifyingglass"
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
        case .home:
            HomeView()
        case .search:
            SearchView()
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
                        .font(.system(size: 20))
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

// MARK: - Tab Views
struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.large) {
                    // Header
                    HStack {
                        Text("Home")
                            .font(AppTheme.Typography.displaySmall)
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Spacer()

                        Button(action: {}) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppTheme.Colors.accent)
                        }
                    }
                    .padding(.horizontal)

                    // Sample posts
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

struct SearchView: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.large) {
                    // Header
                    Text("Search")
                        .font(AppTheme.Typography.displaySmall)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Search bar
                    GlassTextField(
                        text: $searchText,
                        placeholder: "Search businesses, events, or people..."
                    )

                    // Search categories
                    VStack(spacing: AppTheme.Spacing.medium) {
                        Text("Popular Categories")
                            .font(AppTheme.Typography.headlineSmall)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: AppTheme.Spacing.medium) {
                            ForEach(["Restaurants", "Events", "Services", "Retail"], id: \.self) { category in
                                GlassCard {
                                    VStack(spacing: AppTheme.Spacing.small) {
                                        Image(systemName: "building.2")
                                            .font(.system(size: 32))
                                            .foregroundColor(AppTheme.Colors.accent)

                                        Text(category)
                                            .font(AppTheme.Typography.titleMedium)
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                    }
                                    .padding()
                                }
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

struct MessagesView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.large) {
                    // Header
                    HStack {
                        Text("Messages")
                            .font(AppTheme.Typography.displaySmall)
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Spacer()

                        Button(action: {}) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.Colors.accent)
                        }
                    }
                    .padding(.horizontal)

                    // Sample conversations
                    ForEach(0..<6) { index in
                        GlassCard {
                            HStack(spacing: AppTheme.Spacing.medium) {
                                Circle()
                                    .fill(AppTheme.Colors.accent.opacity(0.3))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Text("B")
                                            .font(AppTheme.Typography.headlineSmall)
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Business Name \(index + 1)")
                                            .font(AppTheme.Typography.titleMedium)
                                            .foregroundColor(AppTheme.Colors.textPrimary)

                                        Spacer()

                                        Text("2h")
                                            .font(AppTheme.Typography.labelSmall)
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                    }

                                    Text("Last message preview goes here...")
                                        .font(AppTheme.Typography.bodyMedium)
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                        .lineLimit(1)
                                }

                                Spacer()
                            }
                            .padding(AppTheme.Spacing.small)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Navigate to conversation
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.large) {
                    // Profile header
                    GlassCard {
                        VStack(spacing: AppTheme.Spacing.medium) {
                            Circle()
                                .fill(AppTheme.Colors.accent.opacity(0.3))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text("U")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                )

                            Text("User Name")
                                .font(AppTheme.Typography.headlineSmall)
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Text("user@example.com")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.Colors.textSecondary)

                            GlassButton(title: "Edit Profile", action: {})
                                .padding(.top, AppTheme.Spacing.small)
                        }
                        .padding()
                    }

                    // Profile sections
                    VStack(spacing: AppTheme.Spacing.medium) {
                        ProfileMenuItem(icon: "person.circle", title: "Account Settings")
                        ProfileMenuItem(icon: "bell.fill", title: "Notifications")
                        ProfileMenuItem(icon: "lock.fill", title: "Privacy & Security")
                        ProfileMenuItem(icon: "heart.fill", title: "Saved Posts")
                        ProfileMenuItem(icon: "questionmark.circle", title: "Help & Support")
                        ProfileMenuItem(icon: "info.circle", title: "About")
                    }

                    // Logout button
                    GlassButton(title: "Logout", action: {})
                        .padding(.top, AppTheme.Spacing.medium)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Helper Views
struct ProfileMenuItem: View {
    let icon: String
    let title: String

    var body: some View {
        GlassCard {
            HStack(spacing: AppTheme.Spacing.medium) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.Colors.accent)
                    .frame(width: 24)

                Text(title)
                    .font(AppTheme.Typography.bodyLarge)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Navigate to detail view
        }
    }
}

// MARK: - Preview
#Preview {
    TabBarView()
}
