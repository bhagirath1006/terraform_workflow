#!/bin/bash

# Script to import existing AWS resources into Terraform state

set -e

PROJECT_NAME="terraform-app"
REGION="ap-south-1"

echo "🔍 Importing existing resources into Terraform state..."
echo ""

cd terraform

# Function to import resource safely
import_resource() {
  local resource_type=$1
  local resource_name=$2
  local resource_id=$3
  
  echo "📌 Importing $resource_type: $resource_name ($resource_id)"
  
  if terraform import "$resource_type" "$resource_id" 2>/dev/null; then
    echo "   ✅ Imported successfully"
  else
    echo "   ℹ️  Resource already in state or doesn't exist"
  fi
}

# Get VPC ID
VPC_ID=$(aws ec2 describe-vpcs --region $REGION --filters "Name=tag:Name,Values=$PROJECT_NAME-vpc" --query 'Vpcs[0].VpcId' --output text 2>/dev/null || echo "")

if [ "$VPC_ID" != "" ] && [ "$VPC_ID" != "None" ]; then
  echo "Found VPC: $VPC_ID"
  import_resource "module.vpc.aws_vpc.main" "VPC" "$VPC_ID"
  
  # Get subnets
  SUBNET_IDS=$(aws ec2 describe-subnets --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[].SubnetId' --output text)
  COUNT=0
  for SUBNET_ID in $SUBNET_IDS; do
    if [[ $SUBNET_ID == subnet-* ]]; then
      import_resource "module.vpc.aws_subnet.public[$COUNT]" "Subnet" "$SUBNET_ID"
      COUNT=$((COUNT + 1))
    fi
  done
else
  echo "⚠️  No VPC found with tag Name=$PROJECT_NAME-vpc"
fi

# Get EC2 Instance
INSTANCE_ID=$(aws ec2 describe-instances --region $REGION --filters "Name=tag:Name,Values=$PROJECT_NAME-instance" "Name=instance-state-name,Values=running" --query 'Reservations[0].Instances[0].InstanceId' --output text 2>/dev/null || echo "")

if [ "$INSTANCE_ID" != "" ] && [ "$INSTANCE_ID" != "None" ]; then
  echo "Found Instance: $INSTANCE_ID"
  import_resource "module.ec2.aws_instance.app" "Instance" "$INSTANCE_ID"
else
  echo "⚠️  No running EC2 instance found"
fi

# Get Elastic IPs
EIP_IDS=$(aws ec2 describe-addresses --region $REGION --filters "Name=tag:Name,Values=$PROJECT_NAME-eip" --query 'Addresses[].AllocationId' --output text 2>/dev/null || echo "")

for EIP_ID in $EIP_IDS; do
  if [[ $EIP_ID == eipalloc-* ]]; then
    echo "Found EIP: $EIP_ID"
    import_resource "module.ec2.aws_eip.app" "EIP" "$EIP_ID"
  fi
done

# Get IAM Roles
import_resource "module.ec2.aws_iam_role.ec2_role" "EC2 Role" "$PROJECT_NAME-ec2-role" || true
import_resource "module.vpc.aws_iam_role.vpc_flow_logs" "VPC Flow Logs Role" "$PROJECT_NAME-vpc-flow-logs-role" || true

# Get KMS Keys (by key ID)
KMS_KEY_IDS=$(aws kms list-keys --region $REGION --query 'Keys[].KeyId' --output text)
for KEY_ID in $KMS_KEY_IDS; do
  KEY_DESC=$(aws kms describe-key --region $REGION --key-id "$KEY_ID" --query 'KeyMetadata.Description' --output text 2>/dev/null || echo "")
  if [[ "$KEY_DESC" == *"logs"* ]]; then
    echo "Found KMS Key: $KEY_ID"
    import_resource "module.ec2.aws_kms_key.logs" "KMS Key" "$KEY_ID" || true
  fi
done

# Get CloudWatch Log Groups
import_resource "module.ec2.aws_cloudwatch_log_group.app" "Log Group" "/aws/ec2/$PROJECT_NAME" || true
import_resource "module.vpc.aws_cloudwatch_log_group.vpc_flow_logs" "VPC Flow Logs Log Group" "/aws/vpc/flowlogs/$PROJECT_NAME" || true

echo ""
echo "✅ Import complete!"
echo "⚠️  Note: Some resources may already be in state or not exist yet"
echo "Run: terraform plan to verify state"
