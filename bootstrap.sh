#!/bin/bash

# Bootstrap script to create S3 bucket and DynamoDB table for Terraform state

set -e

REGION="ap-south-1"
BUCKET_NAME="terraform-app-state-bucket"
TABLE_NAME="terraform-app-locks"
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

echo "🔧 Bootstrapping Terraform state backend..."
echo "Region: $REGION"
echo "Bucket: $BUCKET_NAME"
echo "DynamoDB Table: $TABLE_NAME"
echo ""

# Create S3 bucket for state
echo "📦 Creating S3 bucket for state..."
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION" \
  2>/dev/null || echo "   ℹ️  Bucket already exists"

# Enable versioning on bucket
echo "🔄 Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled \
  2>/dev/null || true

# Enable encryption on bucket
echo "🔐 Enabling encryption on S3 bucket..."
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }' \
  2>/dev/null || true

# Block public access
echo "🔒 Blocking public access to S3 bucket..."
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
  2>/dev/null || true

# Create DynamoDB table for state locking
echo "🔐 Creating DynamoDB table for state locking..."
aws dynamodb create-table \
  --table-name "$TABLE_NAME" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION" \
  2>/dev/null || echo "   ℹ️  Table already exists"

echo ""
echo "✅ Bootstrap complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Ensure AWS credentials are configured (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)"
echo "   2. Run: terraform init"
echo "   3. Run: terraform apply"
echo ""
