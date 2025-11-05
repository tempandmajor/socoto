//
//  SignUpView.swift
//  Socoto
//
//  Sign up screen with role selection and glassmorphic design
//

import SwiftUI

struct SignUpView: View {
    // MARK: - Environment
    @EnvironmentObject var authViewModel: AuthViewModel

    // MARK: - State
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole: UserRole = .user
    @State private var acceptedTerms = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showSignIn = false
    @FocusState private var focusedField: Field?

    enum Field: Hashable {
        case fullName
        case email
        case password
        case confirmPassword
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
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

                            Text("Create Account")
                                .font(AppTheme.Typography.displayLarge)
                                .foregroundColor(.white)

                            Text("Join Socoto today")
                                .font(AppTheme.Typography.bodyLarge)
                                .foregroundColor(AppTheme.Colors.glassLight)
                        }
                        .padding(.bottom, AppTheme.Spacing.lg)

                        // Role Selection
                        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                            Text("I am a...")
                                .font(AppTheme.Typography.titleMedium)
                                .foregroundColor(.white)
                                .padding(.horizontal, AppTheme.Spacing.lg)

                            HStack(spacing: AppTheme.Spacing.md) {
                                ForEach(UserRole.allCases, id: \.self) { role in
                                    RoleSelectionCard(
                                        role: role,
                                        isSelected: selectedRole == role,
                                        action: {
                                            withAnimation(AppTheme.Animation.spring) {
                                                selectedRole = role
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, AppTheme.Spacing.lg)
                        }

                        // Sign Up Form
                        VStack(spacing: AppTheme.Spacing.lg) {
                            // Full Name Field
                            GlassTextField(
                                text: $fullName,
                                placeholder: "Full Name",
                                icon: "person.fill",
                                type: .text
                            )
                            .focused($focusedField, equals: .fullName)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .email
                            }

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
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .confirmPassword
                            }

                            // Confirm Password Field
                            GlassTextField(
                                text: $confirmPassword,
                                placeholder: "Confirm Password",
                                icon: "lock.fill",
                                type: .password,
                                errorMessage: passwordMismatchError
                            )
                            .focused($focusedField, equals: .confirmPassword)
                            .submitLabel(.go)
                            .onSubmit {
                                signUp()
                            }

                            // Terms & Conditions
                            HStack(alignment: .top, spacing: AppTheme.Spacing.md) {
                                Button(action: {
                                    acceptedTerms.toggle()
                                }) {
                                    Image(systemName: acceptedTerms ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 24))
                                        .foregroundColor(acceptedTerms ? AppTheme.Colors.accent : .white.opacity(0.7))
                                }

                                Text("I agree to the Terms of Service and Privacy Policy")
                                    .font(AppTheme.Typography.labelMedium)
                                    .foregroundColor(AppTheme.Colors.glassLight)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.top, AppTheme.Spacing.sm)

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
                                Text(successMessage)
                                    .font(AppTheme.Typography.labelMedium)
                                    .foregroundColor(AppTheme.Colors.success)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }

                            // Sign Up Button
                            GlassButton(
                                title: "Create Account",
                                icon: "arrow.right",
                                style: .primary,
                                isLoading: authViewModel.isLoading,
                                action: signUp
                            )
                            .disabled(!acceptedTerms)
                            .opacity(acceptedTerms ? 1.0 : 0.5)
                            .padding(.top, AppTheme.Spacing.sm)
                        }
                        .padding(.horizontal, AppTheme.Spacing.lg)

                        // Sign In Link
                        HStack(spacing: AppTheme.Spacing.xs) {
                            Text("Already have an account?")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundColor(AppTheme.Colors.glassLight)

                            Button(action: {
                                showSignIn = true
                            }) {
                                Text("Sign In")
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
            .sheet(isPresented: $showSignIn) {
                SignInView()
                    .environmentObject(authViewModel)
            }
            .onAppear {
                authViewModel.clearMessages()
            }
        }
    }

    // MARK: - Computed Properties
    private var passwordMismatchError: String? {
        if !confirmPassword.isEmpty && password != confirmPassword {
            return "Passwords do not match"
        }
        return nil
    }

    // MARK: - Actions
    private func signUp() {
        // Validate password match
        guard password == confirmPassword else {
            authViewModel.errorMessage = "Passwords do not match"
            return
        }

        guard acceptedTerms else {
            authViewModel.errorMessage = "Please accept the Terms of Service"
            return
        }

        focusedField = nil

        Task {
            await authViewModel.signUp(
                email: email,
                password: password,
                fullName: fullName,
                role: selectedRole
            )
        }
    }
}

// MARK: - Role Selection Card
struct RoleSelectionCard: View {
    let role: UserRole
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.md) {
                // Icon
                Image(systemName: role.icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? AppTheme.Colors.accent : .white)

                // Title
                Text(role.displayName)
                    .font(AppTheme.Typography.titleSmall)
                    .foregroundColor(.white)

                // Description
                Text(role.description)
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundColor(AppTheme.Colors.glassLight)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(AppTheme.Spacing.lg)
            .background(
                GlassmorphicModifier(
                    blurRadius: 20,
                    opacity: isSelected ? 0.3 : 0.2,
                    borderOpacity: isSelected ? 0.5 : 0.3
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.large)
                    .stroke(
                        isSelected ? AppTheme.Colors.accent : Color.clear,
                        lineWidth: 2
                    )
            )
            .cornerRadius(AppTheme.CornerRadius.large)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
