# Credentials Setup Guide

This document explains how credentials are managed securely in the Socoto project.

## Security Overview

All sensitive credentials are stored in the `.env` file which is:
- **NEVER committed to git** (protected by `.gitignore`)
- **Stored only locally** on your development machine
- **Not included in the Xcode project**

## Setup Instructions

1. **Copy the template file:**
   ```bash
   cp .env.example .env
   ```

2. **Fill in your credentials in `.env`:**
   - AWS credentials for S3 storage
   - Supabase keys for database and authentication
   - Stripe keys for payment processing
   - GitHub token for CI/CD (if needed)

3. **Never commit `.env` to git:**
   The `.gitignore` file ensures this won't happen accidentally.

## Verified Services

✅ **AWS Access Verified**
- Account ID: 798701233429
- Region: us-east-2

✅ **Supabase Access Verified**
- Project: socoto (vvxtxhmcbmordfmyuzar)
- Project ID: Configured in `.env`
- Service Role Key: Configured in `.env`
- Access Token: Configured for CLI usage
- Status: ACTIVE_HEALTHY
- Database: PostgreSQL 17.6.1.038
- CLI: Installed and ready
- ⚠️ **TODO**: Add SUPABASE_ANON_KEY for client-side app access

✅ **Stripe Access Verified**
- Account: Socoto (acct_1SQBLEPgqpwpKROa)
- Publishable Key: Configured in `.env`
- Secret Key: Configured in `.env`
- CLI: Installed and configured

## iOS Configuration

For the iOS app to access these credentials:
1. Consider using a Swift configuration manager (e.g., `dotenv` library)
2. Alternatively, use Xcode schemes with environment variables
3. Never hardcode credentials in Swift files

## Production Deployment

For production:
- Use AWS Secrets Manager for credential storage
- Use Xcode Cloud environment variables
- Implement proper key rotation policies
- Use separate credentials for dev/staging/production

## CLI Tools

### Stripe CLI
- **Version**: 1.21.8
- **Location**: `~/.local/bin/stripe`
- **Configuration**: `~/.config/stripe/config.toml`
- **Usage**:
  ```bash
  stripe customers list
  stripe listen --forward-to localhost:3000/webhook
  ```

### Supabase CLI
- **Version**: 2.54.11
- **Location**: `~/.local/bin/supabase`
- **Usage**:
  ```bash
  export SUPABASE_ACCESS_TOKEN=<your_token>
  supabase link --project-ref vvxtxhmcbmordfmyuzar
  supabase db pull
  ```

## Security Notes

- **Rotate GitHub token** after sharing in any conversation/chat
- **Use IAM roles** instead of access keys when possible
- **Enable MFA** on all service accounts
- **Monitor credential usage** via AWS CloudTrail, Stripe Dashboard
