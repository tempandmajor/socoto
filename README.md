# Socoto

A hyper-local social network connecting local businesses with residents for bookings, campaigns, and community engagement.

## Overview

Socoto enables local businesses to connect with their community through:
- Business profiles with reviews and ratings
- Social feed with posts and updates
- Booking system for appointments
- Discount campaigns and promotions
- Direct messaging (with calling for premium subscribers)

## Tech Stack

- **iOS**: SwiftUI with modern design system
- **Backend**: Supabase (PostgreSQL + Realtime + Storage)
- **Payments**: Stripe ($20/month premium tier)
- **Authentication**: Supabase Auth with role-based access
- **Design System**: Space Grotesk + Inter fonts, comprehensive design tokens

## Features

### For Users
- Browse local businesses by location and category
- View business profiles, posts, and reviews
- Book appointments with local businesses
- Message businesses directly
- Follow businesses and get updates
- Leave reviews and ratings

### For Businesses
- Create and manage business profile
- Post updates and announcements
- Accept and manage bookings
- Run discount campaigns
- Message customers
- View analytics and insights
- **Premium ($20/month)**: Voice calling feature

## Getting Started

### Prerequisites
- Xcode 15+
- iOS 17+
- Swift 5.9+
- Active Supabase project (with Storage buckets configured)
- Stripe account (optional for basic features)

### Setup

1. Clone the repository:
```bash
git clone https://github.com/tempandmajor/socoto.git
cd socoto
```

2. Configure credentials:
```bash
cp .env.example .env
# Edit .env with your Supabase credentials
```

3. Set up Supabase Storage buckets:
```sql
-- Run in Supabase SQL Editor
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('user-profiles', 'user-profiles', true),
  ('business-media', 'business-media', true),
  ('post-media', 'post-media', true),
  ('message-attachments', 'message-attachments', false);
```

4. Install custom fonts (see [FONTS_SETUP.md](FONTS_SETUP.md)):
   - Download Space Grotesk and Inter
   - Add .ttf files to Xcode project
   - Register in Info.plist

5. Open in Xcode:
```bash
open Socoto.xcodeproj
```

## Project Structure

```
Socoto/
├── Design/
│   ├── Theme/
│   │   ├── DesignTokens.swift    # Comprehensive design system
│   │   └── AppTheme.swift        # Legacy theme (deprecated)
│   ├── Components/
│   │   ├── ButtonStyles.swift    # Primary, secondary, pill buttons
│   │   ├── SurfaceComponents.swift  # Cards, panels, containers
│   │   ├── StatusComponents.swift   # Badges, pills, indicators
│   │   └── ProgressiveDisclosure.swift  # Accordions, tabs, wizards
│   └── Modifiers/
│       └── GlassmorphicModifier.swift
├── Core/
│   ├── Configuration/
│   │   └── Config.swift          # Secure config management
│   └── Navigation/
│       └── TabBarView.swift      # Main navigation
├── Services/
│   ├── API/
│   │   └── SupabaseService.swift
│   └── Storage/
│       └── SupabaseStorageService.swift  # Media uploads
└── Assets.xcassets/
    ├── Colors/                   # Design token colors
    ├── Surface/                  # Surface color variants
    ├── Ink/                      # Text color variants
    ├── Border/                   # Border colors
    ├── Brand/                    # Brand colors
    └── Status/                   # Status colors
```

## Design System

Socoto uses a comprehensive design system with:

### Color Tokens
- **Surface Colors**: Backgrounds, elevated surfaces, overlays
- **Ink Colors**: Text hierarchy (primary, secondary, tertiary, muted)
- **Border Colors**: Borders, focus states
- **Brand Colors**: Primary, secondary, accent
- **Status Colors**: Success, warning, error, info, pending

All colors support Light/Dark mode automatically via Asset Catalog.

### Typography
- **Display**: Space Grotesk SemiBold (56pt, 48pt, 40pt)
- **Headlines**: Space Grotesk SemiBold (32pt, 28pt, 24pt)
- **Titles**: Space Grotesk Medium/SemiBold (20pt, 18pt, 16pt)
- **Body**: Inter Regular (18pt, 16pt, 14pt)
- **Labels**: Inter Medium (14pt, 12pt, 11pt)
- **Buttons**: Space Grotesk SemiBold UPPERCASE (16pt, 14pt, 12pt)

### Spacing Scale
4pt, 8pt, 12pt, 16pt, 20pt, 24pt, 32pt, 40pt, 48pt, 64pt

### Components
- **Buttons**: Primary, Secondary, Tertiary, Pill, Icon, Destructive
- **Surfaces**: Cards, Panels, Glass Cards, Summary Cards, Empty States
- **Status**: Pills, Badges, Banners, Progress Indicators, Skeletons
- **Progressive Disclosure**: Accordions, Expandable Sections, Tabs, Wizards

### Progressive Disclosure
The app implements progressive disclosure patterns to reduce cognitive load:
- Expandable sections for advanced settings
- Show more/less for long content
- Accordions for FAQ and detailed information
- Tabs for organizing related content
- Multi-step wizards for complex workflows

## Security

✅ **Security Improvements**:
- Client-safe credentials only (SUPABASE_ANON_KEY, STRIPE_PUBLISHABLE_KEY)
- Removed AWS credentials from client app
- Removed dangerous keys (service role, secret keys)
- Removed hardcoded developer paths
- Row Level Security (RLS) enabled on Supabase
- Secure media uploads via Supabase Storage
- JWT-based authentication

## Storage Architecture

Uses **Supabase Storage** for all media (no AWS):

### Buckets
- `user-profiles` - Profile pictures (5MB max)
- `business-media` - Logos, covers, gallery (10MB max)
- `post-media` - Post images/videos (50MB max)
- `message-attachments` - Message files (20MB max)

### Features
- Automatic image optimization
- CDN included
- RLS policies for security
- Presigned URLs for secure uploads
- Image transformations on-the-fly

## Documentation

- [FONTS_SETUP.md](FONTS_SETUP.md) - Custom fonts installation guide
- [DATABASE_SCHEMA.md](DATABASE_SCHEMA.md) - Complete database schema
- [AUTH_CONFIGURATION.md](AUTH_CONFIGURATION.md) - Authentication setup
- [CREDENTIALS_SETUP.md](CREDENTIALS_SETUP.md) - Credentials management

## Development Workflow

### Using Design Tokens

```swift
// Typography
Text("Headline")
    .headlineLarge()  // Space Grotesk SemiBold, 32pt

Text("Body text")
    .bodyMedium()  // Inter Regular, 16pt

// Colors
Text("Status")
    .foregroundColor(DesignTokens.Colors.inkPrimary)
    .background(DesignTokens.Colors.surfaceElevated)

// Buttons
Button("Submit") {}
    .primaryButton()

Button("Cancel") {}
    .secondaryButton()

// Spacing
VStack(spacing: DesignTokens.Spacing.large) {
    // Content
}
.padding(DesignTokens.Spacing.page)

// Components
SurfaceCard {
    Text("Card content")
}

StatusPill(text: "Active", status: .success)

ProgressIndicator(progress: 0.75)
```

### Progressive Disclosure Example

```swift
ExpandableSection {
    Text("Advanced Options")
        .headlineSmall()
} content: {
    VStack {
        Toggle("Enable notifications", isOn: $notificationsEnabled)
        Toggle("Auto-save", isOn: $autoSave)
    }
}

Accordion(sections: [
    .init(title: "FAQ 1") { Text("Answer 1") },
    .init(title: "FAQ 2") { Text("Answer 2") }
])
```

## Contributing

This is a private project. For questions, contact the development team.

## License

Proprietary - All rights reserved

---

Built with ❤️ for local communities
