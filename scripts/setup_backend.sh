#!/bin/bash

# Backend Setup Script for Terraform State Management
# This script creates S3 bucket and DynamoDB table for state locking

set -e

AWS_REGION="us-east-1"
PROJECT_NAME="myapp"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
S3_BUCKET="${PROJECT_NAME}-terraform-state-${ACCOUNT_ID}"
DYNAMODB_TABLE="terraform-locks"

echo "Setting up Terraform backend..."
echo "AWS Region: $AWS_REGION"
echo "S3 Bucket: $S3_BUCKET"
echo "DynamoDB Table: $DYNAMODB_TABLE"

# Create S3 bucket
echo "Creating S3 bucket..."
aws s3api create-bucket \
  --bucket "$S3_BUCKET" \
  --region "$AWS_REGION" \
  $(if [ "$AWS_REGION" != "us-east-1" ]; then echo "--create-bucket-configuration LocationConstraint=$AWS_REGION"; fi) \
  2>/dev/null || echo "Bucket already exists or error occurred"

# Enable versioning
echo "Enabling S3 bucket versioning..."
aws s3api put-bucket-versioning \
  --bucket "$S3_BUCKET" \
  --versioning-configuration Status=Enabled

# Enable encryption
echo "Enabling S3 bucket encryption..."
aws s3api put-bucket-encryption \
  --bucket "$S3_BUCKET" \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

# Block public access
echo "Blocking public access to S3 bucket..."
aws s3api put-public-access-block \
  --bucket "$S3_BUCKET" \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Create DynamoDB table
echo "Creating DynamoDB table for state locking..."
aws dynamodb create-table \
  --table-name "$DYNAMODB_TABLE" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$AWS_REGION" \
  2>/dev/null || echo "Table already exists or error occurred"

echo "✅ Backend setup complete!"
echo ""
echo "Next steps:"
echo "1. Uncomment the terraform block in backend.tf"
echo "2. Update the bucket name: $S3_BUCKET"
echo "3. Run: terraform init"
echo ""
