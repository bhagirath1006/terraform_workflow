#!/bin/bash

# Terraform Deployment Script
# This script initializes and deploys the infrastructure

set -e

echo "=========================================="
echo "Terraform Infrastructure Deployment"
echo "=========================================="
echo ""

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "ERROR: Terraform is not installed or not in PATH"
    echo "Please install Terraform from: https://www.terraform.io/downloads"
    exit 1
fi

echo "✓ Terraform is installed: $(terraform version -json | jq -r '.terraform_version')"
echo ""

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$(dirname "$SCRIPT_DIR")"

echo "Working directory: $TF_DIR"
echo ""

cd "$TF_DIR"

# Step 1: Terraform Init
echo "Step 1: Initializing Terraform..."
echo "---------------------------------------"
terraform init
echo "✓ Terraform initialized successfully"
echo ""

# Step 2: Validate configuration
echo "Step 2: Validating Terraform configuration..."
echo "---------------------------------------"
terraform validate
echo "✓ Configuration is valid"
echo ""

# Step 3: Format check
echo "Step 3: Checking Terraform formatting..."
echo "---------------------------------------"
terraform fmt -check -recursive || terraform fmt -recursive
echo "✓ Formatting check complete"
echo ""

# Step 4: Plan
echo "Step 4: Creating Terraform plan..."
echo "---------------------------------------"
terraform plan -out=tfplan
echo "✓ Plan created successfully"
echo ""

# Step 5: Ask for confirmation
echo "Step 5: Confirmation"
echo "---------------------------------------"
echo ""
echo "Review the plan above to ensure it matches your expectations."
echo ""
read -p "Do you want to apply these changes? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
    echo ""
    echo "Deployment cancelled. Plan saved as 'tfplan'."
    exit 0
fi

echo ""

# Step 6: Apply
echo "Step 6: Applying Terraform configuration..."
echo "---------------------------------------"
terraform apply tfplan
echo "✓ Infrastructure deployed successfully"
echo ""

# Step 7: Output
echo "Step 7: Deployment Summary"
echo "---------------------------------------"
terraform output deployment_summary
echo ""

echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Useful commands:"
echo "  terraform output                     # View all outputs"
echo "  terraform show                       # Show current state"
echo "  terraform plan                       # Create a new plan"
echo "  terraform destroy                    # Destroy all resources"
echo "  ./scripts/cleanup.sh                 # Full cleanup with state removal"
echo ""
