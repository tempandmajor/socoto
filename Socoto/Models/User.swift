//
//  User.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import Foundation

/// User profile model extending Supabase auth.users
struct User: Identifiable, Codable {
    let id: UUID
    var userType: UserType
    var fullName: String
    var avatarUrl: String?
    var bio: String?
    var phone: String?
    var locationLat: Double?
    var locationLng: Double?
    var address: String?
    var city: String?
    var state: String?
    var zipCode: String?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userType = "user_type"
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case bio
        case phone
        case locationLat = "location_lat"
        case locationLng = "location_lng"
        case address
        case city
        case state
        case zipCode = "zip_code"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    /// Check if user can manage businesses
    var canManageBusiness: Bool {
        return userType.canManageBusiness
    }

    /// Check if user is admin
    var isAdmin: Bool {
        return userType.isAdmin
    }

    /// Get user's full location string
    var fullLocation: String? {
        guard let city = city, let state = state else {
            return nil
        }
        return "\(city), \(state)"
    }

    /// Check if user has complete profile
    var isProfileComplete: Bool {
        return !fullName.isEmpty &&
               phone != nil &&
               city != nil &&
               state != nil
    }
}

// MARK: - User Creation Model
struct UserSignUpData: Codable {
    let email: String
    let password: String
    let fullName: String
    let userType: UserType

    var metadata: [String: Any] {
        return [
            "full_name": fullName,
            "user_type": userType.rawValue
        ]
    }
}

// MARK: - User Update Model
struct UserUpdateData: Codable {
    var fullName: String?
    var bio: String?
    var phone: String?
    var address: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case bio
        case phone
        case address
        case city
        case state
        case zipCode = "zip_code"
        case avatarUrl = "avatar_url"
    }
}
