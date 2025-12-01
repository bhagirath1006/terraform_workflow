#!/bin/bash

# Cleanup script to remove old AWS resources before fresh Terraform deployment
# This script safely removes resources that are preventing Terraform from applying

set -e

echo "🧹 Cleaning up existing AWS resources..."
echo ""
echo "⚠️  WARNING: This will DELETE existing resources!"
echo ""

REGION="ap-south-1"
PROJECT="terraform-app"

read -p "Continue with cleanup? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
  echo "Cleanup cancelled"
  exit 0
fi

echo ""
echo "Starting cleanup..."

# Delete EC2 instances
echo "🔴 Terminating EC2 instances..."
INSTANCE_IDS=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=${PROJECT}-instance" "Name=instance-state-name,Values=running,stopped" \
  --query 'Reservations[].Instances[].InstanceId' \
  --region "$REGION" \
  --output text)

if [ -n "$INSTANCE_IDS" ]; then
  for INSTANCE_ID in $INSTANCE_IDS; do
    echo "  Terminating instance: $INSTANCE_ID"
    aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" --region "$REGION" > /dev/null
  done
  echo "  Waiting for instances to terminate..."
  aws ec2 wait instance-terminated --instance-ids $INSTANCE_IDS --region "$REGION" 2>/dev/null || true
else
  echo "  No instances found"
fi

# Release Elastic IPs
echo "🌐 Releasing Elastic IPs..."
ALLOCATION_IDS=$(aws ec2 describe-addresses \
  --filters "Name=tag:Name,Values=${PROJECT}-eip" \
  --query 'Addresses[].AllocationId' \
  --region "$REGION" \
  --output text)

if [ -n "$ALLOCATION_IDS" ]; then
  for ALLOCATION_ID in $ALLOCATION_IDS; do
    echo "  Releasing allocation: $ALLOCATION_ID"
    aws ec2 release-address --allocation-id "$ALLOCATION_ID" --region "$REGION" 2>/dev/null || true
  done
else
  echo "  No Elastic IPs found"
fi

# Delete CloudWatch Log Groups
echo "📊 Deleting CloudWatch Log Groups..."
LOG_GROUPS=("/aws/ec2/${PROJECT}" "/aws/vpc/flowlogs/${PROJECT}")

for LOG_GROUP in "${LOG_GROUPS[@]}"; do
  if aws logs describe-log-groups --log-group-name-prefix "$LOG_GROUP" --region "$REGION" | grep -q "logGroupName"; then
    echo "  Deleting log group: $LOG_GROUP"
    aws logs delete-log-group --log-group-name "$LOG_GROUP" --region "$REGION" 2>/dev/null || true
  fi
done

# Delete KMS Aliases
echo "🔐 Deleting KMS Aliases..."
ALIASES=("${PROJECT}-logs" "${PROJECT}-vpc-logs")

for ALIAS in "${ALIASES[@]}"; do
  echo "  Deleting alias: alias/$ALIAS"
  aws kms delete-alias --alias-name "alias/$ALIAS" --region "$REGION" 2>/dev/null || true
done

# Delete KMS Keys (schedule for deletion)
echo "🔑 Scheduling KMS Keys for deletion..."
KMS_KEYS=$(aws kms list-keys --region "$REGION" --query 'Keys[].KeyId' --output text)

for KEY_ID in $KMS_KEYS; do
  KEY_ALIAS=$(aws kms list-aliases --key-id "$KEY_ID" --region "$REGION" --query 'Aliases[0].AliasName' --output text 2>/dev/null || echo "")
  if [[ "$KEY_ALIAS" == *"$PROJECT"* ]]; then
    echo "  Scheduling key deletion: $KEY_ID"
    aws kms schedule-key-deletion --key-id "$KEY_ID" --pending-window-in-days 7 --region "$REGION" 2>/dev/null || true
  fi
done

# Delete IAM Roles (if not in use)
echo "👤 Cleaning up IAM Roles..."
ROLES=("${PROJECT}-ec2-role" "${PROJECT}-vpc-flow-logs-role")

for ROLE in "${ROLES[@]}"; do
  echo "  Cleaning role: $ROLE"
  
  # List and delete inline policies
  POLICIES=$(aws iam list-role-policies --role-name "$ROLE" --query 'PolicyNames[]' --output text 2>/dev/null || echo "")
  for POLICY in $POLICIES; do
    echo "    Deleting inline policy: $POLICY"
    aws iam delete-role-policy --role-name "$ROLE" --policy-name "$POLICY" 2>/dev/null || true
  done
  
  # Delete instance profile
  INSTANCE_PROFILES=$(aws iam list-instance-profiles-for-role --role-name "$ROLE" --query 'InstanceProfiles[].InstanceProfileName' --output text 2>/dev/null || echo "")
  for INSTANCE_PROFILE in $INSTANCE_PROFILES; do
    echo "    Removing role from instance profile: $INSTANCE_PROFILE"
    aws iam remove-role-from-instance-profile --instance-profile-name "$INSTANCE_PROFILE" --role-name "$ROLE" 2>/dev/null || true
    echo "    Deleting instance profile: $INSTANCE_PROFILE"
    aws iam delete-instance-profile --instance-profile-name "$INSTANCE_PROFILE" 2>/dev/null || true
  done
  
  # Delete role
  echo "    Deleting role: $ROLE"
  aws iam delete-role --role-name "$ROLE" 2>/dev/null || true
done

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Run: terraform init"
echo "   2. Run: terraform plan"
echo "   3. Run: terraform apply"
echo ""
