#!/usr/bin/env python3
"""
Secure Credential Manager for Socoto
Provides secure loading, validation, and management of credentials
"""

import os
import sys
import json
import stat
import getpass
from pathlib import Path
from typing import Dict, Optional, List
from datetime import datetime
import re

class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'  # No Color

class CredentialManager:
    """Secure credential management system"""

    def __init__(self):
        self.home_dir = Path.home()
        self.cred_dir = self.home_dir / '.socoto' / 'credentials'
        self.backup_dir = self.home_dir / '.socoto' / 'backups'
        self.log_dir = self.home_dir / '.socoto' / 'logs'

        # Create directories with secure permissions
        self._setup_directories()

        self.credentials: Dict[str, Dict[str, str]] = {}

    def _setup_directories(self):
        """Create necessary directories with secure permissions"""
        for directory in [self.cred_dir, self.backup_dir, self.log_dir]:
            directory.mkdir(parents=True, exist_ok=True)
            # Set directory permissions to 700 (owner only)
            os.chmod(directory, stat.S_IRWXU)

    def _log(self, message: str, level: str = 'INFO'):
        """Log message to file"""
        log_file = self.log_dir / 'credentials.log'
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        with open(log_file, 'a') as f:
            f.write(f"[{timestamp}] {level}: {message}\n")

    def _print_success(self, message: str):
        """Print success message"""
        print(f"{Colors.GREEN}✓{Colors.NC} {message}")
        self._log(message, 'SUCCESS')

    def _print_error(self, message: str):
        """Print error message"""
        print(f"{Colors.RED}✗{Colors.NC} {message}", file=sys.stderr)
        self._log(message, 'ERROR')

    def _print_warning(self, message: str):
        """Print warning message"""
        print(f"{Colors.YELLOW}⚠{Colors.NC} {message}")
        self._log(message, 'WARNING')

    def _print_info(self, message: str):
        """Print info message"""
        print(f"{Colors.BLUE}ℹ{Colors.NC} {message}")
        self._log(message, 'INFO')

    def _check_file_permissions(self, file_path: Path) -> bool:
        """Check if file has secure permissions"""
        if not file_path.exists():
            return False

        file_stat = file_path.stat()
        mode = stat.filemode(file_stat.st_mode)

        # Should be -rw------- (600) or -r-------- (400)
        if file_stat.st_mode & (stat.S_IRWXG | stat.S_IRWXO):
            self._print_warning(f"Insecure permissions on {file_path.name}")
            # Fix permissions
            os.chmod(file_path, stat.S_IRUSR | stat.S_IWUSR)
            self._print_success(f"Fixed permissions to 600")

        return True

    def load_credentials(self, service: str) -> bool:
        """Load credentials for a specific service"""
        cred_file = self.cred_dir / f"{service}.env"

        if not cred_file.exists():
            self._print_error(f"Credential file not found: {cred_file}")
            return False

        self._check_file_permissions(cred_file)

        # Load credentials
        credentials = {}
        try:
            with open(cred_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    # Skip comments and empty lines
                    if not line or line.startswith('#'):
                        continue

                    # Parse key=value
                    if '=' in line:
                        key, value = line.split('=', 1)
                        credentials[key.strip()] = value.strip()

            self.credentials[service] = credentials
            self._print_success(f"Loaded credentials for {service}")

            # Export to environment
            for key, value in credentials.items():
                os.environ[key] = value

            return True

        except Exception as e:
            self._print_error(f"Error loading credentials: {e}")
            return False

    def validate_supabase(self) -> bool:
        """Validate Supabase credentials"""
        required = ['SUPABASE_URL', 'SUPABASE_ANON_KEY', 'SUPABASE_SERVICE_ROLE_KEY']
        return self._validate_service('supabase', required, {
            'SUPABASE_URL': r'^https://.*\.supabase\.co$',
            'SUPABASE_ANON_KEY': r'^eyJ',
            'SUPABASE_SERVICE_ROLE_KEY': r'^eyJ'
        })

    def validate_stripe(self) -> bool:
        """Validate Stripe credentials"""
        required = ['STRIPE_SECRET_KEY', 'STRIPE_PUBLISHABLE_KEY']
        result = self._validate_service('stripe', required, {
            'STRIPE_SECRET_KEY': r'^sk_(test|live)_',
            'STRIPE_PUBLISHABLE_KEY': r'^pk_(test|live)_'
        })

        # Check if test or live mode
        if 'STRIPE_SECRET_KEY' in os.environ:
            if os.environ['STRIPE_SECRET_KEY'].startswith('sk_test_'):
                self._print_info("Using Stripe TEST mode")
            elif os.environ['STRIPE_SECRET_KEY'].startswith('sk_live_'):
                self._print_warning("Using Stripe LIVE mode - be careful!")

        return result

    def validate_aws(self) -> bool:
        """Validate AWS credentials"""
        required = ['AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY', 'AWS_REGION', 'AWS_S3_BUCKET']
        return self._validate_service('aws', required, {
            'AWS_ACCESS_KEY_ID': r'^AKIA',
            'AWS_REGION': r'^[a-z]{2}-[a-z]+-[0-9]$'
        })

    def _validate_service(self, service: str, required: List[str], patterns: Dict[str, str] = None) -> bool:
        """Generic service validation"""
        if service not in self.credentials:
            self._print_error(f"Credentials for {service} not loaded")
            return False

        creds = self.credentials[service]
        missing = [var for var in required if var not in creds or not creds[var]]

        if missing:
            self._print_error(f"Missing {service} credentials: {', '.join(missing)}")
            return False

        # Validate patterns
        if patterns:
            for key, pattern in patterns.items():
                if key in creds and creds[key]:
                    if not re.match(pattern, creds[key]):
                        self._print_warning(f"{key} format may be incorrect")

        self._print_success(f"{service.capitalize()} credentials validated")
        return True

    def create_template(self, service: str):
        """Create credential template file"""
        templates = {
            'supabase': """# Supabase Credentials
# Get these from: https://app.supabase.com/project/_/settings/api

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...your-anon-key
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...your-service-role-key

# Optional: Project reference for CLI
SUPABASE_PROJECT_REF=your-project-ref
""",
            'stripe': """# Stripe Credentials
# Get these from: https://dashboard.stripe.com/test/apikeys

# Use test keys for development (sk_test_...)
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...

# Webhook signing secret (for webhook verification)
STRIPE_WEBHOOK_SECRET=whsec_...

# Optional: Product IDs
STRIPE_BUSINESS_SUBSCRIPTION_PRODUCT_ID=prod_...
STRIPE_BUSINESS_SUBSCRIPTION_PRICE_ID=price_...
""",
            'aws': """# AWS Credentials
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
""",
            'github': """# GitHub Credentials
# Get these from: https://github.com/settings/tokens

GITHUB_TOKEN=ghp_...
GITHUB_REPO_OWNER=tempandmajor
GITHUB_REPO_NAME=socoto
"""
        }

        if service not in templates:
            self._print_error(f"Unknown service: {service}")
            return

        template_file = self.cred_dir / f"{service}.env.template"
        with open(template_file, 'w') as f:
            f.write(templates[service])

        os.chmod(template_file, stat.S_IRUSR | stat.S_IWUSR)
        self._print_success(f"Created template: {template_file}")
        self._print_info(f"Copy to {service}.env and fill in your credentials")

    def list_credentials(self):
        """List available credential files"""
        self._print_info(f"Credential files in {self.cred_dir}:")

        env_files = list(self.cred_dir.glob("*.env"))
        template_files = list(self.cred_dir.glob("*.env.template"))

        if not env_files and not template_files:
            self._print_warning("No credential files found")
            return

        for file in env_files:
            size = file.stat().st_size
            perms = oct(file.stat().st_mode)[-3:]
            print(f"  {Colors.GREEN}●{Colors.NC} {file.name} ({size} bytes, {perms})")

        for file in template_files:
            print(f"  {Colors.YELLOW}○{Colors.NC} {file.name} (template)")

    def export_for_cli(self, service: str):
        """Export credentials for CLI usage"""
        if not self.load_credentials(service):
            return

        print(f"\n{Colors.CYAN}# Export commands for {service}:{Colors.NC}")
        for key, value in self.credentials[service].items():
            print(f"export {key}='{value}'")


def main():
    """Main CLI interface"""
    import argparse

    parser = argparse.ArgumentParser(
        description='Socoto Secure Credential Manager',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s template supabase          Create Supabase credential template
  %(prog)s load supabase              Load Supabase credentials
  %(prog)s validate all               Validate all credentials
  %(prog)s list                       List credential files
  %(prog)s export supabase            Export credentials for CLI

Security:
  - Credentials stored in: ~/.socoto/credentials/
  - File permissions: 600 (read/write owner only)
  - Never commit credential files to git
        """
    )

    parser.add_argument('command', choices=['load', 'validate', 'template', 'list', 'export'],
                        help='Command to execute')
    parser.add_argument('service', nargs='?', default='all',
                        help='Service name (supabase, stripe, aws, github, all)')

    args = parser.parse_args()

    manager = CredentialManager()

    if args.command == 'template':
        if args.service == 'all':
            for svc in ['supabase', 'stripe', 'aws', 'github']:
                manager.create_template(svc)
        else:
            manager.create_template(args.service)

    elif args.command == 'load':
        if args.service == 'all':
            for svc in ['supabase', 'stripe', 'aws', 'github']:
                manager.load_credentials(svc)
        else:
            manager.load_credentials(args.service)

    elif args.command == 'validate':
        if args.service == 'all':
            manager.load_credentials('supabase') and manager.validate_supabase()
            manager.load_credentials('stripe') and manager.validate_stripe()
            manager.load_credentials('aws') and manager.validate_aws()
        else:
            if manager.load_credentials(args.service):
                if args.service == 'supabase':
                    manager.validate_supabase()
                elif args.service == 'stripe':
                    manager.validate_stripe()
                elif args.service == 'aws':
                    manager.validate_aws()

    elif args.command == 'list':
        manager.list_credentials()

    elif args.command == 'export':
        manager.export_for_cli(args.service)


if __name__ == '__main__':
    main()
