#!/bin/bash

# Import existing AWS resources into Terraform state

set -e

PROJECT_NAME="terraform-app"
REGION="ap-south-1"

echo "🔄 Importing existing resources into Terraform state..."
echo ""

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

# Import VPC
echo "📍 Importing VPC..."
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=${PROJECT_NAME}-vpc" --query 'Vpcs[0].VpcId' --region "$REGION" --output text 2>/dev/null || echo "")
if [ ! -z "$VPC_ID" ] && [ "$VPC_ID" != "None" ]; then
  cd terraform
  terraform import -var-file="environments/dev.tfvars" "module.vpc.aws_vpc.main" "$VPC_ID" 2>/dev/null || echo "   ℹ️  VPC already in state or doesn't exist"
  cd ..
else
  echo "   ℹ️  VPC not found"
fi

# Import EC2 IAM Role
echo "📍 Importing EC2 IAM Role..."
cd terraform
terraform import -var-file="environments/dev.tfvars" "module.ec2.aws_iam_role.ec2_role" "${PROJECT_NAME}-ec2-role" 2>/dev/null || echo "   ℹ️  Role already in state"
cd ..

# Import VPC Flow Logs IAM Role
echo "📍 Importing VPC Flow Logs IAM Role..."
cd terraform
terraform import -var-file="environments/dev.tfvars" "module.vpc.aws_iam_role.vpc_flow_logs" "${PROJECT_NAME}-vpc-flow-logs-role" 2>/dev/null || echo "   ℹ️  Role already in state"
cd ..

# Import EC2 CloudWatch Log Group
echo "📍 Importing EC2 CloudWatch Log Group..."
cd terraform
terraform import -var-file="environments/dev.tfvars" "module.ec2.aws_cloudwatch_log_group.app" "/aws/ec2/${PROJECT_NAME}" 2>/dev/null || echo "   ℹ️  Log group already in state"
cd ..

# Import VPC Flow Logs CloudWatch Log Group
echo "📍 Importing VPC Flow Logs CloudWatch Log Group..."
cd terraform
terraform import -var-file="environments/dev.tfvars" "module.vpc.aws_cloudwatch_log_group.vpc_flow_logs" "/aws/vpc/flowlogs/${PROJECT_NAME}" 2>/dev/null || echo "   ℹ️  Log group already in state"
cd ..

# Import KMS Aliases
echo "📍 Importing KMS Aliases..."
cd terraform
terraform import -var-file="environments/dev.tfvars" "module.ec2.aws_kms_alias.logs" "alias/${PROJECT_NAME}-logs" 2>/dev/null || echo "   ℹ️  KMS alias already in state"
terraform import -var-file="environments/dev.tfvars" "module.vpc.aws_kms_alias.vpc_logs" "alias/${PROJECT_NAME}-vpc-logs" 2>/dev/null || echo "   ℹ️  KMS alias already in state"
cd ..

echo ""
echo "✅ Import complete!"
echo ""
