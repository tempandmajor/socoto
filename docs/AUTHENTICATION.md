# Authentication System Documentation

## Overview

Complete authentication flow for the Socoto iOS app with glassmorphic UI design. The system supports email/password authentication, role-based access (User vs Business Owner), and password reset functionality.

## Architecture

### Components

#### 1. **AuthViewModel** (`Features/Auth/ViewModels/AuthViewModel.swift`)
Central state management for authentication:
- **Published Properties:**
  - `isAuthenticated`: Boolean indicating auth state
  - `currentUser`: User profile object
  - `isLoading`: Loading state for async operations
  - `errorMessage`: Error messages for user feedback
  - `successMessage`: Success messages for user feedback

- **Methods:**
  - `checkAuthStatus()`: Checks for existing session on app launch
  - `signIn(email:password:)`: Authenticates user with email/password
  - `signUp(email:password:fullName:role:)`: Creates new user account
  - `signOut()`: Signs out current user
  - `resetPassword(email:)`: Sends password reset email

#### 2. **Authentication Views**

##### WelcomeView (`Features/Auth/Views/WelcomeView.swift`)
- Entry point for unauthenticated users
- Animated gradient background
- Feature highlights
- Buttons to sign up or sign in

##### SignUpView (`Features/Auth/Views/SignUpView.swift`)
- User registration with role selection
- Fields: Full Name, Email, Password, Confirm Password
- Role cards: User vs Business Owner
- Terms & conditions checkbox
- Password validation and matching
- Navigation to sign in

##### SignInView (`Features/Auth/Views/SignInView.swift`)
- Email/password authentication
- Forgot password link
- Social sign-in placeholders (Apple, Google)
- Navigation to sign up
- Form validation

##### ForgotPasswordView (`Features/Auth/Views/ForgotPasswordView.swift`)
- Password reset via email
- Success confirmation
- Back to sign in navigation

#### 3. **Data Models** (`Models/User.swift`)

##### Profile
```swift
struct Profile: Codable, Identifiable {
    let id: String
    let email: String
    let fullName: String
    let role: String
    let avatarUrl: String?
    let bio: String?
    let location: String?
    let phoneNumber: String?
    let preferences: UserPreferences?
    let createdAt: Date
    let updatedAt: Date
}
```

##### UserRole Enum
```swift
enum UserRole: String, CaseIterable {
    case user = "user"
    case businessOwner = "business_owner"
}
```

#### 4. **App Integration** (`SocotoApp.swift`)
- Creates AuthViewModel as `@StateObject`
- Routes based on auth state:
  - Loading → `LoadingView`
  - Authenticated → `TabBarView`
  - Not Authenticated → `WelcomeView`
- Passes authViewModel as environment object

## User Flows

### 1. Sign Up Flow
```
WelcomeView
  → Tap "Create Account"
  → SignUpView
    → Select Role (User or Business Owner)
    → Enter Full Name
    → Enter Email
    → Enter Password
    → Confirm Password
    → Accept Terms
    → Tap "Create Account"
    → [Success] Shows confirmation message
    → [Auto] Navigate to main app
```

### 2. Sign In Flow
```
WelcomeView
  → Tap "Sign In"
  → SignInView
    → Enter Email
    → Enter Password
    → Tap "Sign In"
    → [Success] Navigate to main app
```

### 3. Password Reset Flow
```
SignInView
  → Tap "Forgot Password?"
  → ForgotPasswordView
    → Enter Email
    → Tap "Send Reset Link"
    → [Success] Show confirmation
    → Tap "Back to Sign In"
    → SignInView
```

### 4. Sign Out Flow
```
TabBarView
  → Navigate to Profile Tab
  → Tap "Sign Out"
  → [Confirm] Sign out
  → Navigate to WelcomeView
```

## Form Validation

### Sign Up Validation
- ✅ Email: Valid email format (regex validation)
- ✅ Full Name: Not empty
- ✅ Password: Minimum 8 characters
- ✅ Confirm Password: Matches password
- ✅ Terms: Must be accepted
- ✅ Role: Must select one (default: User)

### Sign In Validation
- ✅ Email: Valid email format
- ✅ Password: Not empty

### Password Reset Validation
- ✅ Email: Valid email format

## Design Features

### Glassmorphic Components Used
- `GlassTextField`: Text input fields with glass effect
- `GlassButton`: Primary, secondary, accent, destructive buttons
- `GlassCard`: Content containers
- `GlassmorphicModifier`: Custom glass effect

### Animations
- Spring animations for role selection
- Fade transitions for messages
- Scale effects on button press
- Animated gradient backgrounds
- Tab selection with matched geometry effect

### Color Scheme
- Primary: Blue gradient (`#4A90E2`)
- Secondary: Purple gradient (`#9B59B6`)
- Accent: Teal (`#1ABC9C`)
- Error: Red (`#E74C3C`)
- Success: Green (`#2ECC71`)

## Integration with Supabase

### Required Setup
1. Add Supabase Swift package to Xcode project
2. Uncomment import statements in `SupabaseService.swift`
3. Uncomment implementation code in auth methods
4. Configure Supabase credentials in `.env`:
   ```
   SUPABASE_URL=your_project_url
   SUPABASE_ANON_KEY=your_anon_key
   ```

### Database Schema
The auth system expects these Supabase tables:

#### profiles table
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  email TEXT NOT NULL,
  full_name TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user',
  avatar_url TEXT,
  bio TEXT,
  location TEXT,
  phone_number TEXT,
  preferences JSONB,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### Row Level Security (RLS)
```sql
-- Users can read their own profile
CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);
```

## Testing Guide

### Manual Testing Checklist

#### Sign Up Tests
- [ ] Create user account with valid data
- [ ] Create business owner account
- [ ] Try sign up with invalid email
- [ ] Try sign up with short password (<8 chars)
- [ ] Try sign up with mismatched passwords
- [ ] Try sign up without accepting terms
- [ ] Verify email validation message shows

#### Sign In Tests
- [ ] Sign in with valid credentials
- [ ] Try sign in with wrong password
- [ ] Try sign in with non-existent email
- [ ] Try sign in with invalid email format
- [ ] Verify error messages display correctly

#### Password Reset Tests
- [ ] Request password reset with valid email
- [ ] Request reset with invalid email
- [ ] Verify success message appears
- [ ] Check email for reset link

#### Navigation Tests
- [ ] Navigate from Welcome → Sign Up
- [ ] Navigate from Welcome → Sign In
- [ ] Navigate from Sign In → Forgot Password
- [ ] Navigate from Sign Up → Sign In
- [ ] Verify back buttons work correctly

#### Profile Tests
- [ ] View profile after sign in
- [ ] Verify user info displays correctly
- [ ] Verify role badge shows correct role
- [ ] Sign out from profile
- [ ] Verify returns to Welcome screen

#### UI/UX Tests
- [ ] Verify glassmorphic effects render correctly
- [ ] Test animations (role selection, buttons)
- [ ] Test loading states
- [ ] Test error message display
- [ ] Test success message display
- [ ] Verify keyboard behavior (next, go, dismiss)
- [ ] Test on different screen sizes

### Automated Testing (Future)

#### Unit Tests
```swift
// AuthViewModelTests.swift
func testSignInWithValidCredentials()
func testSignInWithInvalidEmail()
func testSignUpWithValidData()
func testSignUpWithShortPassword()
func testPasswordResetWithValidEmail()
func testEmailValidation()
```

#### UI Tests
```swift
// AuthenticationUITests.swift
func testCompleteSignUpFlow()
func testCompleteSignInFlow()
func testPasswordResetFlow()
func testNavigationBetweenAuthScreens()
```

## Error Handling

### Common Errors
| Error | Message | Resolution |
|-------|---------|------------|
| Invalid email | "Please enter a valid email address" | Enter valid email format |
| Short password | "Password must be at least 8 characters" | Use longer password |
| Password mismatch | "Passwords do not match" | Ensure passwords match |
| Empty fields | "Please enter your [field]" | Fill required field |
| Sign in failed | "Sign in failed: [error]" | Check credentials |
| Network error | "Sign in failed: [error]" | Check internet connection |

## Security Features

### Implemented
- ✅ Password minimum length (8 characters)
- ✅ Email validation (regex)
- ✅ Secure password input (masked)
- ✅ Role-based access control
- ✅ Session management
- ✅ Auth state persistence check

### Planned
- [ ] Password strength meter
- [ ] 2FA/MFA support
- [ ] Biometric authentication (Face ID/Touch ID)
- [ ] Rate limiting for auth attempts
- [ ] Password complexity requirements
- [ ] Email verification enforcement
- [ ] OAuth providers (Apple, Google)

## File Structure

```
Socoto/
├── Features/
│   └── Auth/
│       ├── ViewModels/
│       │   └── AuthViewModel.swift
│       └── Views/
│           ├── WelcomeView.swift
│           ├── SignUpView.swift
│           ├── SignInView.swift
│           └── ForgotPasswordView.swift
├── Models/
│   └── User.swift
├── Services/
│   └── API/
│       └── SupabaseService.swift (updated)
├── Core/
│   └── Navigation/
│       └── TabBarView.swift (updated)
└── SocotoApp.swift (updated)
```

## Next Steps

### Immediate (Required for Testing)
1. **Install Supabase Package**
   - Open Xcode project
   - File → Add Package Dependencies
   - Add `https://github.com/supabase/supabase-swift`
   - Uncomment imports in SupabaseService.swift

2. **Configure Credentials**
   - Create `.env` file in project root
   - Add Supabase URL and anon key
   - Verify Config.swift loads credentials

3. **Test Authentication**
   - Build and run app (⌘R)
   - Test sign up flow
   - Test sign in flow
   - Test password reset
   - Test sign out

### Phase 2 (Next Ticket)
- [ ] User Profile Editing (Ticket 6)
- [ ] Profile photo upload to S3
- [ ] Location picker integration
- [ ] Preferences management

### Phase 3 (Future Enhancement)
- [ ] Social authentication (Apple, Google)
- [ ] Biometric authentication
- [ ] Multi-factor authentication
- [ ] Email verification flow
- [ ] Account deletion
- [ ] Session management improvements

## Troubleshooting

### Issue: App shows loading screen forever
**Solution:** Check Supabase package is installed and credentials are configured

### Issue: "Supabase package not yet configured" error
**Solution:**
1. Install Supabase Swift package
2. Uncomment imports in SupabaseService.swift
3. Uncomment implementation code in auth methods

### Issue: Sign up succeeds but user not created
**Solution:**
1. Check Supabase database triggers
2. Verify profiles table exists
3. Check RLS policies allow inserts

### Issue: Profile doesn't show after sign in
**Solution:**
1. Check fetchProfile method in SupabaseService
2. Verify profiles table has data
3. Check RLS policies allow reads

### Issue: Glassmorphic effects not visible
**Solution:**
1. Ensure app runs in dark mode (`.preferredColorScheme(.dark)`)
2. Check iOS version (requires iOS 15+)
3. Verify AppTheme colors are configured

## Support

For issues or questions:
- Check this documentation
- Review code comments in auth files
- Test with mock data first
- Verify Supabase console for backend issues

## Changelog

### v1.0.0 (Current)
- ✅ Complete authentication UI with glassmorphic design
- ✅ AuthViewModel for state management
- ✅ Welcome, Sign Up, Sign In, Forgot Password views
- ✅ Role selection (User vs Business Owner)
- ✅ Form validation
- ✅ Error handling
- ✅ Profile view with sign out
- ✅ Auth state routing in app
- ✅ User model and preferences
- ✅ Integration with SupabaseService

---

**Status:** ✅ Complete and ready for Supabase integration
**Next Ticket:** User Profiles (Ticket 6)
**Commit:** `dbaf770` - "Implement complete authentication flow with glassmorphic UI"
