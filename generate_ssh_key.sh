#!/bin/bash

# Generate SSH key for EC2 access
# This script creates a local SSH key and stores it for use with Terraform

set -e

KEY_NAME="terraform-app-key"
KEY_DIR="$(pwd)/ssh-keys"

echo "🔑 Generating SSH key for EC2 access..."
echo ""

# Create ssh-keys directory if it doesn't exist
if [ ! -d "$KEY_DIR" ]; then
  mkdir -p "$KEY_DIR"
  echo "📁 Created directory: $KEY_DIR"
fi

# Generate SSH key
if [ -f "$KEY_DIR/$KEY_NAME" ]; then
  echo "⚠️  Key already exists at: $KEY_DIR/$KEY_NAME"
  read -p "Do you want to regenerate it? (yes/no): " -r
  if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Using existing key"
    cat "$KEY_DIR/$KEY_NAME.pub"
    exit 0
  fi
  rm -f "$KEY_DIR/$KEY_NAME" "$KEY_DIR/$KEY_NAME.pub"
fi

# Generate key without passphrase for automation (you can add -N "passphrase" for security)
ssh-keygen -t rsa -b 4096 -f "$KEY_DIR/$KEY_NAME" -N "" -C "terraform-app" > /dev/null 2>&1

echo "✅ SSH key generated successfully!"
echo ""
echo "📍 Key location:"
echo "   Private key: $KEY_DIR/$KEY_NAME"
echo "   Public key:  $KEY_DIR/$KEY_NAME.pub"
echo ""
echo "🔐 Key permissions (secured):"
chmod 600 "$KEY_DIR/$KEY_NAME"
chmod 644 "$KEY_DIR/$KEY_NAME.pub"
ls -lh "$KEY_DIR/$KEY_NAME"*
echo ""
echo "📋 Public key content (add to terraform.tfvars):"
echo ""
cat "$KEY_DIR/$KEY_NAME.pub"
echo ""
echo "✅ Next steps:"
echo "   1. Add this to your terraform.tfvars:"
echo ""
echo "   ssh_public_key = \"$(cat "$KEY_DIR/$KEY_NAME.pub")\""
echo ""
echo "   2. Run: terraform apply"
echo "   3. SSH to your instance:"
echo "      ssh -i $KEY_DIR/$KEY_NAME ubuntu@<elastic-ip>"
echo ""

