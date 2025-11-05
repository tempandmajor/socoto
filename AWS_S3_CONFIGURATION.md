# AWS S3 Configuration

## Overview
Socoto uses AWS S3 for secure and scalable media storage across four dedicated buckets.

## S3 Buckets

### 1. socoto-user-profiles
**Purpose**: User profile pictures and avatars

**Configuration**:
- Region: us-east-2
- Encryption: AES256 (at rest)
- Versioning: Enabled
- CORS: Enabled for web/mobile uploads

**Typical File Types**:
- JPEG, PNG profile photos
- Max size: 5 MB

### 2. socoto-business-media
**Purpose**: Business logos, cover images, and gallery photos

**Configuration**:
- Region: us-east-2
- Encryption: AES256 (at rest)
- Versioning: Enabled
- CORS: Enabled for web/mobile uploads

**Typical File Types**:
- Business logos (PNG, JPEG)
- Cover images (JPEG, PNG)
- Gallery photos
- Max size: 10 MB per image

### 3. socoto-post-media
**Purpose**: User and business post images/videos

**Configuration**:
- Region: us-east-2
- Encryption: AES256 (at rest)
- Versioning: Enabled
- CORS: Enabled for web/mobile uploads

**Typical File Types**:
- Images (JPEG, PNG, GIF)
- Videos (MP4, MOV)
- Max size: 50 MB for images, 100 MB for videos

### 4. socoto-message-attachments
**Purpose**: File attachments in direct messages

**Configuration**:
- Region: us-east-2
- Encryption: AES256 (at rest)
- Versioning: Enabled
- CORS: Enabled for web/mobile uploads

**Typical File Types**:
- Images (JPEG, PNG)
- Documents (PDF)
- Max size: 20 MB

## CORS Configuration

All buckets have CORS enabled with the following configuration:

```json
{
  "CORSRules": [
    {
      "AllowedOrigins": ["*"],
      "AllowedMethods": ["GET", "PUT", "POST", "DELETE", "HEAD"],
      "AllowedHeaders": ["*"],
      "ExposeHeaders": ["ETag"],
      "MaxAgeSeconds": 3000
    }
  ]
}
```

## iOS Integration

### AWS SDK Setup

Add the AWS SDK to your Swift Package Manager dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/awslabs/aws-sdk-swift.git", from: "0.34.0")
]
```

### Upload Example

```swift
import AWSS3

func uploadImage(image: UIImage, to bucket: String, key: String) async throws -> String {
    // Convert image to data
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        throw UploadError.invalidImage
    }

    // Configure S3 client
    let client = try S3Client(region: "us-east-2")

    // Create upload request
    let input = PutObjectInput(
        body: .data(imageData),
        bucket: bucket,
        contentType: "image/jpeg",
        key: key
    )

    // Upload to S3
    _ = try await client.putObject(input: input)

    // Return public URL
    return "https://\(bucket).s3.us-east-2.amazonaws.com/\(key)"
}
```

### Download Example

```swift
func downloadImage(from url: String) async throws -> UIImage {
    let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)

    guard let image = UIImage(data: data) else {
        throw DownloadError.invalidImageData
    }

    return image
}
```

## File Naming Convention

Use a consistent naming structure for organized storage:

### User Profiles
```
users/{user_id}/avatar_{timestamp}.jpg
```

### Business Media
```
businesses/{business_id}/logo_{timestamp}.png
businesses/{business_id}/cover_{timestamp}.jpg
businesses/{business_id}/gallery/{photo_id}.jpg
```

### Post Media
```
posts/{post_id}/{media_id}_{timestamp}.jpg
posts/{post_id}/video_{timestamp}.mp4
```

### Message Attachments
```
messages/{conversation_id}/{message_id}_{filename}
```

## Security Best Practices

### 1. Pre-signed URLs
Generate pre-signed URLs for secure, temporary access:

```swift
func generatePresignedURL(bucket: String, key: String) async throws -> URL {
    let client = try S3Client(region: "us-east-2")

    let input = GetObjectInput(bucket: bucket, key: key)
    let request = try await client.getObjectPresignedURL(input: input, expiration: 3600) // 1 hour

    return request
}
```

### 2. Access Control
- Never expose AWS credentials in the app
- Use IAM roles with minimum required permissions
- Implement server-side validation for uploads

### 3. File Validation

Always validate files before upload:

```swift
func validateImage(_ image: UIImage) -> Bool {
    guard let data = image.jpegData(compressionQuality: 0.8) else {
        return false
    }

    // Check file size (5MB max for profiles)
    let maxSize = 5 * 1024 * 1024
    guard data.count <= maxSize else {
        return false
    }

    // Check dimensions
    guard image.size.width >= 200 && image.size.height >= 200 else {
        return false
    }

    return true
}
```

## Image Processing

### Resize for Upload

```swift
func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
    let ratio = min(maxDimension / image.size.width, maxDimension / image.size.height)
    let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)

    let renderer = UIGraphicsImageRenderer(size: newSize)
    return renderer.image { _ in
        image.draw(in: CGRect(origin: .zero, size: newSize))
    }
}
```

### Compression

```swift
// Profile photos: 1024x1024 max, 80% quality
let profilePhoto = resizeImage(originalImage, maxDimension: 1024)
let profileData = profilePhoto.jpegData(compressionQuality: 0.8)

// Cover images: 1920x1080 max, 85% quality
let coverImage = resizeImage(originalImage, maxDimension: 1920)
let coverData = coverImage.jpegData(compressionQuality: 0.85)
```

## Caching Strategy

### iOS Image Caching

Use a caching library like Kingfisher or implement custom caching:

```swift
import Kingfisher

// Load image with caching
imageView.kf.setImage(
    with: URL(string: imageURL),
    placeholder: UIImage(named: "placeholder"),
    options: [
        .transition(.fade(0.2)),
        .cacheOriginalImage,
        .scaleFactor(UIScreen.main.scale)
    ]
)
```

## Lifecycle Policies

Consider implementing lifecycle policies for cost optimization:

### Delete Temporary Files
```
Rule: Delete incomplete multipart uploads after 7 days
Rule: Move old post media to Glacier after 2 years
Rule: Delete unverified user avatars after 30 days
```

## Monitoring & Costs

### CloudWatch Metrics
Monitor these S3 metrics:
- Total storage size
- Request count
- Error rate
- Data transfer

### Cost Optimization
- Enable intelligent tiering for infrequently accessed media
- Compress images before upload
- Delete orphaned files (files not referenced in database)
- Use CloudFront CDN for frequently accessed content

## Backup Strategy

All S3 buckets have versioning enabled for:
- Accidental deletion protection
- File history tracking
- Quick recovery

### Recovery Example

```bash
# List versions of a file
aws s3api list-object-versions \
    --bucket socoto-user-profiles \
    --prefix users/abc123/avatar

# Restore previous version
aws s3api copy-object \
    --copy-source socoto-user-profiles/users/abc123/avatar?versionId=xyz \
    --bucket socoto-user-profiles \
    --key users/abc123/avatar
```

## Error Handling

```swift
enum S3Error: Error {
    case uploadFailed
    case downloadFailed
    case invalidFile
    case networkError
    case quotaExceeded
}

func handleS3Error(_ error: Error) {
    if let s3Error = error as? S3Error {
        switch s3Error {
        case .uploadFailed:
            // Show retry option
        case .downloadFailed:
            // Show cached version if available
        case .invalidFile:
            // Show validation error
        case .networkError:
            // Queue for retry
        case .quotaExceeded:
            // Show upgrade prompt
        }
    }
}
```

## Testing

### Local Development
Use LocalStack or MinIO for local S3 testing:

```bash
# Start LocalStack
docker run -d -p 4566:4566 localstack/localstack

# Configure local endpoint
AWS_ENDPOINT_URL=http://localhost:4566
```

### Test Checklist
- [ ] Upload image to each bucket
- [ ] Download image from each bucket
- [ ] Verify CORS works from iOS app
- [ ] Test file size limits
- [ ] Test unsupported file types
- [ ] Test network error handling
- [ ] Verify encryption at rest
- [ ] Test versioning and recovery

## Next Steps

- [ ] Implement CloudFront CDN for faster delivery
- [ ] Add server-side image processing (thumbnails)
- [ ] Implement automatic image optimization
- [ ] Add video transcoding pipeline
- [ ] Setup S3 event notifications
- [ ] Implement content moderation for uploaded images
