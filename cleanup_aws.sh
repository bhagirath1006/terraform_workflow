#!/bin/bash

# Script to destroy all existing terraform-app resources from AWS
# This cleans up so we can start fresh with proper state management

set -e

PROJECT_NAME="terraform-app"
REGION="ap-south-1"

echo "⚠️  WARNING: This will delete ALL resources with tag Project=terraform-app"
echo "Press Ctrl+C within 5 seconds to cancel..."
sleep 5

echo ""
echo "🗑️  Cleaning up AWS resources..."
echo ""

# Delete EC2 Instances
echo "🔍 Finding EC2 instances..."
INSTANCE_IDS=$(aws ec2 describe-instances --region $REGION --filters "Name=tag:Project,Values=$PROJECT_NAME" "Name=instance-state-name,Values=running,stopped" --query 'Reservations[].Instances[].InstanceId' --output text)

if [ ! -z "$INSTANCE_IDS" ]; then
  echo "❌ Terminating instances: $INSTANCE_IDS"
  aws ec2 terminate-instances --region $REGION --instance-ids $INSTANCE_IDS
  
  echo "⏳ Waiting for instances to terminate..."
  aws ec2 wait instance-terminated --region $REGION --instance-ids $INSTANCE_IDS
  echo "✅ Instances terminated"
fi

# Release Elastic IPs
echo ""
echo "🔍 Finding Elastic IPs..."
ALLOCATION_IDS=$(aws ec2 describe-addresses --region $REGION --filters "Name=tag:Project,Values=$PROJECT_NAME" --query 'Addresses[].AllocationId' --output text)

if [ ! -z "$ALLOCATION_IDS" ]; then
  echo "❌ Releasing Elastic IPs: $ALLOCATION_IDS"
  for AID in $ALLOCATION_IDS; do
    aws ec2 release-address --region $REGION --allocation-id $AID 2>/dev/null || echo "   ℹ️  EIP already released"
  done
  echo "✅ Elastic IPs released"
fi

# Delete VPCs (this will cascade delete subnets, security groups, etc.)
echo ""
echo "🔍 Finding VPCs..."
VPC_IDS=$(aws ec2 describe-vpcs --region $REGION --filters "Name=tag:Project,Values=$PROJECT_NAME" --query 'Vpcs[].VpcId' --output text)

if [ ! -z "$VPC_IDS" ]; then
  for VPC_ID in $VPC_IDS; do
    echo "❌ Deleting VPC and related resources: $VPC_ID"
    
    # Delete VPC Flow Logs
    echo "   Deleting VPC Flow Logs..."
    FLOW_LOG_IDS=$(aws ec2 describe-flow-logs --region $REGION --filter "Name=resource-id,Values=$VPC_ID" --query 'FlowLogs[].FlowLogId' --output text 2>/dev/null || echo "")
    for FLOW_LOG_ID in $FLOW_LOG_IDS; do
      aws ec2 delete-flow-logs --region $REGION --flow-log-ids $FLOW_LOG_ID 2>/dev/null || true
    done
    
    # Delete CloudWatch Log Groups
    echo "   Deleting CloudWatch Log Groups..."
    aws logs delete-log-group --region $REGION --log-group-name "/aws/vpc/flowlogs/$PROJECT_NAME" 2>/dev/null || echo "   ℹ️  Log group already deleted"
    aws logs delete-log-group --region $REGION --log-group-name "/aws/ec2/$PROJECT_NAME" 2>/dev/null || echo "   ℹ️  Log group already deleted"
    
    # Delete Internet Gateways
    echo "   Deleting Internet Gateways..."
    IGW_IDS=$(aws ec2 describe-internet-gateways --region $REGION --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query 'InternetGateways[].InternetGatewayId' --output text)
    for IGW_ID in $IGW_IDS; do
      aws ec2 detach-internet-gateway --region $REGION --internet-gateway-id $IGW_ID --vpc-id $VPC_ID 2>/dev/null || true
      aws ec2 delete-internet-gateway --region $REGION --internet-gateway-id $IGW_ID 2>/dev/null || true
    done
    
    # Delete Subnets
    echo "   Deleting Subnets..."
    SUBNET_IDS=$(aws ec2 describe-subnets --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query 'Subnets[].SubnetId' --output text)
    for SUBNET_ID in $SUBNET_IDS; do
      aws ec2 delete-subnet --region $REGION --subnet-id $SUBNET_ID 2>/dev/null || true
    done
    
    # Delete Security Groups (except default)
    echo "   Deleting Security Groups..."
    SG_IDS=$(aws ec2 describe-security-groups --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query 'SecurityGroups[?GroupName!=`default`].GroupId' --output text)
    for SG_ID in $SG_IDS; do
      aws ec2 delete-security-group --region $REGION --group-id $SG_ID 2>/dev/null || echo "   ℹ️  Security group already deleted"
    done
    
    # Delete VPC
    echo "   Deleting VPC..."
    aws ec2 delete-vpc --region $REGION --vpc-id $VPC_ID 2>/dev/null || echo "   ℹ️  VPC already deleted"
    echo "✅ VPC deleted: $VPC_ID"
  done
fi

# Delete IAM Roles and Policies
echo ""
echo "🔍 Finding IAM Roles..."

for ROLE_NAME in "$PROJECT_NAME-ec2-role" "$PROJECT_NAME-vpc-flow-logs-role"; do
  echo "❌ Deleting IAM Role: $ROLE_NAME"
  
  # Delete inline policies
  POLICY_NAMES=$(aws iam list-role-policies --role-name $ROLE_NAME --query 'PolicyNames[].PolicyName' --output text 2>/dev/null || echo "")
  for POLICY_NAME in $POLICY_NAMES; do
    aws iam delete-role-policy --role-name $ROLE_NAME --policy-name $POLICY_NAME 2>/dev/null || true
  done
  
  # Delete instance profiles
  aws iam delete-instance-profile --instance-profile-name "$PROJECT_NAME-ec2-profile" 2>/dev/null || true
  
  # Delete role
  aws iam delete-role --role-name $ROLE_NAME 2>/dev/null || echo "   ℹ️  Role already deleted"
done

# Delete KMS Keys (schedule for deletion)
echo ""
echo "🔍 Finding KMS Keys..."
KMS_KEYS=$(aws kms list-keys --region $REGION --query 'Keys[].KeyId' --output text)
for KEY_ID in $KMS_KEYS; do
  KEY_DESC=$(aws kms describe-key --region $REGION --key-id $KEY_ID --query 'KeyMetadata.Description' --output text 2>/dev/null || echo "")
  if [[ "$KEY_DESC" == *"$PROJECT_NAME"* ]]; then
    echo "❌ Scheduling KMS Key for deletion: $KEY_ID"
    aws kms schedule-key-deletion --region $REGION --key-id $KEY_ID --pending-window-in-days 7 2>/dev/null || echo "   ℹ️  Key already scheduled"
  fi
done

echo ""
echo "✅ Cleanup complete!"
echo "ℹ️  Next steps:"
echo "   1. Run: terraform apply"
echo "   2. New resources will be created fresh with proper state"
