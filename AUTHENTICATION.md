# Authentication Implementation

## Overview

Socoto implements role-based authentication using Supabase Auth with three distinct user types:
- **User**: Standard user account for browsing, bookings, and social features
- **Business Owner**: Account with privileges to create and manage business profiles
- **Admin**: Full system access with moderation capabilities

## Architecture

### Database Schema

The authentication system uses PostgreSQL with Supabase Auth, extending the base `auth.users` table with a custom `profiles` table that includes role information.

**Migration File**: `database/migrations/001_initial_schema.sql`

Key features:
- Row Level Security (RLS) enabled on all tables
- Automatic profile creation on user signup via triggers
- Role-based policies for data access control
- PostGIS support for location-based queries

### User Roles

#### User Type Enum
```swift
enum UserType: String, Codable {
    case user = "user"
    case businessOwner = "business_owner"
    case admin = "admin"
}
```

#### Capabilities by Role

**User**:
- Browse businesses and view profiles
- Create posts and comments
- Leave reviews
- Make bookings
- Follow businesses
- Send messages
- View campaigns and claim discounts

**Business Owner** (includes all User capabilities plus):
- Create and manage business profiles
- Manage bookings for their businesses
- Create and manage campaigns
- Respond to reviews
- Access business analytics
- Manage subscriptions (Stripe)

**Admin** (includes all Business Owner capabilities plus):
- Moderate content (posts, reviews, comments)
- Manage user reports
- Manage categories
- Access all system features
- View admin dashboard

## Implementation

### Models

**Location**: `Socoto/Models/`

1. **UserType.swift** - User role enum with permission helpers
2. **User.swift** - User profile model with Codable support

### Services

**Location**: `Socoto/Services/Authentication/`

**AuthenticationService.swift** - Comprehensive auth service with:
- Sign up with role selection
- Sign in / Sign out
- Password reset
- Profile management
- Role-based access control helpers
- Email and password validation
- Error handling

Key methods:
```swift
// Authentication
func signUp(email:password:fullName:userType:) async throws
func signIn(email:password:) async throws
func signOut() async throws
func resetPassword(email:) async throws

// Authorization
func canManageBusiness() -> Bool
func isAdmin() -> Bool
func requireBusinessOwner() throws
func requireAdmin() throws
```

### Views

**Location**: `Socoto/Views/Authentication/`

1. **SignInView.swift** - Glassmorphic sign in interface
2. **SignUpView.swift** - Sign up with role selection and password strength indicator

Features:
- Glassmorphic design matching iOS app aesthetic
- Real-time form validation
- Password strength indicator
- Role selection UI
- Error handling with user-friendly messages

## Row Level Security (RLS) Policies

### Profiles
- Anyone can view public profiles
- Users can update their own profile
- Profile creation handled automatically on signup

### Businesses
- Anyone can view active businesses
- Only business owners can create businesses
- Owners can manage their own businesses

### Posts & Comments
- Public read access
- Authenticated users can create
- Authors can update/delete their own content

### Reviews
- Public read access
- Users can create one review per business
- Reviewers can update/delete their own reviews

### Bookings
- Private: only customer and business owner can view
- Users can create bookings
- Both parties can update status

### Messages
- Private: only conversation participants
- End-to-end privacy through RLS

## Configuration

### Environment Variables

Required in `.env`:
```bash
SUPABASE_PROJECT_ID=vvxtxhmcbmordfmyuzar
SUPABASE_URL=https://vvxtxhmcbmordfmyuzar.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
SUPABASE_DB_PASSWORD=Drastic10+
```

**Accessed via**: `Config.Supabase.*` in Swift code

### Database Setup

1. **Run the migration**:
```bash
supabase db push database/migrations/001_initial_schema.sql
```

2. **Verify tables created**:
```bash
supabase db pull
```

3. **Check RLS policies**:
```sql
SELECT * FROM pg_policies WHERE schemaname = 'public';
```

## Security Features

### Password Requirements
- Minimum 8 characters
- Must contain uppercase letter
- Must contain lowercase letter
- Must contain number
- Strength indicator provides visual feedback

### Email Validation
- RFC-compliant email regex validation
- Case-insensitive handling

### Session Management
- Automatic session refresh
- Secure token storage
- Auth state listener for real-time updates

### Data Protection
- Row Level Security on all tables
- Service role key stored securely in `.env`
- Database password encrypted at rest
- HTTPS-only communication

## Usage Examples

### Sign Up New User
```swift
let authService = AuthenticationService.shared

try await authService.signUp(
    email: "user@example.com",
    password: "SecurePass123",
    fullName: "John Doe",
    userType: .user
)
```

### Sign In
```swift
try await authService.signIn(
    email: "user@example.com",
    password: "SecurePass123"
)
```

### Check Permissions
```swift
// Check if user can create business
if authService.canManageBusiness() {
    // Show create business UI
}

// Require business owner access
do {
    try authService.requireBusinessOwner()
    // Proceed with business operations
} catch {
    // Show permission denied
}
```

### Update Profile
```swift
let updates = UserUpdateData(
    fullName: "John Doe Jr.",
    bio: "Local business enthusiast",
    city: "San Francisco",
    state: "CA"
)

try await authService.updateProfile(updates)
```

## Next Steps

### Required for Production

1. **Add Supabase Swift Package**:
   ```swift
   // Package.swift
   .package(url: "https://github.com/supabase/supabase-swift", from: "1.0.0")
   ```

2. **Uncomment Supabase code**:
   - `AuthenticationService.swift`
   - `SupabaseService.swift`

3. **Get Supabase Anon Key**:
   - Visit Supabase Dashboard → Project Settings → API
   - Copy the `anon` public key
   - Add to `.env` as `SUPABASE_ANON_KEY`

4. **Test Authentication Flow**:
   - Sign up with different user types
   - Verify profile creation
   - Test RLS policies
   - Validate role-based access

### Enhancements

- [ ] Social authentication (Google, Apple)
- [ ] Two-factor authentication (2FA)
- [ ] Email verification flow
- [ ] Password reset UI
- [ ] Session timeout handling
- [ ] Biometric authentication
- [ ] Account deletion
- [ ] Profile picture upload

## Testing

### Manual Testing Checklist

- [ ] Sign up as regular user
- [ ] Sign up as business owner
- [ ] Sign in with valid credentials
- [ ] Sign in with invalid credentials
- [ ] Password validation (weak passwords rejected)
- [ ] Email validation (invalid emails rejected)
- [ ] Password reset email sent
- [ ] Profile update persists
- [ ] Sign out clears session
- [ ] Auth state persists across app restarts

### Database Testing

```sql
-- Test profile creation trigger
INSERT INTO auth.users (id, email) VALUES (uuid_generate_v4(), 'test@test.com');

-- Verify profile created
SELECT * FROM profiles WHERE id = (SELECT id FROM auth.users WHERE email = 'test@test.com');

-- Test RLS policy
SET ROLE authenticated;
SELECT * FROM businesses; -- Should only show active businesses
```

## Troubleshooting

### Common Issues

**"Supabase package not yet configured"**
- Add Supabase Swift package to project
- Uncomment implementation code

**"SUPABASE_ANON_KEY is empty"**
- Get anon key from Supabase Dashboard
- Add to `.env` file

**"Row Level Security policy violation"**
- Check RLS policies are enabled
- Verify user has correct permissions
- Review policy definitions in migration

**Profile not created on signup**
- Check trigger `on_auth_user_created` exists
- Verify function `handle_new_user()` is defined
- Check metadata passed in signup

## References

- [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- [Supabase RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL RLS](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [Supabase Swift Client](https://github.com/supabase/supabase-swift)
