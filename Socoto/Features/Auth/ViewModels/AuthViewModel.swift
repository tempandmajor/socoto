//
//  AuthViewModel.swift
//  Socoto
//
//  Authentication state management and business logic
//

import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // MARK: - Private Properties
    private let supabaseService = SupabaseService.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init() {
        checkAuthStatus()
    }

    // MARK: - Auth Status
    func checkAuthStatus() {
        isLoading = true

        Task {
            do {
                // Check if there's an active session
                if let userId = try await supabaseService.getCurrentSession() {
                    // Fetch user profile
                    let profile = try await supabaseService.fetchProfile(userId: userId)
                    self.currentUser = profile
                    self.isAuthenticated = true
                }
            } catch {
                print("Auth check error: \(error.localizedDescription)")
                self.isAuthenticated = false
            }

            self.isLoading = false
        }
    }

    // MARK: - Sign In
    func signIn(email: String, password: String) async {
        // Validation
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }

        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            return
        }

        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let userId = try await supabaseService.signIn(email: email, password: password)

            // Fetch user profile after sign in
            let profile = try await supabaseService.fetchProfile(userId: userId)
            self.currentUser = profile
            self.isAuthenticated = true
        } catch {
            self.errorMessage = "Sign in failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String, fullName: String, role: UserRole) async {
        // Validation
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }

        guard !fullName.isEmpty else {
            errorMessage = "Please enter your full name"
            return
        }

        guard !password.isEmpty else {
            errorMessage = "Please enter a password"
            return
        }

        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }

        guard password.count >= 8 else {
            errorMessage = "Password must be at least 8 characters"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let userId = try await supabaseService.signUp(
                email: email,
                password: password,
                fullName: fullName,
                role: role.rawValue
            )

            // Show success message
            self.successMessage = "Account created! Please check your email to verify your account."

            // Fetch user profile
            let profile = try await supabaseService.fetchProfile(userId: userId)
            self.currentUser = profile
            self.isAuthenticated = true
        } catch {
            self.errorMessage = "Sign up failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Sign Out
    func signOut() async {
        isLoading = true

        do {
            try await supabaseService.signOut()
            self.isAuthenticated = false
            self.currentUser = nil
        } catch {
            self.errorMessage = "Sign out failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Password Reset
    func resetPassword(email: String) async {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return
        }

        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            try await supabaseService.resetPassword(email: email)
            self.successMessage = "Password reset email sent! Check your inbox."
        } catch {
            self.errorMessage = "Password reset failed: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Validation Helpers
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    // MARK: - Clear Messages
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}

// MARK: - User Role Enum
enum UserRole: String, CaseIterable {
    case user = "user"
    case businessOwner = "business_owner"

    var displayName: String {
        switch self {
        case .user:
            return "User"
        case .businessOwner:
            return "Business Owner"
        }
    }

    var description: String {
        switch self {
        case .user:
            return "Discover and book local businesses"
        case .businessOwner:
            return "Manage your business profile and bookings"
        }
    }

    var icon: String {
        switch self {
        case .user:
            return "person.fill"
        case .businessOwner:
            return "storefront.fill"
        }
    }
}
