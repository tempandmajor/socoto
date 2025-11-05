# iOS App Setup Guide

This guide will help you create the Xcode project and integrate all the Swift files that have been created.

## Step 1: Create New Xcode Project

1. Open Xcode
2. Select **File > New > Project**
3. Choose **iOS > App**
4. Configure your project:
   - **Product Name**: Socoto
   - **Team**: Select your development team
   - **Organization Identifier**: com.yourcompany (or your identifier)
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: None
   - **Include Tests**: Check both Unit Tests and UI Tests
5. Choose the location: `/Users/emmanuelakangbou/CascadeProjects/Socoto`
6. **IMPORTANT**: Uncheck "Create Git repository" (we already have one)

## Step 2: Organize Project Structure

After creating the project, organize the files in Xcode using these groups:

```
Socoto/
├── SocotoApp.swift (already exists - will be updated)
├── Core/
│   ├── Configuration/
│   │   └── Config.swift
│   └── Navigation/
│       └── TabBarView.swift
├── Design/
│   ├── Theme/
│   │   └── AppTheme.swift
│   ├── Modifiers/
│   │   └── GlassmorphicModifier.swift
│   └── Components/
│       ├── GlassButton.swift
│       ├── GlassCard.swift
│       └── GlassTextField.swift
├── Features/
│   ├── Auth/
│   ├── Feed/
│   ├── Business/
│   ├── Profile/
│   ├── Booking/
│   └── Messages/
├── Services/
│   ├── API/
│   │   └── SupabaseService.swift
│   └── Storage/
│       └── S3StorageService.swift
├── Models/
├── Extensions/
└── Resources/
    └── Assets.xcassets
```

## Step 3: Add Existing Swift Files to Xcode

All Swift files have already been created in the correct folder structure:

1. In Xcode, right-click on the project navigator
2. Select **Add Files to "Socoto"...**
3. Navigate to each folder and add the files:

### Core Files
- `/Socoto/Core/Configuration/Config.swift`
- `/Socoto/Core/Navigation/TabBarView.swift`

### Design System
- `/Socoto/Design/Theme/AppTheme.swift`
- `/Socoto/Design/Modifiers/GlassmorphicModifier.swift`
- `/Socoto/Design/Components/GlassButton.swift`
- `/Socoto/Design/Components/GlassCard.swift`
- `/Socoto/Design/Components/GlassTextField.swift`

### Services
- `/Socoto/Services/API/SupabaseService.swift`
- `/Socoto/Services/Storage/S3StorageService.swift`

### App Entry Point
- Replace the default `SocotoApp.swift` content with the updated version at:
  `/Socoto/SocotoApp.swift`

**Important**: When adding files, make sure to:
- ✅ Check "Copy items if needed"
- ✅ Select "Create groups"
- ✅ Add to target: Socoto

## Step 4: Configure Project Settings

### Build Settings

1. Select project in navigator
2. Select the "Socoto" target
3. Go to **Build Settings** tab
4. Search for "iOS Deployment Target"
5. Set to **iOS 13.0** or later

### Info.plist Configuration

Add the following keys to `Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Socoto needs access to your photos to upload images for posts and profile pictures.</string>

<key>NSCameraUsageDescription</key>
<string>Socoto needs access to your camera to take photos for posts and profile.</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>Socoto needs your location to show you nearby businesses and local content.</string>

<key>UIApplicationSceneManifest</key>
<dict>
    <key>UIApplicationSupportsMultipleScenes</key>
    <true/>
</dict>
```

### App Icon

1. Open `Assets.xcassets` in Xcode
2. Select `AppIcon`
3. Drag and drop your app icon images for each size
4. Xcode will automatically place them in the correct slots

### Launch Screen

1. The app uses a programmatic launch screen (no storyboard needed)
2. To customize, you can add a `LaunchScreen.storyboard` later

## Step 5: Add Swift Packages

Follow the instructions in `SWIFT_PACKAGES_SETUP.md` to add:

1. **Supabase Swift** (`https://github.com/supabase/supabase-swift`)
2. **AWS SDK** (`https://github.com/awslabs/aws-sdk-swift`)
3. **Kingfisher** (`https://github.com/onevcat/Kingfisher`)
4. **Stripe iOS** (optional) (`https://github.com/stripe/stripe-ios-spm`)

## Step 6: Configure Environment Variables

### For Development (Debug builds):

The app reads from the `.env` file in the project root during development.

**Important**: The `.env` file path resolution works when running from Xcode simulator/device.

### For Production (Release builds):

Environment variables should be configured in Xcode build configuration or CI/CD:

1. In Xcode, select project
2. Go to **Info** tab
3. Expand **Configurations**
4. Add configuration keys under each environment

## Step 7: Build and Run

1. Select a simulator or device
2. Press **⌘R** or click the Play button
3. The app should build and launch with the glassmorphic tab bar

### Troubleshooting Build Issues

#### Missing Packages
- Go to **File > Packages > Reset Package Caches**
- Clean Build Folder (⇧⌘K)
- Rebuild

#### File Not Found
- Verify all files are added to the Socoto target
- Check file paths in Project Navigator
- Ensure files are in the correct groups

#### Configuration Errors
- Check that `.env` file exists in project root
- Verify all required environment variables are set
- Check console for warning messages about missing config keys

## Step 8: Enable Git LFS (Optional but Recommended)

For large assets like videos and high-res images:

```bash
git lfs install
git lfs track "*.mp4"
git lfs track "*.mov"
git lfs track "*.png"
git lfs track "*.jpg"
git add .gitattributes
git commit -m "Enable Git LFS for media files"
```

## Step 9: Test the App

### Visual Test
1. Launch app in simulator
2. Verify glassmorphic design system is working
3. Test tab bar navigation
4. Verify all UI components render correctly

### Configuration Test
1. Check console for any configuration warnings
2. Verify app doesn't crash on launch
3. Test that theme colors are applied correctly

## Step 10: Commit Initial iOS App

```bash
git add -A
git commit -m "Add iOS app with glassmorphic UI and service layers"
git push origin main
```

## Next Steps

After completing this setup:

1. **Add Supabase Package**: Uncomment Supabase import statements in `SupabaseService.swift`
2. **Add AWS Package**: Uncomment AWS import statements in `S3StorageService.swift`
3. **Implement Auth Views**: Create sign in/sign up views in `Features/Auth/`
4. **Test Authentication**: Connect to Supabase and test user registration
5. **Implement Features**: Build out Feed, Discover, Messages, and Profile features

## Architecture Overview

The app follows a clean architecture pattern:

- **Features**: Self-contained feature modules
- **Services**: API and storage layer
- **Design**: Reusable UI components with glassmorphic theme
- **Core**: App-wide configuration and navigation
- **Models**: Data models (to be created as needed)

## Support

If you encounter issues:

1. Check Xcode console for error messages
2. Verify all files are correctly added to target
3. Ensure Swift packages are resolved
4. Check `.env` file exists and contains all credentials
5. Review `CREDENTIALS_SETUP.md` for security guidelines

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Supabase Swift Client](https://github.com/supabase/supabase-swift)
- [AWS SDK for Swift](https://github.com/awslabs/aws-sdk-swift)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
