//
//  WelcomeView.swift
//  Socoto
//
//  Welcome/landing screen with glassmorphic design
//

import SwiftUI

struct WelcomeView: View {
    // MARK: - Environment
    @EnvironmentObject var authViewModel: AuthViewModel

    // MARK: - State
    @State private var showSignUp = false
    @State private var showSignIn = false
    @State private var showForgotPassword = false

    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                // Animated Gradient Background
                AnimatedGradientBackground()
                    .ignoresSafeArea()

                // Content
                VStack(spacing: 0) {
                    Spacer()

                    // Logo & Branding
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // App Icon
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            AppTheme.Colors.glassLight.opacity(0.3),
                                            AppTheme.Colors.glassLight.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .blur(radius: 20)

                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .font(.system(size: 80))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.white, AppTheme.Colors.glassLight],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        // App Name
                        Text("Socoto")
                            .font(AppTheme.Typography.displayLarge)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        // Tagline
                        Text("Connect with local businesses")
                            .font(AppTheme.Typography.titleMedium)
                            .foregroundColor(AppTheme.Colors.glassLight)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.xl)
                    }

                    Spacer()

                    // Features Preview
                    VStack(spacing: AppTheme.Spacing.md) {
                        FeatureRow(icon: "storefront.fill", text: "Discover local businesses")
                        FeatureRow(icon: "calendar.badge.clock", text: "Book appointments instantly")
                        FeatureRow(icon: "tag.fill", text: "Get exclusive deals")
                        FeatureRow(icon: "message.fill", text: "Chat with businesses")
                    }
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.bottom, AppTheme.Spacing.xl)

                    // Action Buttons
                    VStack(spacing: AppTheme.Spacing.md) {
                        GlassButton(
                            title: "Create Account",
                            icon: "arrow.right",
                            style: .primary,
                            action: {
                                showSignUp = true
                            }
                        )

                        GlassButton(
                            title: "Sign In",
                            icon: "person.fill",
                            style: .secondary,
                            action: {
                                showSignIn = true
                            }
                        )
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.bottom, AppTheme.Spacing.xxl)
                }
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $showSignIn) {
                SignInView()
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppTheme.Colors.accent)
                .frame(width: 32)

            Text(text)
                .font(AppTheme.Typography.bodyLarge)
                .foregroundColor(.white)

            Spacer()
        }
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: [
                AppTheme.Colors.primary,
                AppTheme.Colors.secondary,
                AppTheme.Colors.accent,
                AppTheme.Colors.primary
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(
                Animation
                    .easeInOut(duration: 5.0)
                    .repeatForever(autoreverses: true)
            ) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    WelcomeView()
        .environmentObject(AuthViewModel())
}
