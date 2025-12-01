#!/bin/bash

# Import existing AWS resources into Terraform state
# Run this script after terraform init to import previously created resources

set -e

echo "🔄 Importing existing AWS resources into Terraform state..."
echo ""

# Get AWS account ID and region
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
REGION="ap-south-1"
PROJECT="terraform-app"

echo "Account ID: $ACCOUNT_ID"
echo "Region: $REGION"
echo "Project: $PROJECT"
echo ""

# Function to import resource with error handling
import_resource() {
  local resource_type=$1
  local resource_id=$2
  local resource_name=$3
  
  echo "📥 Importing $resource_type: $resource_name..."
  terraform import "$resource_type.$resource_name" "$resource_id" 2>/dev/null || echo "   ⚠️  Already imported or not found"
}

# Import VPC resources
echo "🏗️  Importing VPC resources..."
import_resource "module.vpc.aws_vpc.main" "vpc-*" "vpc"
import_resource "module.vpc.aws_internet_gateway.main" "igw-*" "igw"

# Import EC2 resources  
echo ""
echo "💻 Importing EC2 resources..."
import_resource "module.ec2.aws_iam_role.ec2_role" "${PROJECT}-ec2-role" "ec2_role"
import_resource "module.ec2.aws_iam_instance_profile.ec2_profile" "${PROJECT}-ec2-profile" "ec2_profile"

# Import IAM roles for VPC Flow Logs
echo ""
echo "📋 Importing IAM resources..."
import_resource "module.vpc.aws_iam_role.vpc_flow_logs" "${PROJECT}-vpc-flow-logs-role" "vpc_flow_logs"

# Import KMS resources
echo ""
echo "🔐 Importing KMS resources..."
import_resource "module.ec2.aws_kms_key.logs" "alias/${PROJECT}-logs" "ec2_kms_key"
import_resource "module.vpc.aws_kms_key.vpc_logs" "alias/${PROJECT}-vpc-logs" "vpc_kms_key"

# Import CloudWatch Log Groups
echo ""
echo "📊 Importing CloudWatch Log Groups..."
import_resource "module.ec2.aws_cloudwatch_log_group.app" "/aws/ec2/${PROJECT}" "ec2_log_group"
import_resource "module.vpc.aws_cloudwatch_log_group.vpc_flow_logs" "/aws/vpc/flowlogs/${PROJECT}" "vpc_log_group"

echo ""
echo "✅ Import complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Review terraform state: terraform state list"
echo "   2. Run terraform plan to verify"
echo "   3. Run terraform apply if changes look correct"
echo ""
