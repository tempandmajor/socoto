//
//  SignInView.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import SwiftUI

struct SignInView: View {
    @StateObject private var authService = AuthenticationService.shared
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
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
                        Text("Socoto")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)

                        Text("Connect with your local community")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 60)

                    // Sign In Form
                    VStack(spacing: 20) {
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
                            .textContentType(.password)
                        }

                        // Forgot Password
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                // TODO: Navigate to forgot password
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                        }

                        // Sign In Button
                        Button(action: signIn) {
                            if authService.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Sign In")
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

                        // Sign Up Link
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.white.opacity(0.9))
                            Button("Sign Up") {
                                // TODO: Navigate to sign up
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
        .alert("Sign In Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let error = authService.authError {
                Text(error.localizedDescription)
            }
        }
    }

    private var isValidForm: Bool {
        !email.isEmpty && !password.isEmpty && AuthenticationService.isValidEmail(email)
    }

    private func signIn() {
        Task {
            do {
                try await authService.signIn(email: email, password: password)
            } catch {
                showError = true
            }
        }
    }
}

#Preview {
    SignInView()
}
