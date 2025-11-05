//
//  User.swift
//  Socoto
//
//  User and Profile data models
//

import Foundation

// MARK: - User Profile
struct Profile: Codable, Identifiable {
    let id: String
    let email: String
    let fullName: String
    let role: String
    let avatarUrl: String?
    let bio: String?
    let location: String?
    let phoneNumber: String?
    let preferences: UserPreferences?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case role
        case avatarUrl = "avatar_url"
        case bio
        case location
        case phoneNumber = "phone_number"
        case preferences
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var isBusinessOwner: Bool {
        role == "business_owner"
    }

    var displayName: String {
        fullName.isEmpty ? email : fullName
    }
}

// MARK: - User Preferences
struct UserPreferences: Codable {
    var categories: [String]?
    var notificationsEnabled: Bool?
    var locationSharingEnabled: Bool?
    var marketingEmailsEnabled: Bool?

    enum CodingKeys: String, CodingKey {
        case categories
        case notificationsEnabled = "notifications_enabled"
        case locationSharingEnabled = "location_sharing_enabled"
        case marketingEmailsEnabled = "marketing_emails_enabled"
    }
}

// MARK: - User Session
struct UserSession: Codable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    let user: SessionUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresAt = "expires_at"
        case user
    }
}

// MARK: - Session User (minimal user info from auth)
struct SessionUser: Codable {
    let id: String
    let email: String
    let emailVerified: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case emailVerified = "email_verified"
    }
}
