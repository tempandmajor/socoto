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

- **iOS**: SwiftUI with glassmorphism design
- **Backend**: Supabase (PostgreSQL + Realtime)
- **Storage**: AWS S3
- **Payments**: Stripe ($20/month premium tier)
- **Authentication**: Supabase Auth with role-based access

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
- Active Supabase project
- AWS account
- Stripe account

### Setup

1. Clone the repository:
```bash
git clone https://github.com/tempandmajor/socoto.git
cd socoto
```

2. Install dependencies:
```bash
# Swift Package Manager will handle dependencies
```

3. Configure credentials:
```bash
cp .env.example .env
# Edit .env with your credentials
```

4. Open in Xcode:
```bash
open Socoto.xcodeproj
```

## Project Structure

```
Socoto/
├── Models/          # Data models and entities
├── Views/           # SwiftUI views and components
├── ViewModels/      # MVVM view models
├── Services/        # API, database, and third-party services
├── Utilities/       # Helper functions and extensions
└── Resources/       # Assets and configuration
```

## Security

- All credentials stored in `.env` (not committed)
- Row Level Security (RLS) enabled on Supabase
- Secure credential management via AWS Secrets Manager in production
- End-to-end encryption for messages

## Contributing

This is a private project. For questions, contact the development team.

## License

Proprietary - All rights reserved

---

Built with ❤️ for local communities
