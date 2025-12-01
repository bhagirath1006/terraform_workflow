#!/bin/bash

# Terraform Cleanup Script
# This script destroys all resources created by Terraform and clears the state

set -e

echo "=========================================="
echo "Terraform Infrastructure Cleanup"
echo "=========================================="
echo ""

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "ERROR: Terraform is not installed or not in PATH"
    exit 1
fi

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$(dirname "$SCRIPT_DIR")"

echo "Working directory: $TF_DIR"
echo ""

# Check if terraform.tfstate exists
if [ ! -f "$TF_DIR/terraform.tfstate" ]; then
    echo "WARNING: No terraform.tfstate found in $TF_DIR"
    echo "This means no resources have been created yet, or state has already been cleared."
    exit 0
fi

# Confirm before destroying
echo "WARNING: This will destroy ALL infrastructure resources created by Terraform!"
echo "This includes:"
echo "  - EC2 instances"
echo "  - Elastic IPs"
echo "  - VPC and subnets"
echo "  - Security groups"
echo "  - And all other managed resources"
echo ""
read -p "Are you sure you want to proceed? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

cd "$TF_DIR"

echo ""
echo "Running terraform destroy..."
terraform destroy -auto-approve

echo ""
echo "=========================================="
echo "Removing Terraform state files..."
echo "=========================================="

# Remove state files
if [ -f "terraform.tfstate" ]; then
    rm -f terraform.tfstate
    echo "✓ Removed terraform.tfstate"
fi

if [ -f "terraform.tfstate.backup" ]; then
    rm -f terraform.tfstate.backup
    echo "✓ Removed terraform.tfstate.backup"
fi

# Remove .terraform directory and lock file
if [ -d ".terraform" ]; then
    rm -rf .terraform
    echo "✓ Removed .terraform directory"
fi

if [ -f ".terraform.lock.hcl" ]; then
    rm -f .terraform.lock.hcl
    echo "✓ Removed .terraform.lock.hcl"
fi

echo ""
echo "=========================================="
echo "Cleanup Complete!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  ✓ All infrastructure resources destroyed"
echo "  ✓ Terraform state files removed"
echo "  ✓ Terraform lock files removed"
echo ""
echo "The workspace is now clean and ready for re-deployment."
echo ""
