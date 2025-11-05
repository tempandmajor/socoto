//
//  SignInView.swift
//  Socoto
//
//  Sign in screen with glassmorphic design
//

import SwiftUI

struct SignInView: View {
    // MARK: - Environment
    @EnvironmentObject var authViewModel: AuthViewModel

    // MARK: - State
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showForgotPassword = false
    @FocusState private var focusedField: Field?

    // MARK: - Navigation
    @Environment(\.dismiss) var dismiss

    enum Field: Hashable {
        case email
        case password
    }

    // MARK: - Body
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

            // Content
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xl) {
                    // Header
                    VStack(spacing: AppTheme.Spacing.md) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, AppTheme.Colors.glassLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.top, AppTheme.Spacing.xl)

                        Text("Welcome Back")
                            .font(AppTheme.Typography.displayLarge)
                            .foregroundColor(.white)

                        Text("Sign in to continue")
                            .font(AppTheme.Typography.bodyLarge)
                            .foregroundColor(AppTheme.Colors.glassLight)
                    }
                    .padding(.bottom, AppTheme.Spacing.lg)

                    // Sign In Form
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Email Field
                        GlassTextField(
                            text: $email,
                            placeholder: "Email",
                            icon: "envelope.fill",
                            type: .email
                        )
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit {
                            focusedField = .password
                        }

                        // Password Field
                        GlassTextField(
                            text: $password,
                            placeholder: "Password",
                            icon: "lock.fill",
                            type: .password
                        )
                        .focused($focusedField, equals: .password)
                        .submitLabel(.go)
                        .onSubmit {
                            signIn()
                        }

                        // Forgot Password
                        HStack {
                            Spacer()
                            Button(action: {
                                showForgotPassword = true
                            }) {
                                Text("Forgot Password?")
                                    .font(AppTheme.Typography.labelMedium)
                                    .foregroundColor(.white)
                            }
                        }

                        // Error Message
                        if let errorMessage = authViewModel.errorMessage {
                            Text(errorMessage)
                                .font(AppTheme.Typography.labelMedium)
                                .foregroundColor(AppTheme.Colors.error)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        // Sign In Button
                        GlassButton(
                            title: "Sign In",
                            icon: "arrow.right",
                            style: .primary,
                            isLoading: authViewModel.isLoading,
                            action: signIn
                        )
                        .padding(.top, AppTheme.Spacing.sm)

                        // Divider
                        HStack {
                            Rectangle()
                                .fill(AppTheme.Colors.glassBorder)
                                .frame(height: 1)
                            Text("OR")
                                .font(AppTheme.Typography.labelSmall)
                                .foregroundColor(AppTheme.Colors.glassLight)
                                .padding(.horizontal, AppTheme.Spacing.md)
                            Rectangle()
                                .fill(AppTheme.Colors.glassBorder)
                                .frame(height: 1)
                        }
                        .padding(.vertical, AppTheme.Spacing.sm)

                        // Social Sign In (Future)
                        VStack(spacing: AppTheme.Spacing.md) {
                            GlassButton(
                                title: "Continue with Apple",
                                icon: "apple.logo",
                                style: .secondary,
                                action: {
                                    // TODO: Implement Apple Sign In
                                }
                            )

                            GlassButton(
                                title: "Continue with Google",
                                icon: "globe",
                                style: .secondary,
                                action: {
                                    // TODO: Implement Google Sign In
                                }
                            )
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)

                    // Sign Up Link
                    HStack(spacing: AppTheme.Spacing.xs) {
                        Text("Don't have an account?")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.Colors.glassLight)

                        Button(action: {
                            dismiss()
                        }) {
                            Text("Sign Up")
                                .font(AppTheme.Typography.bodyMedium)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, AppTheme.Spacing.md)
                }
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
                .environmentObject(authViewModel)
        }
        .onAppear {
            authViewModel.clearMessages()
        }
    }

    // MARK: - Actions
    private func signIn() {
        focusedField = nil

        Task {
            await authViewModel.signIn(email: email, password: password)
        }
    }
}

// MARK: - Preview
#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
}
