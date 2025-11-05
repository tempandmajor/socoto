//
//  AuthenticationService.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import Foundation
import Combine
// import Supabase  // Uncomment after adding Supabase package
// import Auth       // Uncomment after adding Supabase package

/// Authentication service with role-based access control
@MainActor
final class AuthenticationService: ObservableObject {

    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var authError: AuthError?

    // MARK: - Singleton
    static let shared = AuthenticationService()

    // MARK: - Private Properties
    // private let supabaseClient: SupabaseClient  // Uncomment after adding package
    private var authStateSubscription: AnyCancellable?

    // MARK: - Initialization
    private init() {
        // Initialize Supabase client
        // Uncomment and configure after adding Supabase package:
        /*
        supabaseClient = SupabaseClient(
            supabaseURL: URL(string: Config.Supabase.url)!,
            supabaseKey: Config.Supabase.anonKey
        )
        */

        // Setup auth state listener
        setupAuthStateListener()
    }

    // MARK: - Authentication Methods

    /// Sign up a new user with email, password, and user type
    func signUp(email: String, password: String, fullName: String, userType: UserType) async throws {
        isLoading = true
        authError = nil

        defer { isLoading = false }

        do {
            // TODO: Implement after adding Supabase package
            /*
            let signUpData = UserSignUpData(
                email: email,
                password: password,
                fullName: fullName,
                userType: userType
            )

            let response = try await supabaseClient.auth.signUp(
                email: email,
                password: password,
                data: signUpData.metadata
            )

            // Fetch the created profile
            try await fetchCurrentUser(userId: response.user.id.uuidString)
            */

            throw AuthError.notImplemented
        } catch {
            authError = mapError(error)
            throw authError!
        }
    }

    /// Sign in with email and password
    func signIn(email: String, password: String) async throws {
        isLoading = true
        authError = nil

        defer { isLoading = false }

        do {
            // TODO: Implement after adding Supabase package
            /*
            let response = try await supabaseClient.auth.signIn(
                email: email,
                password: password
            )

            // Fetch user profile
            try await fetchCurrentUser(userId: response.user.id.uuidString)
            */

            throw AuthError.notImplemented
        } catch {
            authError = mapError(error)
            throw authError!
        }
    }

    /// Sign out current user
    func signOut() async throws {
        isLoading = true
        authError = nil

        defer { isLoading = false }

        do {
            // TODO: Implement after adding Supabase package
            /*
            try await supabaseClient.auth.signOut()
            */

            currentUser = nil
            isAuthenticated = false
        } catch {
            authError = mapError(error)
            throw authError!
        }
    }

    /// Reset password for email
    func resetPassword(email: String) async throws {
        isLoading = true
        authError = nil

        defer { isLoading = false }

        do {
            // TODO: Implement after adding Supabase package
            /*
            try await supabaseClient.auth.resetPasswordForEmail(email)
            */

            throw AuthError.notImplemented
        } catch {
            authError = mapError(error)
            throw authError!
        }
    }

    /// Update password for authenticated user
    func updatePassword(newPassword: String) async throws {
        guard isAuthenticated else {
            throw AuthError.notAuthenticated
        }

        isLoading = true
        authError = nil

        defer { isLoading = false }

        do {
            // TODO: Implement after adding Supabase package
            /*
            try await supabaseClient.auth.updateUser(
                attributes: UserAttributes(password: newPassword)
            )
            */

            throw AuthError.notImplemented
        } catch {
            authError = mapError(error)
            throw authError!
        }
    }

    // MARK: - User Profile Methods

    /// Fetch current user profile from database
    func fetchCurrentUser(userId: String) async throws {
        do {
            // TODO: Implement after adding Supabase package
            /*
            let user: User = try await supabaseClient
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value

            currentUser = user
            isAuthenticated = true
            */

            throw AuthError.notImplemented
        } catch {
            authError = mapError(error)
            throw authError!
        }
    }

    /// Update current user profile
    func updateProfile(_ updates: UserUpdateData) async throws {
        guard let userId = currentUser?.id else {
            throw AuthError.notAuthenticated
        }

        isLoading = true
        authError = nil

        defer { isLoading = false }

        do {
            // TODO: Implement after adding Supabase package
            /*
            try await supabaseClient
                .from("profiles")
                .update(updates)
                .eq("id", value: userId.uuidString)
                .execute()

            // Refresh user profile
            try await fetchCurrentUser(userId: userId.uuidString)
            */

            throw AuthError.notImplemented
        } catch {
            authError = mapError(error)
            throw authError!
        }
    }

    // MARK: - Role-Based Access Control

    /// Check if current user can manage businesses
    func canManageBusiness() -> Bool {
        return currentUser?.canManageBusiness ?? false
    }

    /// Check if current user is admin
    func isAdmin() -> Bool {
        return currentUser?.isAdmin ?? false
    }

    /// Check if user has specific user type
    func hasUserType(_ userType: UserType) -> Bool {
        return currentUser?.userType == userType
    }

    /// Require authentication, throw error if not authenticated
    func requireAuthentication() throws {
        guard isAuthenticated else {
            throw AuthError.notAuthenticated
        }
    }

    /// Require business owner privileges
    func requireBusinessOwner() throws {
        try requireAuthentication()
        guard canManageBusiness() else {
            throw AuthError.insufficientPermissions
        }
    }

    /// Require admin privileges
    func requireAdmin() throws {
        try requireAuthentication()
        guard isAdmin() else {
            throw AuthError.insufficientPermissions
        }
    }

    // MARK: - Private Methods

    private func setupAuthStateListener() {
        // TODO: Implement after adding Supabase package
        /*
        authStateSubscription = supabaseClient.auth.onAuthStateChange { [weak self] event, session in
            Task { @MainActor [weak self] in
                guard let self = self else { return }

                switch event {
                case .signedIn, .tokenRefreshed:
                    if let userId = session?.user.id.uuidString {
                        try? await self.fetchCurrentUser(userId: userId)
                    }

                case .signedOut:
                    self.currentUser = nil
                    self.isAuthenticated = false

                default:
                    break
                }
            }
        }
        */
    }

    private func mapError(_ error: Error) -> AuthError {
        // Map Supabase errors to our AuthError enum
        // TODO: Implement proper error mapping after adding Supabase package

        if let authError = error as? AuthError {
            return authError
        }

        return .unknown(error.localizedDescription)
    }
}

// MARK: - AuthError

enum AuthError: LocalizedError {
    case notAuthenticated
    case insufficientPermissions
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case invalidCredentials
    case networkError
    case notImplemented
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to perform this action"
        case .insufficientPermissions:
            return "You don't have permission to perform this action"
        case .invalidEmail:
            return "Please enter a valid email address"
        case .weakPassword:
            return "Password must be at least 8 characters with uppercase, lowercase, and numbers"
        case .emailAlreadyInUse:
            return "This email is already registered"
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Network connection error. Please try again"
        case .notImplemented:
            return "Supabase SDK not yet configured. Please add the Supabase Swift package"
        case .unknown(let message):
            return message
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to continue"
        case .insufficientPermissions:
            return "Contact support if you believe this is an error"
        case .invalidEmail:
            return "Check your email address and try again"
        case .weakPassword:
            return "Use a stronger password with mixed characters"
        case .emailAlreadyInUse:
            return "Try signing in instead, or use a different email"
        case .invalidCredentials:
            return "Double-check your email and password"
        case .networkError:
            return "Check your internet connection and try again"
        case .notImplemented:
            return "Add the Supabase Swift package to Package.swift"
        case .unknown:
            return "Please try again or contact support"
        }
    }
}

// MARK: - Validation Helpers

extension AuthenticationService {

    /// Validate email format
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    /// Validate password strength
    static func isValidPassword(_ password: String) -> Bool {
        // At least 8 characters, contains uppercase, lowercase, and number
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }

    /// Get password strength indicator
    static func passwordStrength(_ password: String) -> PasswordStrength {
        if password.isEmpty {
            return .none
        }

        var strength = 0

        // Check length
        if password.count >= 8 { strength += 1 }
        if password.count >= 12 { strength += 1 }

        // Check character types
        if password.range(of: "[a-z]", options: .regularExpression) != nil { strength += 1 }
        if password.range(of: "[A-Z]", options: .regularExpression) != nil { strength += 1 }
        if password.range(of: "[0-9]", options: .regularExpression) != nil { strength += 1 }
        if password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil { strength += 1 }

        switch strength {
        case 0...2:
            return .weak
        case 3...4:
            return .medium
        default:
            return .strong
        }
    }
}

// MARK: - PasswordStrength

enum PasswordStrength {
    case none
    case weak
    case medium
    case strong

    var displayText: String {
        switch self {
        case .none: return ""
        case .weak: return "Weak"
        case .medium: return "Medium"
        case .strong: return "Strong"
        }
    }

    var color: String {
        switch self {
        case .none: return "gray"
        case .weak: return "red"
        case .medium: return "orange"
        case .strong: return "green"
        }
    }
}
