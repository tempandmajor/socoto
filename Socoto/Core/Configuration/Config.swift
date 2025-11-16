//
//  Config.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import Foundation

/// Application configuration loaded from environment
enum Config {

    // MARK: - Supabase Configuration
    enum Supabase {
        static let url: String = getEnvVar("SUPABASE_URL")
        static let anonKey: String = getEnvVar("SUPABASE_ANON_KEY")

        // Storage bucket names
        enum StorageBuckets {
            static let userProfiles = "user-profiles"
            static let businessMedia = "business-media"
            static let postMedia = "post-media"
            static let messageAttachments = "message-attachments"
        }
    }

    // MARK: - Stripe Configuration (Client-Safe Keys Only)
    enum Stripe {
        static let publishableKey: String = getEnvVar("STRIPE_PUBLISHABLE_KEY")
        // Note: Secret key and webhook secret should ONLY be on backend server
    }

    // MARK: - App Configuration
    enum App {
        static let environment: String = getEnvVar("APP_ENV", defaultValue: "development")
    }

    // MARK: - Helper Methods
    private static func getEnvVar(_ key: String, defaultValue: String = "") -> String {
        // Try to get from Info.plist first (for production builds)
        if let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
           !value.isEmpty,
           !value.starts(with: "$(") {
            return value
        }

        // Try to get from ProcessInfo environment
        if let value = ProcessInfo.processInfo.environment[key], !value.isEmpty {
            return value
        }

        // Try to load from .env file (for development)
        if let envValue = loadFromEnvFile(key) {
            return envValue
        }

        return defaultValue
    }

    private static func loadFromEnvFile(_ key: String) -> String? {
        // Get the path to the project root (go up from bundle path)
        guard let projectPath = findProjectRoot() else {
            return nil
        }

        let envPath = projectPath + "/.env"

        guard let envContents = try? String(contentsOfFile: envPath, encoding: .utf8) else {
            return nil
        }

        let lines = envContents.components(separatedBy: .newlines)
        for line in lines {
            // Skip comments and empty lines
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.starts(with: "#") {
                continue
            }

            // Parse KEY=VALUE format
            let parts = line.split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                let lineKey = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                if lineKey == key {
                    return value
                }
            }
        }

        return nil
    }

    private static func findProjectRoot() -> String? {
        // Start from the bundle path and go up to find the project root
        var currentPath = Bundle.main.bundlePath

        // Remove /build/ and subsequent paths to get to project root
        if let range = currentPath.range(of: "/build/", options: .backwards) {
            currentPath = String(currentPath[..<range.lowerBound])
        }

        // If we're in a derived data path, try SOURCE_ROOT environment variable
        if currentPath.contains("DerivedData"),
           let sourceRoot = ProcessInfo.processInfo.environment["SOURCE_ROOT"] {
            return sourceRoot
        }

        return currentPath
    }

    // MARK: - Validation
    static func validateConfiguration() -> [String] {
        var missingKeys: [String] = []

        // Check Supabase (required)
        if Supabase.url.isEmpty { missingKeys.append("SUPABASE_URL") }
        if Supabase.anonKey.isEmpty { missingKeys.append("SUPABASE_ANON_KEY") }

        // Check Stripe (optional for basic features)
        if Stripe.publishableKey.isEmpty && App.environment == "production" {
            missingKeys.append("STRIPE_PUBLISHABLE_KEY")
        }

        return missingKeys
    }
}
