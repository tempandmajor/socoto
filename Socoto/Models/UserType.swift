//
//  UserType.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import Foundation

/// User role type for role-based access control
enum UserType: String, Codable, CaseIterable {
    case user = "user"
    case businessOwner = "business_owner"
    case admin = "admin"

    var displayName: String {
        switch self {
        case .user:
            return "User"
        case .businessOwner:
            return "Business Owner"
        case .admin:
            return "Admin"
        }
    }

    var description: String {
        switch self {
        case .user:
            return "Standard user account with access to browse businesses, make bookings, and interact with content"
        case .businessOwner:
            return "Business account with ability to manage business profiles, campaigns, and bookings"
        case .admin:
            return "Administrator with full system access and moderation capabilities"
        }
    }

    /// Check if user has business owner privileges
    var canManageBusiness: Bool {
        return self == .businessOwner || self == .admin
    }

    /// Check if user has admin privileges
    var isAdmin: Bool {
        return self == .admin
    }
}
