//
//  ForgotPasswordView.swift
//  Socoto
//
//  Password reset screen with glassmorphic design
//

import SwiftUI

struct ForgotPasswordView: View {
    // MARK: - Environment
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    // MARK: - State
    @State private var email = ""
    @FocusState private var isEmailFocused: Bool

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
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, AppTheme.Colors.glassLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.top, AppTheme.Spacing.xl)

                        Text("Reset Password")
                            .font(AppTheme.Typography.displayLarge)
                            .foregroundColor(.white)

                        Text("Enter your email address and we'll send you a link to reset your password")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.Colors.glassLight)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppTheme.Spacing.lg)
                    }
                    .padding(.bottom, AppTheme.Spacing.lg)

                    // Reset Form
                    VStack(spacing: AppTheme.Spacing.lg) {
                        // Email Field
                        GlassTextField(
                            text: $email,
                            placeholder: "Email",
                            icon: "envelope.fill",
                            type: .email
                        )
                        .focused($isEmailFocused)
                        .submitLabel(.send)
                        .onSubmit {
                            resetPassword()
                        }

                        // Error Message
                        if let errorMessage = authViewModel.errorMessage {
                            Text(errorMessage)
                                .font(AppTheme.Typography.labelMedium)
                                .foregroundColor(AppTheme.Colors.error)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }

                        // Success Message
                        if let successMessage = authViewModel.successMessage {
                            VStack(spacing: AppTheme.Spacing.md) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppTheme.Colors.success)

                                Text(successMessage)
                                    .font(AppTheme.Typography.labelMedium)
                                    .foregroundColor(AppTheme.Colors.success)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)

                                GlassButton(
                                    title: "Back to Sign In",
                                    icon: "arrow.left",
                                    style: .secondary,
                                    action: {
                                        dismiss()
                                    }
                                )
                                .padding(.top, AppTheme.Spacing.sm)
                            }
                        } else {
                            // Send Reset Link Button
                            GlassButton(
                                title: "Send Reset Link",
                                icon: "paperplane.fill",
                                style: .primary,
                                isLoading: authViewModel.isLoading,
                                action: resetPassword
                            )
                            .padding(.top, AppTheme.Spacing.sm)
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.lg)

                    // Back Button
                    if authViewModel.successMessage == nil {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack(spacing: AppTheme.Spacing.xs) {
                                Image(systemName: "arrow.left")
                                Text("Back to Sign In")
                            }
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(.white)
                        }
                        .padding(.top, AppTheme.Spacing.md)
                    }
                }
                .padding(.bottom, AppTheme.Spacing.xxl)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            authViewModel.clearMessages()
        }
    }

    // MARK: - Actions
    private func resetPassword() {
        isEmailFocused = false

        Task {
            await authViewModel.resetPassword(email: email)
        }
    }
}

// MARK: - Preview
#Preview {
    ForgotPasswordView()
        .environmentObject(AuthViewModel())
}
