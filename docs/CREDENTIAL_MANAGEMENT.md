# Secure Credential Management Guide

## 🔒 Overview

This guide explains how to securely manage credentials for the Socoto project using our custom credential management system.

## 📦 What's Installed

### CLIs Installed
- ✅ **Supabase CLI** v2.54.11 - Database and auth management
- ✅ **Stripe CLI** v1.32.0 - Payment processing

### Security Tools
- ✅ **Credential Manager (Python)** - Secure credential loading and validation
- ✅ **Credential Script (Bash)** - Command-line credential management
- ✅ **Enhanced .gitignore** - Prevents credential leaks

## 🚀 Quick Start

### Step 1: Create Credential Templates

```bash
# Create templates for all services
./scripts/credential_manager.py template all

# Or create for specific service
./scripts/credential_manager.py template supabase
./scripts/credential_manager.py template stripe
./scripts/credential_manager.py template aws
```

This creates template files in `~/.socoto/credentials/`:
- `supabase.env.template`
- `stripe.env.template`
- `aws.env.template`
- `github.env.template`

### Step 2: Copy and Fill In Credentials

```bash
# Navigate to credentials directory
cd ~/.socoto/credentials/

# Copy template to actual credential file
cp supabase.env.template supabase.env
cp stripe.env.template stripe.env
cp aws.env.template aws.env

# Edit with your actual credentials
nano supabase.env  # or vim, code, etc.
```

### Step 3: Validate Credentials

```bash
# Validate all credentials
./scripts/credential_manager.py validate all

# Or validate specific service
./scripts/credential_manager.py validate supabase
./scripts/credential_manager.py validate stripe
```

## 📋 Credential Requirements

### Supabase Credentials

**Where to get them:** https://app.supabase.com/project/_/settings/api

Required:
```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...
```

Optional:
```bash
SUPABASE_PROJECT_REF=your-project-ref  # For CLI operations
```

### Stripe Credentials

**Where to get them:** https://dashboard.stripe.com/test/apikeys

Required (use TEST keys for development):
```bash
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
```

Optional:
```bash
STRIPE_WEBHOOK_SECRET=whsec_...  # For webhook verification
STRIPE_BUSINESS_SUBSCRIPTION_PRODUCT_ID=prod_...
STRIPE_BUSINESS_SUBSCRIPTION_PRICE_ID=price_...
```

### AWS Credentials

**Where to get them:** https://console.aws.amazon.com/iam/

Required:
```bash
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1
AWS_S3_BUCKET=socoto-main
```

Optional (specific buckets):
```bash
AWS_S3_PROFILE_BUCKET=socoto-profiles
AWS_S3_BUSINESS_BUCKET=socoto-businesses
AWS_S3_POST_BUCKET=socoto-posts
AWS_S3_MESSAGE_BUCKET=socoto-messages
```

### GitHub Credentials (Optional)

**Where to get them:** https://github.com/settings/tokens

```bash
GITHUB_TOKEN=ghp_...
GITHUB_REPO_OWNER=tempandmajor
GITHUB_REPO_NAME=socoto
```

## 🛠️ Using the Credential Manager

### Python Script (Recommended)

```bash
# List all credential files
./scripts/credential_manager.py list

# Load credentials for a service
./scripts/credential_manager.py load supabase

# Export credentials for CLI usage
./scripts/credential_manager.py export supabase
```

### Bash Script (Alternative)

```bash
# Create templates
./scripts/credentials.sh template supabase

# Load credentials
./scripts/credentials.sh load supabase

# Validate credentials
./scripts/credentials.sh validate all

# Create backup
./scripts/credentials.sh backup

# Check status
./scripts/credentials.sh status
```

## 🔐 Security Features

### File Permissions
- All credential files automatically set to `600` (owner read/write only)
- Credential directory set to `700` (owner access only)
- Scripts validate and fix permissions automatically

### Git Protection
Enhanced `.gitignore` prevents committing:
- ✅ `.env` files
- ✅ `.socoto/` directory
- ✅ Any files matching `*_secret_key*`, `*_api_key*`, etc.
- ✅ Credential backups
- ✅ Service-specific config files

### Logging
- All credential operations logged to `~/.socoto/logs/credentials.log`
- Includes timestamps and operation types
- Does NOT log actual credential values

### Backup System
```bash
# Create encrypted backup (requires GPG)
./scripts/credentials.sh backup

# Backups stored in: ~/.socoto/backups/
# Format: credentials_YYYYMMDD_HHMMSS.tar.gz.gpg
```

## 📁 Directory Structure

```
~/.socoto/
├── credentials/           # Actual credential files (600 permissions)
│   ├── supabase.env
│   ├── stripe.env
│   ├── aws.env
│   ├── github.env
│   ├── supabase.env.template
│   ├── stripe.env.template
│   └── ...
├── backups/              # Encrypted credential backups (600 permissions)
│   └── credentials_20251105_123456.tar.gz.gpg
└── logs/                 # Operation logs
    └── credentials.log
```

## 🧪 Testing Credentials

### Test Supabase Connection

```bash
# Load credentials
./scripts/credential_manager.py load supabase

# Test with Supabase CLI
supabase projects list

# Or test API directly
curl -H "apikey: $SUPABASE_ANON_KEY" \
     -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
     "$SUPABASE_URL/rest/v1/"
```

### Test Stripe Connection

```bash
# Load credentials
./scripts/credential_manager.py load stripe

# Configure Stripe CLI
stripe config --set api_key $STRIPE_SECRET_KEY

# Test connection
stripe balance retrieve
stripe products list --limit 3
```

### Test AWS Connection

```bash
# Load credentials
./scripts/credential_manager.py load aws

# Configure AWS CLI
export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION=$AWS_REGION

# Test connection
aws s3 ls
aws s3 ls s3://$AWS_S3_BUCKET
```

## ⚠️ Security Best Practices

### DO ✅
- Store credentials in `~/.socoto/credentials/`
- Use file permissions 600 for credential files
- Use test/development keys for development
- Rotate credentials regularly
- Create backups before making changes
- Validate credentials after updating
- Use environment-specific credential files

### DON'T ❌
- Commit credential files to git
- Share credentials via email or chat
- Use production credentials in development
- Store credentials in code or config files
- Use weak or default passwords
- Share service role keys publicly
- Leave credentials in command history

## 🔧 Troubleshooting

### "Credential file not found"
```bash
# Create template first
./scripts/credential_manager.py template supabase

# Copy and fill in credentials
cp ~/.socoto/credentials/supabase.env.template \
   ~/.socoto/credentials/supabase.env
```

### "Insecure permissions" warning
The script automatically fixes this, but you can manually fix:
```bash
chmod 600 ~/.socoto/credentials/*.env
chmod 700 ~/.socoto/credentials/
```

### Credentials not loading
```bash
# Check file exists and has content
cat ~/.socoto/credentials/supabase.env

# Check permissions
ls -la ~/.socoto/credentials/

# Validate format
./scripts/credential_manager.py validate supabase
```

### "Format may be incorrect" warnings
- Double-check you copied the full key/URL
- Ensure no extra spaces or quotes
- Check the service dashboard for correct format
- Regenerate the credential if needed

## 📝 Example Workflow

### Initial Setup

```bash
# 1. Create all templates
./scripts/credential_manager.py template all

# 2. Fill in Supabase credentials
cd ~/.socoto/credentials/
cp supabase.env.template supabase.env
nano supabase.env  # Add your credentials

# 3. Fill in Stripe credentials
cp stripe.env.template stripe.env
nano stripe.env  # Add your credentials

# 4. Validate everything
cd ~/socoto
./scripts/credential_manager.py validate all

# 5. Test connections
./scripts/credential_manager.py load supabase
supabase projects list

./scripts/credential_manager.py load stripe
stripe balance retrieve
```

### Daily Usage

```bash
# Load credentials for development session
./scripts/credential_manager.py load supabase
./scripts/credential_manager.py load stripe
./scripts/credential_manager.py load aws

# Now use CLIs with loaded credentials
supabase db dump
stripe products list
aws s3 ls
```

### Before Deployment

```bash
# Create backup
./scripts/credentials.sh backup

# Validate all credentials
./scripts/credential_manager.py validate all

# Update production credentials
cp ~/.socoto/credentials/stripe.env.template \
   ~/.socoto/credentials/stripe.production.env
# Fill in production keys

# Verify production config
./scripts/credential_manager.py validate stripe
```

## 🆘 Getting Credentials

### Supabase
1. Go to https://app.supabase.com
2. Select your project
3. Click Settings (⚙️) → API
4. Copy:
   - Project URL
   - `anon` `public` key
   - `service_role` `secret` key

### Stripe
1. Go to https://dashboard.stripe.com
2. **For Development:** Switch to "Test mode" (toggle in top right)
3. Click Developers → API keys
4. Copy:
   - Secret key (starts with `sk_test_`)
   - Publishable key (starts with `pk_test_`)

### AWS
1. Go to https://console.aws.amazon.com/iam/
2. Users → Your user → Security credentials
3. Create access key
4. Download credentials (only shown once!)
5. Note your preferred region (e.g., `us-east-1`)

## 🔄 Credential Rotation

### When to Rotate
- Every 90 days (recommended)
- When a team member leaves
- If credentials may be compromised
- Before major deployments

### How to Rotate

```bash
# 1. Backup current credentials
./scripts/credentials.sh backup

# 2. Generate new credentials on service dashboard

# 3. Update credential file
nano ~/.socoto/credentials/supabase.env

# 4. Validate new credentials
./scripts/credential_manager.py validate supabase

# 5. Test connection
supabase projects list

# 6. Revoke old credentials on service dashboard
```

## 📞 Support

If you encounter issues:
1. Check logs: `~/.socoto/logs/credentials.log`
2. Validate credentials: `./scripts/credential_manager.py validate all`
3. Review this documentation
4. Check service dashboards for API status
5. Ensure you're using test/development keys

---

**Remember:** Never commit credentials to git! The system is designed to keep them secure. 🔒
