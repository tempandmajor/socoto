//
//  S3StorageService.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import Foundation
import UIKit
// import AWSS3          // Uncomment after adding AWS SDK package
// import AWSClientRuntime  // Uncomment after adding AWS SDK package

/// Service for handling media uploads to AWS S3
final class S3StorageService {

    // MARK: - Singleton
    static let shared = S3StorageService()

    // MARK: - Properties
    // private var s3Client: S3Client?  // Uncomment after adding AWS SDK

    enum StorageBucket: String {
        case userProfiles = "socoto-user-profiles"
        case businessMedia = "socoto-business-media"
        case postMedia = "socoto-post-media"
        case messageAttachments = "socoto-message-attachments"

        var bucket: String {
            return self.rawValue
        }
    }

    enum StorageError: Error {
        case invalidImage
        case uploadFailed
        case downloadFailed
        case deleteFailed
        case awsNotConfigured

        var localizedDescription: String {
            switch self {
            case .invalidImage:
                return "Invalid image data"
            case .uploadFailed:
                return "Failed to upload file"
            case .downloadFailed:
                return "Failed to download file"
            case .deleteFailed:
                return "Failed to delete file"
            case .awsNotConfigured:
                return "AWS SDK not yet configured. Please add the AWS SDK package."
            }
        }
    }

    // MARK: - Initialization
    private init() {
        // TODO: Initialize S3 client after adding AWS SDK package
        /*
        do {
            let credentials = AWSCredentials(
                accessKeyId: Config.AWS.accessKeyId,
                secretAccessKey: Config.AWS.secretAccessKey
            )

            let config = try S3Client.S3ClientConfiguration(
                region: Config.AWS.region,
                credentialsProvider: credentials
            )

            s3Client = S3Client(config: config)
        } catch {
            print("Failed to initialize S3 client: \(error)")
        }
        */
    }

    // MARK: - Public Methods

    /// Upload an image to S3
    /// - Parameters:
    ///   - image: UIImage to upload
    ///   - bucket: Target S3 bucket
    ///   - key: File key/path in S3
    /// - Returns: Public URL of uploaded image
    func uploadImage(_ image: UIImage, to bucket: StorageBucket, key: String) async throws -> String {
        // TODO: Implement after adding AWS SDK package
        /*
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidImage
        }

        return try await uploadData(imageData, to: bucket, key: key, contentType: "image/jpeg")
        */
        throw StorageError.awsNotConfigured
    }

    /// Upload data to S3
    /// - Parameters:
    ///   - data: Data to upload
    ///   - bucket: Target S3 bucket
    ///   - key: File key/path in S3
    ///   - contentType: MIME type of the file
    /// - Returns: Public URL of uploaded file
    func uploadData(_ data: Data, to bucket: StorageBucket, key: String, contentType: String) async throws -> String {
        // TODO: Implement after adding AWS SDK package
        /*
        guard let s3Client = s3Client else {
            throw StorageError.awsNotConfigured
        }

        do {
            let putObjectInput = PutObjectInput(
                body: .data(data),
                bucket: bucket.bucket,
                contentType: contentType,
                key: key
            )

            _ = try await s3Client.putObject(input: putObjectInput)

            // Generate public URL
            let url = "https://\(bucket.bucket).s3.amazonaws.com/\(key)"
            return url
        } catch {
            print("S3 upload error: \(error)")
            throw StorageError.uploadFailed
        }
        */
        throw StorageError.awsNotConfigured
    }

    /// Download data from S3
    /// - Parameters:
    ///   - bucket: Source S3 bucket
    ///   - key: File key/path in S3
    /// - Returns: Downloaded data
    func downloadData(from bucket: StorageBucket, key: String) async throws -> Data {
        // TODO: Implement after adding AWS SDK package
        /*
        guard let s3Client = s3Client else {
            throw StorageError.awsNotConfigured
        }

        do {
            let getObjectInput = GetObjectInput(
                bucket: bucket.bucket,
                key: key
            )

            let response = try await s3Client.getObject(input: getObjectInput)

            guard let data = try await response.body?.readData() else {
                throw StorageError.downloadFailed
            }

            return data
        } catch {
            print("S3 download error: \(error)")
            throw StorageError.downloadFailed
        }
        */
        throw StorageError.awsNotConfigured
    }

    /// Delete a file from S3
    /// - Parameters:
    ///   - bucket: Source S3 bucket
    ///   - key: File key/path in S3
    func deleteFile(from bucket: StorageBucket, key: String) async throws {
        // TODO: Implement after adding AWS SDK package
        /*
        guard let s3Client = s3Client else {
            throw StorageError.awsNotConfigured
        }

        do {
            let deleteObjectInput = DeleteObjectInput(
                bucket: bucket.bucket,
                key: key
            )

            _ = try await s3Client.deleteObject(input: deleteObjectInput)
        } catch {
            print("S3 delete error: \(error)")
            throw StorageError.deleteFailed
        }
        */
        throw StorageError.awsNotConfigured
    }

    // MARK: - Helper Methods

    /// Generate a unique key for a file
    /// - Parameters:
    ///   - userId: User ID for namespacing
    ///   - fileExtension: File extension (e.g., "jpg", "png")
    /// - Returns: Unique file key
    func generateUniqueKey(userId: String, fileExtension: String) -> String {
        let timestamp = Date().timeIntervalSince1970
        let uuid = UUID().uuidString
        return "\(userId)/\(timestamp)_\(uuid).\(fileExtension)"
    }

    /// Extract key from S3 URL
    /// - Parameter url: Full S3 URL
    /// - Returns: File key/path
    func extractKey(from url: String) -> String? {
        guard let urlComponents = URLComponents(string: url),
              let host = urlComponents.host else {
            return nil
        }

        // Extract key from URL path
        let path = urlComponents.path
        return String(path.dropFirst()) // Remove leading "/"
    }

    /// Get bucket from URL
    /// - Parameter url: Full S3 URL
    /// - Returns: Storage bucket if found
    func getBucket(from url: String) -> StorageBucket? {
        guard let urlComponents = URLComponents(string: url),
              let host = urlComponents.host else {
            return nil
        }

        // Extract bucket name from host
        let bucketName = host.components(separatedBy: ".").first

        return StorageBucket(rawValue: bucketName ?? "")
    }
}

// MARK: - Image Processing Extensions
extension S3StorageService {

    /// Compress and resize image before upload
    /// - Parameters:
    ///   - image: Original image
    ///   - maxSize: Maximum dimension (width or height)
    /// - Returns: Compressed image
    func prepareImageForUpload(_ image: UIImage, maxSize: CGFloat = 1920) -> UIImage? {
        let size = image.size

        // Calculate new size maintaining aspect ratio
        var newSize: CGSize
        if size.width > size.height {
            let ratio = maxSize / size.width
            newSize = CGSize(width: maxSize, height: size.height * ratio)
        } else {
            let ratio = maxSize / size.height
            newSize = CGSize(width: size.width * ratio, height: maxSize)
        }

        // Resize image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage
    }

    /// Upload user profile image
    /// - Parameters:
    ///   - image: Profile image
    ///   - userId: User ID
    /// - Returns: Public URL of uploaded image
    func uploadProfileImage(_ image: UIImage, userId: String) async throws -> String {
        guard let preparedImage = prepareImageForUpload(image, maxSize: 500) else {
            throw StorageError.invalidImage
        }

        let key = generateUniqueKey(userId: userId, fileExtension: "jpg")
        return try await uploadImage(preparedImage, to: .userProfiles, key: key)
    }

    /// Upload business media (logo, cover, gallery)
    /// - Parameters:
    ///   - image: Business image
    ///   - businessId: Business ID
    ///   - type: Image type (logo, cover, gallery)
    /// - Returns: Public URL of uploaded image
    func uploadBusinessImage(_ image: UIImage, businessId: String, type: String) async throws -> String {
        let maxSize: CGFloat = type == "logo" ? 500 : 1920
        guard let preparedImage = prepareImageForUpload(image, maxSize: maxSize) else {
            throw StorageError.invalidImage
        }

        let key = "\(businessId)/\(type)/\(generateUniqueKey(userId: businessId, fileExtension: "jpg"))"
        return try await uploadImage(preparedImage, to: .businessMedia, key: key)
    }

    /// Upload post media
    /// - Parameters:
    ///   - image: Post image
    ///   - userId: User ID
    ///   - postId: Post ID
    /// - Returns: Public URL of uploaded image
    func uploadPostImage(_ image: UIImage, userId: String, postId: String) async throws -> String {
        guard let preparedImage = prepareImageForUpload(image) else {
            throw StorageError.invalidImage
        }

        let key = "\(userId)/\(postId)/\(generateUniqueKey(userId: userId, fileExtension: "jpg"))"
        return try await uploadImage(preparedImage, to: .postMedia, key: key)
    }

    /// Upload message attachment
    /// - Parameters:
    ///   - data: File data
    ///   - conversationId: Conversation ID
    ///   - contentType: MIME type
    ///   - fileExtension: File extension
    /// - Returns: Public URL of uploaded file
    func uploadMessageAttachment(_ data: Data, conversationId: String, contentType: String, fileExtension: String) async throws -> String {
        let key = "\(conversationId)/\(generateUniqueKey(userId: conversationId, fileExtension: fileExtension))"
        return try await uploadData(data, to: .messageAttachments, key: key, contentType: contentType)
    }
}
