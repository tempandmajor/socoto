# Authentication Configuration

## Overview
Socoto uses Supabase Auth with role-based access control to manage users, business owners, and administrators.

## User Types

### 1. Regular Users (`user`)
- Browse businesses and posts
- Create bookings
- Leave reviews
- Send messages
- Follow businesses
- Claim campaigns

### 2. Business Owners (`business_owner`)
- All user permissions
- Create and manage business profiles
- Post content and announcements
- Create campaigns and promotions
- Manage bookings
- Respond to reviews
- Access analytics
- Subscribe to premium features ($20/month for calling)

### 3. Admins (`admin`)
- Full platform access
- Content moderation
- User and business verification
- Handle reports
- System configuration

## Authentication Setup

### Supabase Auth Configuration

1. **Email/Password Authentication** (Primary)
   - Users sign up with email and password
   - Email verification required
   - Password reset via email

2. **Phone Authentication** (Optional)
   - SMS OTP for phone verification
   - Can be used as primary auth method

3. **Social Login** (Future)
   - Apple Sign In (required for iOS)
   - Google Sign In
   - Facebook Login

### Auth Configuration in Supabase Dashboard

```
Authentication Settings:
- Email confirmations: Enabled
- Secure email change: Enabled
- Mailer autoconfirm: Disabled (for production)
- Enable phone confirmations: Enabled (optional)
- Minimum password length: 8 characters
```

### JWT Custom Claims

The `profiles` table automatically creates a profile when a user signs up. The user's role is stored in the `user_type` field.

```sql
-- Automatic profile creation on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name)
    VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Row Level Security (RLS)

All tables have RLS enabled with policies that enforce role-based access:

### Profiles
- ✅ Anyone can view all profiles
- ✅ Users can update their own profile
- ✅ Users can insert their own profile

### Businesses
- ✅ Anyone can view active businesses
- ✅ Business owners can create businesses
- ✅ Business owners can manage their own businesses

### Posts & Comments
- ✅ Anyone can view posts and comments
- ✅ Authenticated users can create posts/comments
- ✅ Authors can edit/delete their own content

### Reviews
- ✅ Anyone can view reviews
- ✅ Authenticated users can create reviews
- ✅ Business owners can respond to reviews about their business

### Bookings
- ✅ Customers can view their own bookings
- ✅ Business owners can view bookings for their business
- ✅ Both parties can update booking status

### Messages
- ✅ Only conversation participants can view/send messages
- ✅ Recipients can mark messages as read

### Subscriptions
- ✅ Business owners can view their own subscription
- ✅ System can create/update subscriptions via service role

### Reports (Moderation)
- ✅ Users can create reports
- ✅ Users can view their own reports
- ✅ Admins can view and manage all reports

## iOS Integration

### Supabase Swift Client Setup

```swift
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://vvxtxhmcbmordfmyuzar.supabase.co")!,
    supabaseKey: "YOUR_ANON_KEY"
)
```

### Sign Up Example

```swift
func signUp(email: String, password: String, fullName: String, userType: UserType) async throws {
    let response = try await supabase.auth.signUp(
        email: email,
        password: password,
        data: [
            "full_name": .string(fullName),
            "user_type": .string(userType.rawValue)
        ]
    )

    // Profile is automatically created via trigger
}
```

### Sign In Example

```swift
func signIn(email: String, password: String) async throws {
    try await supabase.auth.signIn(
        email: email,
        password: password
    )
}
```

### Check User Role

```swift
func getUserProfile() async throws -> Profile {
    let userId = try await supabase.auth.session.user.id

    let profile: Profile = try await supabase
        .from("profiles")
        .select()
        .eq("id", value: userId)
        .single()
        .execute()
        .value

    return profile
}
```

### Session Management

```swift
// Listen to auth state changes
for await state in await supabase.auth.authStateChanges {
    switch state {
    case .signedIn(let session):
        print("User signed in: \(session.user.id)")
    case .signedOut:
        print("User signed out")
    case .initialSession(let session):
        print("Initial session: \(session?.user.id ?? "none")")
    }
}
```

## Security Best Practices

### 1. Password Requirements
- Minimum 8 characters
- Enforce strong passwords in the app
- Consider password strength meter

### 2. Email Verification
- Require email verification before full access
- Send verification email on signup
- Resend option available

### 3. Session Management
- Automatic token refresh
- Secure token storage in iOS Keychain
- Session timeout configuration

### 4. Multi-Factor Authentication (Future)
- TOTP for enhanced security
- SMS backup codes
- Biometric authentication (Face ID/Touch ID)

### 5. Rate Limiting
- Implement rate limiting for auth endpoints
- Prevent brute force attacks
- Monitor failed login attempts

## Role Elevation

### Becoming a Business Owner

Users can upgrade to business owner status by creating a business profile:

```swift
func createBusiness(name: String, category: String, location: Location) async throws {
    // First, update user type
    try await supabase
        .from("profiles")
        .update(["user_type": "business_owner"])
        .eq("id", value: currentUserId)
        .execute()

    // Then create business
    try await supabase
        .from("businesses")
        .insert([
            "owner_id": currentUserId,
            "name": name,
            "category_id": categoryId,
            "location_lat": location.latitude,
            "location_lng": location.longitude,
            // ... other fields
        ])
        .execute()
}
```

## Testing Auth Flow

### Test Accounts

Create test accounts for each role:

```bash
# Regular User
Email: user@test.com
Type: user

# Business Owner
Email: business@test.com
Type: business_owner

# Admin
Email: admin@test.com
Type: admin
```

### Testing Checklist

- [ ] User can sign up with email/password
- [ ] Email verification works
- [ ] User can sign in
- [ ] User can reset password
- [ ] Session persists across app restarts
- [ ] User can sign out
- [ ] RLS policies enforce correct access
- [ ] Role-based features are properly restricted
- [ ] Profile is automatically created on signup

## Troubleshooting

### Common Issues

1. **Profile not created on signup**
   - Check trigger function exists
   - Verify trigger is enabled
   - Check function logs in Supabase

2. **RLS policies blocking legitimate access**
   - Test policies in SQL editor
   - Verify user session is valid
   - Check auth.uid() returns correct value

3. **Session expired errors**
   - Implement automatic token refresh
   - Check network connectivity
   - Verify token expiration settings

## Next Steps

- [ ] Implement Apple Sign In (required for App Store)
- [ ] Add biometric authentication
- [ ] Implement MFA for business accounts
- [ ] Add account deletion flow
- [ ] Implement account linking (merge accounts)
