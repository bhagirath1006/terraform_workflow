# Backend Configuration for Terraform State (S3 + DynamoDB)
# This file demonstrates how to configure remote state management
# 
# To use this configuration:
# 1. Create S3 bucket and DynamoDB table (uncomment and run setup_backend.sh)
# 2. Uncomment the terraform block below
# 3. Run: terraform init

# Uncomment below to enable S3 backend for state management
# terraform {
#   backend "s3" {
#     bucket         = "myapp-terraform-state"
#     key            = "terraform_fresh_infra/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }

# To set up the S3 backend, create these resources first:
# 
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "myapp-terraform-state-${data.aws_caller_identity.current.account_id}"
# 
#   tags = {
#     Name = "Terraform State"
#   }
# }
# 
# resource "aws_s3_bucket_versioning" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
# 
# resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
#   bucket = aws_s3_bucket.terraform_state.id
# 
#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }
# 
# resource "aws_dynamodb_table" "terraform_locks" {
#   name           = "terraform-locks"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "LockID"
# 
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }
