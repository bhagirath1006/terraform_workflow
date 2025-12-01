#!/bin/bash

# Terraform State Management Utility Script (Bash)

echo "=========================================="
echo "Terraform State Management Utility"
echo "=========================================="
echo ""
echo "Choose an option:"
echo "1. Show current state"
echo "2. List state resources"
echo "3. Show specific resource from state"
echo "4. Clear local state files (keep AWS resources)"
echo "5. Remove specific resource from state (DANGEROUS)"
echo "6. Exit"
echo ""

read -p "Enter your choice (1-6): " choice

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$(dirname "$SCRIPT_DIR")"

cd "$TF_DIR"

case $choice in
    1)
        echo ""
        echo "Current Terraform State:"
        echo "---------------------------------------"
        terraform show
        ;;
    
    2)
        echo ""
        echo "State Resources:"
        echo "---------------------------------------"
        terraform state list
        ;;
    
    3)
        echo ""
        read -p "Enter resource name (e.g., module.vpc.aws_vpc.main): " resource
        terraform state show "$resource"
        ;;
    
    4)
        echo ""
        echo "WARNING: This will remove local state files but keep AWS resources"
        read -p "Continue? (type 'yes' to confirm): " confirm
        
        if [ "$confirm" = "yes" ]; then
            if [ -f "terraform.tfstate" ]; then
                rm -f terraform.tfstate
                echo "✓ Removed terraform.tfstate"
            fi
            if [ -f "terraform.tfstate.backup" ]; then
                rm -f terraform.tfstate.backup
                echo "✓ Removed terraform.tfstate.backup"
            fi
            echo ""
            echo "State files cleared. AWS resources remain untouched."
        fi
        ;;
    
    5)
        echo ""
        echo "WARNING: Removing a resource from state will cause Terraform to orphan it!"
        echo "The AWS resource will continue to exist but won't be managed by Terraform."
        echo ""
        read -p "Enter resource address to remove: " resource
        read -p "Type 'yes' to confirm removal of $resource: " confirm
        
        if [ "$confirm" = "yes" ]; then
            terraform state rm "$resource"
            echo "✓ Resource removed from state"
        else
            echo "Cancelled"
        fi
        ;;
    
    6)
        echo "Exiting..."
        ;;
    
    *)
        echo "Invalid choice. Exiting."
        ;;
esac

echo ""
