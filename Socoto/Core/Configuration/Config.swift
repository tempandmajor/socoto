//
//  Config.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import Foundation

/// Application configuration loaded from environment
enum Config {

    // MARK: - AWS Configuration
    enum AWS {
        static let accessKeyId: String = getEnvVar("AWS_ACCESS_KEY_ID")
        static let secretAccessKey: String = getEnvVar("AWS_SECRET_ACCESS_KEY")
        static let region: String = getEnvVar("AWS_REGION", defaultValue: "us-east-2")

        // S3 Buckets
        static let userProfilesBucket: String = getEnvVar("S3_USER_PROFILES_BUCKET")
        static let businessMediaBucket: String = getEnvVar("S3_BUSINESS_MEDIA_BUCKET")
        static let postMediaBucket: String = getEnvVar("S3_POST_MEDIA_BUCKET")
        static let messageAttachmentsBucket: String = getEnvVar("S3_MESSAGE_ATTACHMENTS_BUCKET")
    }

    // MARK: - Supabase Configuration
    enum Supabase {
        static let projectId: String = getEnvVar("SUPABASE_PROJECT_ID")
        static let url: String = getEnvVar("SUPABASE_URL")
        static let anonKey: String = getEnvVar("SUPABASE_ANON_KEY")
        static let serviceRoleKey: String = getEnvVar("SUPABASE_SERVICE_ROLE_KEY")
    }

    // MARK: - Stripe Configuration
    enum Stripe {
        static let publishableKey: String = getEnvVar("STRIPE_PUBLISHABLE_KEY")
        static let secretKey: String = getEnvVar("STRIPE_SECRET_KEY")
        static let webhookSecret: String = getEnvVar("STRIPE_WEBHOOK_SECRET")
    }

    // MARK: - GitHub Configuration
    enum GitHub {
        static let token: String = getEnvVar("GITHUB_TOKEN")
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

        // If we're in a derived data path, go to the actual project
        if currentPath.contains("DerivedData") {
            // In development, try to use the SOURCE_ROOT environment variable
            if let sourceRoot = ProcessInfo.processInfo.environment["SOURCE_ROOT"] {
                return sourceRoot
            }

            // Fallback: Try common development paths
            let possiblePaths = [
                "/Users/emmanuelakangbou/CascadeProjects/Socoto",
                NSHomeDirectory() + "/CascadeProjects/Socoto"
            ]

            for path in possiblePaths {
                if FileManager.default.fileExists(atPath: path + "/.env") {
                    return path
                }
            }
        }

        return currentPath
    }

    // MARK: - Validation
    static func validateConfiguration() -> [String] {
        var missingKeys: [String] = []

        // Check AWS
        if AWS.accessKeyId.isEmpty { missingKeys.append("AWS_ACCESS_KEY_ID") }
        if AWS.secretAccessKey.isEmpty { missingKeys.append("AWS_SECRET_ACCESS_KEY") }

        // Check Supabase
        if Supabase.url.isEmpty { missingKeys.append("SUPABASE_URL") }
        if Supabase.anonKey.isEmpty { missingKeys.append("SUPABASE_ANON_KEY") }

        // Check Stripe
        if Stripe.publishableKey.isEmpty { missingKeys.append("STRIPE_PUBLISHABLE_KEY") }

        return missingKeys
    }
}
