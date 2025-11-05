//
//  SocotoApp.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import SwiftUI

@main
struct SocotoApp: App {
    // MARK: - State
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        // Validate configuration on app launch
        let missingKeys = Config.validateConfiguration()
        if !missingKeys.isEmpty {
            print("⚠️ Warning: Missing configuration keys: \(missingKeys.joined(separator: ", "))")
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isLoading {
                    // Loading state
                    LoadingView()
                } else if authViewModel.isAuthenticated {
                    // Authenticated - Show main app
                    TabBarView()
                        .environmentObject(authViewModel)
                } else {
                    // Not authenticated - Show welcome/auth flow
                    WelcomeView()
                        .environmentObject(authViewModel)
                }
            }
            .preferredColorScheme(.dark) // Force dark mode for glassmorphism effect
        }
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    AppTheme.Colors.primary,
                    AppTheme.Colors.secondary,
                    AppTheme.Colors.accent
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Loading Indicator
            VStack(spacing: AppTheme.Spacing.lg) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, AppTheme.Colors.glassLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
}
