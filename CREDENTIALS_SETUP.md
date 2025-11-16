# Credentials Setup Guide

This document explains how credentials are managed securely in the Socoto project.

## Security Overview

All sensitive credentials are stored in the `.env` file which is:
- **NEVER committed to git** (protected by `.gitignore`)
- **Stored only locally** on your development machine
- **Not included in the Xcode project**
- **Client-safe keys only** - no server secrets in the iOS app

## Security Principles

### ✅ Client-Safe Credentials (OK for iOS app)
- `SUPABASE_ANON_KEY` - Public anonymous key (safe)
- `STRIPE_PUBLISHABLE_KEY` - Public publishable key (safe)

### ❌ Server-Only Credentials (NEVER in iOS app)
- `SUPABASE_SERVICE_ROLE_KEY` - Backend only, bypasses RLS
- `STRIPE_SECRET_KEY` - Backend only, unrestricted API access
- `AWS_ACCESS_KEY_ID` - Not needed, use Supabase Storage
- `AWS_SECRET_ACCESS_KEY` - Not needed, use Supabase Storage

## Setup Instructions

1. **Copy the template file:**
   ```bash
   cp .env.example .env
   ```

2. **Fill in your credentials in `.env`:**
   ```bash
   # Supabase Configuration (Required)
   SUPABASE_URL=https://your_project_id.supabase.co
   SUPABASE_ANON_KEY=your_anon_key_here

   # Stripe Configuration (Optional)
   STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key

   # App Configuration
   APP_ENV=development
   ```

3. **Never commit `.env` to git:**
   The `.gitignore` file ensures this won't happen accidentally.

## Supabase Setup

### 1. Get Your Credentials

From your Supabase project dashboard:
- Project URL: Settings → API → Project URL
- Anon Key: Settings → API → Project API keys → `anon` `public`

⚠️ **DO NOT use the `service_role` key in your iOS app!**

### 2. Configure Storage Buckets

Create storage buckets in Supabase Dashboard or via SQL:

```sql
-- Run in Supabase SQL Editor
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('user-profiles', 'user-profiles', true),
  ('business-media', 'business-media', true),
  ('post-media', 'post-media', true),
  ('message-attachments', 'message-attachments', false);

-- Set up RLS policies (example for user-profiles)
CREATE POLICY "Anyone can view public avatars"
ON storage.objects FOR SELECT
USING (bucket_id = 'user-profiles');

CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'user-profiles'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

### 3. Enable RLS on All Tables

Ensure Row Level Security is enabled:

```sql
-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
-- ... etc for all tables
```

## Stripe Setup (Optional)

1. Get your **publishable** key from Stripe Dashboard
2. Add to `.env`:
   ```bash
   STRIPE_PUBLISHABLE_KEY=pk_test_51...
   ```

⚠️ **Never add `STRIPE_SECRET_KEY` to `.env`**

For payment processing:
- Use Stripe's iOS SDK with publishable key
- Process payments via backend server with secret key
- Verify webhooks on backend server

## iOS Configuration

The app automatically loads credentials from `.env` via `Config.swift`:

```swift
// Access credentials
Config.Supabase.url          // Supabase URL
Config.Supabase.anonKey      // Supabase anon key
Config.Stripe.publishableKey // Stripe publishable key
```

### Environment Variables in Xcode

For CI/CD or Xcode Cloud, set environment variables:

1. Edit Scheme → Run → Arguments
2. Add Environment Variables:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `STRIPE_PUBLISHABLE_KEY`

## Production Deployment

For production builds:

### 1. Use Xcode Cloud Environment Variables
- Go to Xcode Cloud → Environment
- Add production credentials as secrets
- Never commit production keys

### 2. Separate Environments
```bash
# Development
SUPABASE_URL=https://dev-project.supabase.co
APP_ENV=development

# Staging
SUPABASE_URL=https://staging-project.supabase.co
APP_ENV=staging

# Production
SUPABASE_URL=https://prod-project.supabase.co
APP_ENV=production
```

### 3. Backend API for Sensitive Operations

Create a backend server for:
- Processing Stripe payments (use secret key)
- Admin operations (use service role key)
- Sending emails/SMS
- Webhook handling

Never perform these in the iOS app.

## Security Checklist

- [ ] `.env` file exists and is in `.gitignore`
- [ ] Only client-safe keys in `.env`
- [ ] No hardcoded credentials in Swift files
- [ ] RLS enabled on all Supabase tables
- [ ] Storage bucket policies configured
- [ ] Separate credentials for dev/staging/production
- [ ] Backend server handles sensitive operations
- [ ] MFA enabled on Supabase account
- [ ] MFA enabled on Stripe account

## Troubleshooting

### "Missing configuration keys" warning

The app validates required credentials on launch:

```swift
// Check Config.swift validation
let missingKeys = Config.validateConfiguration()
if !missingKeys.isEmpty {
    print("⚠️ Warning: Missing configuration keys: \(missingKeys)")
}
```

### Supabase Storage "forbidden" errors

1. Check RLS policies on `storage.objects`
2. Verify bucket is public (if needed)
3. Ensure user is authenticated
4. Check bucket name matches exactly

### Stripe errors

1. Verify you're using **publishable** key (`pk_test_...`)
2. Check key is for correct environment (test vs live)
3. Ensure Stripe iOS SDK is configured correctly

## Migration from AWS S3

If you previously used AWS S3:

1. **Remove AWS credentials from `.env`**
2. **Delete old S3 files** from project
3. **Update uploads** to use `SupabaseStorageService`
4. **Migrate existing media** to Supabase Storage (if needed)

```swift
// Old (AWS S3)
// S3StorageService.shared.uploadImage(...)

// New (Supabase Storage)
SupabaseStorageService.shared.uploadProfileImage(image, userId: userId)
```

## Security Notes

- **Rotate credentials** after sharing in any conversation/chat
- **Monitor credential usage** via Supabase Dashboard
- **Use separate accounts** for dev/staging/production
- **Enable audit logs** in Supabase
- **Review RLS policies** regularly
- **Never log credentials** in analytics or crash reports

## Support

For security concerns, contact the development team immediately.

---

**Remember**: When in doubt, keep it out. It's better to fetch secrets from a backend server than risk exposing them in the iOS app.
