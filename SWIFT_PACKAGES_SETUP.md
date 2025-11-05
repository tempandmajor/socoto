# Swift Package Manager Setup Guide

This document explains how to add the required Swift packages to the Socoto Xcode project.

## Required Packages

### 1. Supabase Swift
**Purpose**: Supabase client for authentication, database, and realtime features

**Repository**: `https://github.com/supabase/supabase-swift`
**Version**: 2.0.0 or later
**Platforms**: iOS 13.0+

**Installation Steps**:
1. Open `Socoto.xcodeproj` in Xcode
2. Go to **File > Add Package Dependencies...**
3. Enter the repository URL: `https://github.com/supabase/supabase-swift`
4. Select version: **Up to Next Major Version** (2.0.0)
5. Add the following products to your target:
   - `Supabase`
   - `Auth`
   - `PostgREST`
   - `Realtime`
   - `Storage`

### 2. AWS SDK for Swift
**Purpose**: AWS S3 integration for media storage

**Repository**: `https://github.com/awslabs/aws-sdk-swift`
**Version**: 0.40.0 or later
**Platforms**: iOS 13.0+

**Installation Steps**:
1. In Xcode, go to **File > Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/awslabs/aws-sdk-swift`
3. Select version: **Up to Next Major Version** (0.40.0)
4. Add the following products:
   - `AWSS3`
   - `AWSClientRuntime`

**Note**: The AWS SDK is modular, so we only add S3 support to minimize app size.

### 3. Kingfisher (Image Loading)
**Purpose**: Efficient async image downloading and caching

**Repository**: `https://github.com/onevcat/Kingfisher`
**Version**: 7.0.0 or later
**Platforms**: iOS 13.0+

**Installation Steps**:
1. In Xcode, go to **File > Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/onevcat/Kingfisher`
3. Select version: **Up to Next Major Version** (7.0.0)
4. Add product: `Kingfisher`

### 4. Swift Stripe SDK (Optional - for future use)
**Purpose**: Stripe payment integration for subscriptions

**Repository**: `https://github.com/stripe/stripe-ios-spm`
**Version**: 23.0.0 or later
**Platforms**: iOS 13.0+

**Installation Steps**:
1. In Xcode, go to **File > Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/stripe/stripe-ios-spm`
3. Select version: **Up to Next Major Version** (23.0.0)
4. Add product: `StripePaymentSheet`

## Complete Installation Checklist

Once all packages are added, verify your Package Dependencies:

1. Open Xcode project
2. Select the project file in the navigator
3. Select your target (Socoto)
4. Go to **General** tab
5. Scroll to **Frameworks, Libraries, and Embedded Content**
6. Verify the following are listed:
   - ☑️ Supabase
   - ☑️ Auth
   - ☑️ PostgREST
   - ☑️ Realtime
   - ☑️ Storage
   - ☑️ AWSS3
   - ☑️ AWSClientRuntime
   - ☑️ Kingfisher
   - ☑️ StripePaymentSheet (optional)

## Troubleshooting

### Build Errors
If you encounter build errors after adding packages:

1. **Clean Build Folder**: Product > Clean Build Folder (⇧⌘K)
2. **Reset Package Caches**: File > Packages > Reset Package Caches
3. **Update to Latest Packages**: File > Packages > Update to Latest Package Versions
4. **Restart Xcode**: Sometimes a simple restart resolves package issues

### Package Resolution Issues
If packages fail to resolve:

1. Check your internet connection
2. Verify you're using the correct repository URLs
3. Try removing and re-adding the problematic package
4. Check if the package supports your iOS version (13.0+)

### Minimum iOS Version
Ensure your project's deployment target is set correctly:

1. Select project in navigator
2. Select target
3. Go to **Build Settings** tab
4. Search for "iOS Deployment Target"
5. Set to **iOS 13.0** or later

## Next Steps

After installing all packages:

1. ✅ Build the project (⌘B) to verify all packages compile
2. ✅ Review the service layer implementations in:
   - `Services/API/SupabaseService.swift`
   - `Services/Storage/S3StorageService.swift`
3. ✅ Configure your `.env` file with credentials (see `CREDENTIALS_SETUP.md`)
4. ✅ Test authentication flow

## Package Documentation

- **Supabase Swift**: https://github.com/supabase/supabase-swift
- **AWS SDK Swift**: https://github.com/awslabs/aws-sdk-swift
- **Kingfisher**: https://github.com/onevcat/Kingfisher
- **Stripe iOS**: https://stripe.com/docs/mobile/ios

## Support

If you encounter issues with package setup:

1. Check the package's GitHub issues page
2. Verify your Xcode version (14.0+ recommended)
3. Ensure macOS is up to date
4. Review the package's minimum requirements

## Alternative: Using Stripe for Testing

Currently, the Stripe account is set to **sandbox mode** for testing. To work with payments:

1. Use test card numbers from: https://stripe.com/docs/testing
2. Test card: `4242 4242 4242 4242` (any future date, any CVC)
3. Check the Stripe dashboard for test transactions
