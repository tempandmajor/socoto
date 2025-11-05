#!/bin/bash
#
# Secure Credential Management System
# This script provides secure credential loading and validation
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
CREDENTIALS_DIR="$HOME/.socoto/credentials"
BACKUP_DIR="$HOME/.socoto/backups"
LOG_FILE="$HOME/.socoto/logs/credentials.log"

# Ensure directories exist
mkdir -p "$CREDENTIALS_DIR"
mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# Set secure permissions
chmod 700 "$CREDENTIALS_DIR"
chmod 700 "$BACKUP_DIR"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Print functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
    log "SUCCESS: $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    log "ERROR: $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    log "WARNING: $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
    log "INFO: $1"
}

# Check if credential file exists and is secure
check_credential_file() {
    local file=$1

    if [ ! -f "$file" ]; then
        print_error "Credential file not found: $file"
        return 1
    fi

    # Check file permissions (should be 600 or 400)
    local perms=$(stat -c "%a" "$file" 2>/dev/null || stat -f "%A" "$file" 2>/dev/null)
    if [ "$perms" != "600" ] && [ "$perms" != "400" ]; then
        print_warning "Insecure permissions on $file (current: $perms, expected: 600)"
        chmod 600 "$file"
        print_success "Fixed permissions to 600"
    fi

    return 0
}

# Load credentials from file
load_credentials() {
    local service=$1
    local cred_file="$CREDENTIALS_DIR/${service}.env"

    if ! check_credential_file "$cred_file"; then
        return 1
    fi

    # Source the file
    set -a
    source "$cred_file"
    set +a

    print_success "Loaded credentials for $service"
    return 0
}

# Validate Supabase credentials
validate_supabase() {
    local required_vars=("SUPABASE_URL" "SUPABASE_ANON_KEY" "SUPABASE_SERVICE_ROLE_KEY")
    local missing=()

    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            missing+=("$var")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        print_error "Missing Supabase credentials: ${missing[*]}"
        return 1
    fi

    # Validate URL format
    if [[ ! "$SUPABASE_URL" =~ ^https://.*\.supabase\.co$ ]]; then
        print_warning "Supabase URL format may be incorrect: $SUPABASE_URL"
    fi

    # Validate key format (should start with eyJ)
    if [[ ! "$SUPABASE_ANON_KEY" =~ ^eyJ ]]; then
        print_warning "Supabase anon key format may be incorrect"
    fi

    if [[ ! "$SUPABASE_SERVICE_ROLE_KEY" =~ ^eyJ ]]; then
        print_warning "Supabase service role key format may be incorrect"
    fi

    print_success "Supabase credentials validated"
    return 0
}

# Validate Stripe credentials
validate_stripe() {
    local required_vars=("STRIPE_SECRET_KEY" "STRIPE_PUBLISHABLE_KEY")
    local missing=()

    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            missing+=("$var")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        print_error "Missing Stripe credentials: ${missing[*]}"
        return 1
    fi

    # Validate key format
    if [[ "$STRIPE_SECRET_KEY" =~ ^sk_test_ ]]; then
        print_info "Using Stripe TEST mode"
    elif [[ "$STRIPE_SECRET_KEY" =~ ^sk_live_ ]]; then
        print_warning "Using Stripe LIVE mode - be careful!"
    else
        print_warning "Stripe secret key format may be incorrect"
    fi

    if [[ ! "$STRIPE_PUBLISHABLE_KEY" =~ ^pk_ ]]; then
        print_warning "Stripe publishable key format may be incorrect"
    fi

    print_success "Stripe credentials validated"
    return 0
}

# Validate AWS credentials
validate_aws() {
    local required_vars=("AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "AWS_REGION" "AWS_S3_BUCKET")
    local missing=()

    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            missing+=("$var")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        print_error "Missing AWS credentials: ${missing[*]}"
        return 1
    fi

    # Validate region format
    if [[ ! "$AWS_REGION" =~ ^[a-z]{2}-[a-z]+-[0-9]$ ]]; then
        print_warning "AWS region format may be incorrect: $AWS_REGION"
    fi

    print_success "AWS credentials validated"
    return 0
}

# Create credential template
create_template() {
    local service=$1
    local template_file="$CREDENTIALS_DIR/${service}.env.template"

    case $service in
        supabase)
            cat > "$template_file" << 'EOF'
# Supabase Credentials
# Get these from: https://app.supabase.com/project/_/settings/api

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...your-anon-key
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...your-service-role-key

# Optional: Project reference for CLI
SUPABASE_PROJECT_REF=your-project-ref
EOF
            ;;
        stripe)
            cat > "$template_file" << 'EOF'
# Stripe Credentials
# Get these from: https://dashboard.stripe.com/test/apikeys

# Use test keys for development (sk_test_...)
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...

# Webhook signing secret (for webhook verification)
STRIPE_WEBHOOK_SECRET=whsec_...

# Optional: Stripe Connect (if using)
# STRIPE_CONNECT_CLIENT_ID=ca_...
EOF
            ;;
        aws)
            cat > "$template_file" << 'EOF'
# AWS Credentials
# Get these from: https://console.aws.amazon.com/iam/

AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1

# S3 Buckets
AWS_S3_BUCKET=socoto-main
AWS_S3_PROFILE_BUCKET=socoto-profiles
AWS_S3_BUSINESS_BUCKET=socoto-businesses
AWS_S3_POST_BUCKET=socoto-posts
AWS_S3_MESSAGE_BUCKET=socoto-messages
EOF
            ;;
        github)
            cat > "$template_file" << 'EOF'
# GitHub Credentials
# Get these from: https://github.com/settings/tokens

GITHUB_TOKEN=ghp_...
GITHUB_REPO_OWNER=tempandmajor
GITHUB_REPO_NAME=socoto
EOF
            ;;
    esac

    chmod 600 "$template_file"
    print_success "Created template: $template_file"
}

# Backup credentials
backup_credentials() {
    local timestamp=$(date +'%Y%m%d_%H%M%S')
    local backup_file="$BACKUP_DIR/credentials_$timestamp.tar.gz.gpg"

    print_info "Creating encrypted backup..."

    # Create encrypted backup
    tar -czf - -C "$CREDENTIALS_DIR" . | gpg --symmetric --cipher-algo AES256 -o "$backup_file" 2>/dev/null || {
        print_warning "GPG not available, creating unencrypted backup"
        backup_file="$BACKUP_DIR/credentials_$timestamp.tar.gz"
        tar -czf "$backup_file" -C "$CREDENTIALS_DIR" .
        chmod 600 "$backup_file"
    }

    print_success "Backup created: $backup_file"
}

# Main command handler
case "${1:-help}" in
    load)
        if [ -z "${2:-}" ]; then
            print_error "Usage: $0 load <service>"
            exit 1
        fi
        load_credentials "$2"
        ;;
    validate)
        service="${2:-all}"
        if [ "$service" = "all" ]; then
            load_credentials "supabase" && validate_supabase
            load_credentials "stripe" && validate_stripe
            load_credentials "aws" && validate_aws
        else
            load_credentials "$service"
            case $service in
                supabase) validate_supabase ;;
                stripe) validate_stripe ;;
                aws) validate_aws ;;
                *) print_error "Unknown service: $service" ;;
            esac
        fi
        ;;
    template)
        if [ -z "${2:-}" ]; then
            print_error "Usage: $0 template <service>"
            exit 1
        fi
        create_template "$2"
        ;;
    backup)
        backup_credentials
        ;;
    status)
        print_info "Credential files in $CREDENTIALS_DIR:"
        ls -lh "$CREDENTIALS_DIR"/*.env 2>/dev/null || print_warning "No credential files found"
        ;;
    help|*)
        cat << 'EOF'
Socoto Secure Credential Management

Usage: ./scripts/credentials.sh <command> [options]

Commands:
    load <service>       Load credentials for a service
    validate [service]   Validate credentials (all services or specific)
    template <service>   Create credential template file
    backup              Create encrypted backup of credentials
    status              Show status of credential files
    help                Show this help message

Services:
    supabase            Supabase credentials
    stripe              Stripe credentials
    aws                 AWS credentials
    github              GitHub credentials

Examples:
    ./scripts/credentials.sh template supabase
    ./scripts/credentials.sh load supabase
    ./scripts/credentials.sh validate all
    ./scripts/credentials.sh backup

Security:
    - Credentials stored in: $HOME/.socoto/credentials/
    - File permissions: 600 (read/write owner only)
    - Backups encrypted with GPG
    - Never commit credential files to git

EOF
        ;;
esac
