//
//  SignUpView.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var fullName: String = ""
    @State private var selectedUserType: UserType = .user
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var showError: Bool = false

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    // Logo and Title
                    VStack(spacing: 16) {
                        Text("Create Account")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)

                        Text("Join your local community")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 40)

                    // Sign Up Form
                    VStack(spacing: 20) {
                        // Full Name Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))

                            TextField("", text: $fullName)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(.white)
                                .textContentType(.name)
                        }

                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))

                            TextField("", text: $email)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .foregroundColor(.white)
                                .textContentType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                        }

                        // User Type Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Account Type")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))

                            HStack(spacing: 12) {
                                ForEach([UserType.user, UserType.businessOwner], id: \.self) { userType in
                                    UserTypeButton(
                                        userType: userType,
                                        isSelected: selectedUserType == userType
                                    ) {
                                        selectedUserType = userType
                                    }
                                }
                            }
                        }

                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))

                            HStack {
                                if showPassword {
                                    TextField("", text: $password)
                                        .textFieldStyle(.plain)
                                } else {
                                    SecureField("", text: $password)
                                        .textFieldStyle(.plain)
                                }

                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.white)
                            .textContentType(.newPassword)

                            // Password Strength Indicator
                            if !password.isEmpty {
                                PasswordStrengthView(password: password)
                            }
                        }

                        // Confirm Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))

                            HStack {
                                if showConfirmPassword {
                                    TextField("", text: $confirmPassword)
                                        .textFieldStyle(.plain)
                                } else {
                                    SecureField("", text: $confirmPassword)
                                        .textFieldStyle(.plain)
                                }

                                Button(action: { showConfirmPassword.toggle() }) {
                                    Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.15))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .foregroundColor(.white)
                            .textContentType(.newPassword)

                            if !confirmPassword.isEmpty && password != confirmPassword {
                                Text("Passwords don't match")
                                    .font(.caption)
                                    .foregroundColor(.red.opacity(0.9))
                            }
                        }

                        // Sign Up Button
                        Button(action: signUp) {
                            if authService.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Create Account")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.25))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .disabled(authService.isLoading || !isValidForm)

                        // Sign In Link
                        HStack {
                            Text("Already have an account?")
                                .foregroundColor(.white.opacity(0.9))
                            Button("Sign In") {
                                // TODO: Navigate to sign in
                            }
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 32)
            }
        }
        .alert("Sign Up Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = authService.authError {
                Text(error.localizedDescription)
            }
        }
    }

    private var isValidForm: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        !fullName.isEmpty &&
        password == confirmPassword &&
        AuthenticationService.isValidEmail(email) &&
        AuthenticationService.isValidPassword(password)
    }

    private func signUp() {
        Task {
            do {
                try await authService.signUp(
                    email: email,
                    password: password,
                    fullName: fullName,
                    userType: selectedUserType
                )
            } catch {
                showError = true
            }
        }
    }
}

// MARK: - User Type Button

struct UserTypeButton: View {
    let userType: UserType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: userType == .user ? "person.fill" : "building.2.fill")
                    .font(.title2)

                Text(userType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.25) : Color.white.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .foregroundColor(.white)
        }
    }
}

// MARK: - Password Strength View

struct PasswordStrengthView: View {
    let password: String

    private var strength: PasswordStrength {
        AuthenticationService.passwordStrength(password)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(strength.displayText)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))

            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Rectangle()
                        .fill(barColor(for: index))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
        }
    }

    private func barColor(for index: Int) -> Color {
        switch strength {
        case .weak:
            return index == 0 ? .red : Color.white.opacity(0.2)
        case .medium:
            return index < 2 ? .orange : Color.white.opacity(0.2)
        case .strong:
            return .green
        default:
            return Color.white.opacity(0.2)
        }
    }
}

#Preview {
    SignUpView()
}
