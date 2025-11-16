//
//  SupabaseStorageService.swift
//  Socoto
//
//  Supabase Storage service for secure media uploads
//

import Foundation
import UIKit
import Supabase

/// Service for handling media uploads to Supabase Storage
final class SupabaseStorageService {

    // MARK: - Singleton
    static let shared = SupabaseStorageService()

    // MARK: - Properties
    private let client: SupabaseClient

    // Storage buckets
    enum Bucket: String {
        case userProfiles = "user-profiles"
        case businessMedia = "business-media"
        case postMedia = "post-media"
        case messageAttachments = "message-attachments"
    }

    // MARK: - Errors
    enum StorageError: LocalizedError {
        case invalidImage
        case uploadFailed(Error)
        case downloadFailed(Error)
        case deleteFailed(Error)
        case invalidURL
        case fileTooLarge(maxSize: Int)
        case unsupportedFileType

        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "Invalid image data"
            case .uploadFailed(let error):
                return "Upload failed: \(error.localizedDescription)"
            case .downloadFailed(let error):
                return "Download failed: \(error.localizedDescription)"
            case .deleteFailed(let error):
                return "Delete failed: \(error.localizedDescription)"
            case .invalidURL:
                return "Invalid file URL"
            case .fileTooLarge(let maxSize):
                return "File too large. Maximum size: \(maxSize / 1_000_000)MB"
            case .unsupportedFileType:
                return "Unsupported file type"
            }
        }
    }

    // MARK: - Initialization
    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: Config.Supabase.url)!,
            supabaseKey: Config.Supabase.anonKey
        )
    }

    // MARK: - Public Methods

    /// Upload an image to Supabase Storage
    /// - Parameters:
    ///   - image: UIImage to upload
    ///   - bucket: Target storage bucket
    ///   - path: File path in bucket
    ///   - maxSize: Maximum file size in bytes (default: 5MB)
    /// - Returns: Public URL of uploaded image
    func uploadImage(
        _ image: UIImage,
        to bucket: Bucket,
        path: String,
        maxSize: Int = 5_000_000
    ) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidImage
        }

        // Validate file size
        guard imageData.count <= maxSize else {
            throw StorageError.fileTooLarge(maxSize: maxSize)
        }

        return try await uploadData(imageData, to: bucket, path: path, contentType: "image/jpeg")
    }

    /// Upload data to Supabase Storage
    /// - Parameters:
    ///   - data: Data to upload
    ///   - bucket: Target storage bucket
    ///   - path: File path in bucket
    ///   - contentType: MIME type of the file
    /// - Returns: Public URL of uploaded file
    func uploadData(
        _ data: Data,
        to bucket: Bucket,
        path: String,
        contentType: String
    ) async throws -> String {
        do {
            let file = File(
                name: path,
                data: data,
                fileName: path,
                contentType: contentType
            )

            _ = try await client.storage
                .from(bucket.rawValue)
                .upload(
                    path: path,
                    file: file,
                    options: FileOptions(
                        cacheControl: "3600",
                        upsert: false
                    )
                )

            // Get public URL
            let publicURL = try client.storage
                .from(bucket.rawValue)
                .getPublicURL(path: path)

            return publicURL.absoluteString
        } catch {
            throw StorageError.uploadFailed(error)
        }
    }

    /// Get optimized image URL with transformations
    /// - Parameters:
    ///   - bucket: Storage bucket
    ///   - path: File path
    ///   - width: Desired width
    ///   - height: Desired height
    ///   - quality: Image quality (1-100)
    /// - Returns: Public URL with transformation parameters
    func getOptimizedImageURL(
        from bucket: Bucket,
        path: String,
        width: Int? = nil,
        height: Int? = nil,
        quality: Int = 80
    ) throws -> String {
        let publicURL = try client.storage
            .from(bucket.rawValue)
            .getPublicURL(
                path: path,
                download: false,
                transform: TransformOptions(
                    width: width,
                    height: height,
                    quality: quality
                )
            )

        return publicURL.absoluteString
    }

    /// Download data from Supabase Storage
    /// - Parameters:
    ///   - bucket: Source storage bucket
    ///   - path: File path in bucket
    /// - Returns: Downloaded data
    func downloadData(from bucket: Bucket, path: String) async throws -> Data {
        do {
            let data = try await client.storage
                .from(bucket.rawValue)
                .download(path: path)

            return data
        } catch {
            throw StorageError.downloadFailed(error)
        }
    }

    /// Delete a file from Supabase Storage
    /// - Parameters:
    ///   - bucket: Source storage bucket
    ///   - path: File path in bucket
    func deleteFile(from bucket: Bucket, path: String) async throws {
        do {
            try await client.storage
                .from(bucket.rawValue)
                .remove(paths: [path])
        } catch {
            throw StorageError.deleteFailed(error)
        }
    }

    /// Delete multiple files
    /// - Parameters:
    ///   - bucket: Source storage bucket
    ///   - paths: Array of file paths
    func deleteFiles(from bucket: Bucket, paths: [String]) async throws {
        do {
            try await client.storage
                .from(bucket.rawValue)
                .remove(paths: paths)
        } catch {
            throw StorageError.deleteFailed(error)
        }
    }

    // MARK: - Helper Methods

    /// Generate a unique file path
    /// - Parameters:
    ///   - userId: User ID for namespacing
    ///   - fileExtension: File extension (e.g., "jpg", "png")
    ///   - prefix: Optional prefix for the file
    /// - Returns: Unique file path
    func generateUniquePath(
        userId: String,
        fileExtension: String,
        prefix: String? = nil
    ) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let uuid = UUID().uuidString.prefix(8)
        let filename = prefix != nil ? "\(prefix!)_\(timestamp)_\(uuid).\(fileExtension)" : "\(timestamp)_\(uuid).\(fileExtension)"
        return "\(userId)/\(filename)"
    }

    /// Extract path from Supabase Storage URL
    /// - Parameter url: Full Supabase Storage URL
    /// - Returns: File path if valid
    func extractPath(from url: String) -> String? {
        guard let urlComponents = URLComponents(string: url),
              let pathSegments = urlComponents.path.components(separatedBy: "/object/public/").last else {
            return nil
        }
        return pathSegments
    }
}

// MARK: - Convenience Methods
extension SupabaseStorageService {

    /// Prepare image for upload (resize and compress)
    /// - Parameters:
    ///   - image: Original image
    ///   - maxDimension: Maximum width or height
    /// - Returns: Prepared image
    func prepareImageForUpload(_ image: UIImage, maxDimension: CGFloat = 1920) -> UIImage? {
        let size = image.size

        // Calculate new size maintaining aspect ratio
        var newSize: CGSize
        if size.width > maxDimension || size.height > maxDimension {
            if size.width > size.height {
                let ratio = maxDimension / size.width
                newSize = CGSize(width: maxDimension, height: size.height * ratio)
            } else {
                let ratio = maxDimension / size.height
                newSize = CGSize(width: size.width * ratio, height: maxDimension)
            }
        } else {
            newSize = size
        }

        // Resize image
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    /// Upload user profile image
    /// - Parameters:
    ///   - image: Profile image
    ///   - userId: User ID
    /// - Returns: Public URL of uploaded image
    func uploadProfileImage(_ image: UIImage, userId: String) async throws -> String {
        guard let preparedImage = prepareImageForUpload(image, maxDimension: 800) else {
            throw StorageError.invalidImage
        }

        let path = generateUniquePath(userId: userId, fileExtension: "jpg", prefix: "avatar")
        return try await uploadImage(preparedImage, to: .userProfiles, path: path, maxSize: 5_000_000)
    }

    /// Upload business logo
    /// - Parameters:
    ///   - image: Logo image
    ///   - businessId: Business ID
    /// - Returns: Public URL of uploaded logo
    func uploadBusinessLogo(_ image: UIImage, businessId: String) async throws -> String {
        guard let preparedImage = prepareImageForUpload(image, maxDimension: 500) else {
            throw StorageError.invalidImage
        }

        let path = generateUniquePath(userId: businessId, fileExtension: "png", prefix: "logo")
        return try await uploadImage(preparedImage, to: .businessMedia, path: path, maxSize: 5_000_000)
    }

    /// Upload business cover image
    /// - Parameters:
    ///   - image: Cover image
    ///   - businessId: Business ID
    /// - Returns: Public URL of uploaded cover
    func uploadBusinessCover(_ image: UIImage, businessId: String) async throws -> String {
        guard let preparedImage = prepareImageForUpload(image, maxDimension: 1920) else {
            throw StorageError.invalidImage
        }

        let path = generateUniquePath(userId: businessId, fileExtension: "jpg", prefix: "cover")
        return try await uploadImage(preparedImage, to: .businessMedia, path: path, maxSize: 10_000_000)
    }

    /// Upload post image
    /// - Parameters:
    ///   - image: Post image
    ///   - userId: User ID
    /// - Returns: Public URL of uploaded image
    func uploadPostImage(_ image: UIImage, userId: String) async throws -> String {
        guard let preparedImage = prepareImageForUpload(image, maxDimension: 1920) else {
            throw StorageError.invalidImage
        }

        let path = generateUniquePath(userId: userId, fileExtension: "jpg", prefix: "post")
        return try await uploadImage(preparedImage, to: .postMedia, path: path, maxSize: 10_000_000)
    }

    /// Upload message attachment
    /// - Parameters:
    ///   - data: File data
    ///   - conversationId: Conversation ID
    ///   - contentType: MIME type
    ///   - fileExtension: File extension
    /// - Returns: Public URL of uploaded file
    func uploadMessageAttachment(
        _ data: Data,
        conversationId: String,
        contentType: String,
        fileExtension: String
    ) async throws -> String {
        // Validate file size (20MB max for messages)
        guard data.count <= 20_000_000 else {
            throw StorageError.fileTooLarge(maxSize: 20_000_000)
        }

        let path = generateUniquePath(userId: conversationId, fileExtension: fileExtension, prefix: "attachment")
        return try await uploadData(data, to: .messageAttachments, path: path, contentType: contentType)
    }
}
