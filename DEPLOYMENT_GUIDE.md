# Terraform Deployment Guide

## Prerequisites

Before running `terraform apply`, ensure you have completed the following:

### 1. AWS Account Setup

- ✅ AWS Account created
- ✅ IAM User with AdministratorAccess (for initial setup)
- ✅ AWS CLI installed and configured
- ✅ AWS Credentials configured locally or via environment variables

**Verify AWS Configuration:**
```bash
aws sts get-caller-identity
```

### 2. HashiCorp Vault Setup (REQUIRED)

**This is critical** - Your infrastructure requires Vault for secrets management.

**Option A: Local Vault (Development)**

```bash
# Using Docker
docker run -d -p 8200:8200 \
  --name vault \
  -e VAULT_DEV_ROOT_TOKEN_ID=my-root-token \
  vault:latest

# Or using binary
vault server -dev -dev-root-token-id=my-root-token
```

**Option B: Production Vault**
- Use Vault Cloud (managed service)
- Or self-host with high availability setup

### 3. Initialize Vault

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='my-root-token'

# Enable KV v2 secrets engine
vault secrets enable -version=2 kv

# Create app secrets
vault kv put secret/dev/app \
  docker_username="your-docker-user" \
  docker_password="your-docker-password" \
  db_username="devadmin" \
  db_password="dev-secure-password" \
  api_key="dev-api-key"

# Create database secrets
vault kv put secret/dev/database \
  username="devadmin" \
  password="dev-db-password" \
  engine="postgres" \
  port=5432 \
  host="localhost"
```

### 4. Update Environment Configuration

Edit `terraform/environments/dev.tfvars`:

```hcl
# Update with your actual values
docker_registry_server = "docker.io"
docker_username        = "your-docker-username"
docker_password        = "your-docker-password"
docker_image_uri       = "your-docker-image:latest"

# Vault configuration (REQUIRED)
vault_addr            = "http://localhost:8200"    # or your Vault address
vault_token           = "my-root-token"             # or your auth token
vault_skip_tls_verify = true                        # Set to false in production

# Database
db_host     = "localhost"
db_username = "devadmin"
db_password = "dev-secure-password"
api_key     = "dev-api-key"
```

### 5. Docker Image Preparation

If deploying a Docker container, ensure:
- Image is built and available in registry
- Image URI is correct in tfvars
- Docker credentials are valid

**Example for public image (no auth needed):**
```hcl
docker_username = ""
docker_password = ""
docker_image_uri = "nginx:latest"
```

### 6. Network Configuration

The infrastructure creates:
- VPC with CIDR: 10.0.0.0/16
- Public Subnets: 10.0.1.0/24, 10.0.2.0/24
- Private Subnets: 10.0.11.0/24, 10.0.12.0/24
- Security Groups with inbound rules for HTTP/HTTPS/SSH

**Ensure no IP conflicts** with your existing infrastructure.

---

## Deployment Steps

### Step 1: Initialize Terraform

```bash
cd terraform
terraform init
```

### Step 2: Validate Configuration

```bash
terraform validate
```

### Step 3: Review Plan

```bash
terraform plan -var-file="environments/dev.tfvars" -out=tfplan
```

This shows all resources that will be created:
- VPC and networking
- EC2 instance with EIP
- IAM roles and policies
- CloudWatch logs and monitoring
- KMS encryption keys
- Vault secrets and AppRole

### Step 4: Apply Configuration

```bash
terraform apply tfplan
```

Or for auto-approval (not recommended for production):

```bash
terraform apply -var-file="environments/dev.tfvars" -auto-approve
```

**This will:**
1. Create VPC with subnets and security groups
2. Create EC2 instance with:
   - EBS encryption enabled
   - IMDSv2 enforcement
   - Detailed monitoring
   - CloudWatch logs with KMS encryption
3. Allocate and associate Elastic IP
4. Configure IAM roles with least-privilege access
5. Create Vault secrets and AppRole for EC2 access

### Step 5: Verify Deployment

```bash
# Get outputs
terraform output

# SSH into instance (via Bastion or directly if allowed)
ssh -i /path/to/key.pem ubuntu@<elastic-ip>

# Check logs
aws logs tail /aws/ec2/terraform-app --follow

# Verify Vault secrets
vault kv get secret/dev/app
```

---

## Common Issues and Solutions

### Issue 1: Vault Connection Error

**Error:**
```
Error: Unable to authenticate to Vault: invalid token
```

**Solution:**
- Ensure Vault is running: `vault status`
- Verify token: `vault token lookup`
- Check vault_addr in tfvars
- Update tfvars with correct credentials

### Issue 2: AWS Credentials Not Found

**Error:**
```
Error: Incomplete credentials detected
```

**Solution:**
```bash
# Configure AWS credentials
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
export AWS_REGION="us-east-1"
```

### Issue 3: VPC CIDR Conflict

**Error:**
```
Error: creating VPC: Conflict: CIDR already in use
```

**Solution:**
Update `vpc_cidr` in tfvars to unused range:
```hcl
vpc_cidr = "10.1.0.0/16"  # Changed from 10.0.0.0/16
```

### Issue 4: EC2 Instance Launch Failed

**Error:**
```
Error: creating instance: InsufficientInstanceCapacity
```

**Solution:**
- Try different availability zone
- Change instance type: `t3.nano`, `t3.small`
- Wait and retry

### Issue 5: Docker Pull Failed

**Error:**
```
Failed to pull docker image
```

**Solution:**
- Verify docker credentials in Vault
- Check image URI is correct
- Ensure image exists in registry
- Check network connectivity

---

## Post-Deployment Configuration

### 1. Configure SSH Access

```bash
# Get EC2 instance details
terraform output instance_id
terraform output instance_public_ip

# Add SSH key to security group (if needed)
# Or use EC2 Instance Connect
aws ec2-instance-connect open-tunnel --instance-id <instance-id> --os-user ec2-user
```

### 2. Monitor Instance

```bash
# View CloudWatch logs
aws logs tail /aws/ec2/terraform-app --follow

# Check CloudWatch alarms
aws cloudwatch describe-alarms
```

### 3. Access Application

```bash
# Get public IP
terraform output instance_public_ip

# Access via HTTP/HTTPS (depends on container)
curl http://<public-ip>
```

### 4. Configure Domain (Optional)

```bash
# Update Route53 or DNS
aws route53 change-resource-record-sets \
  --hosted-zone-id <zone-id> \
  --change-batch file://change-batch.json
```

---

## Cleanup

### To Destroy All Resources

```bash
terraform destroy -var-file="environments/dev.tfvars" -auto-approve
```

**This will delete:**
- EC2 instance and volumes
- VPC, subnets, and security groups
- IAM roles and policies
- CloudWatch logs and alarms
- KMS keys (after deletion window)
- Vault secrets

---

## Environment-Specific Deployment

### Deploy to Staging

```bash
terraform apply -var-file="environments/staging.tfvars"
```

### Deploy to Production

```bash
terraform apply -var-file="environments/prod.tfvars"
```

**For production, also:**
1. Enable remote state backend (S3 + DynamoDB)
2. Use Vault Enterprise or Cloud
3. Enable TLS for Vault
4. Use restricted AWS IAM user
5. Enable audit logging
6. Configure auto-scaling and load balancing

---

## Advanced: Remote State Backend

### Configure S3 Backend

```hcl
# terraform/backend.tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### Create Backend Resources

```bash
# Create S3 bucket and DynamoDB table
aws s3api create-bucket --bucket my-terraform-state --region us-east-1
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```

### Migrate State

```bash
terraform init  # Will prompt to migrate state
```

---

## Support and Documentation

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Vault Provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)
- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [VAULT_SETUP_GUIDE.md](./VAULT_SETUP_GUIDE.md) - Detailed Vault setup

---

## Quick Reference

```bash
# Initialize
terraform init

# Validate
terraform validate

# Plan
terraform plan -var-file="environments/dev.tfvars"

# Apply
terraform apply -var-file="environments/dev.tfvars"

# Destroy
terraform destroy -var-file="environments/dev.tfvars"

# View outputs
terraform output

# View specific output
terraform output instance_public_ip

# Refresh state
terraform refresh

# Import existing resource
terraform import aws_instance.app i-1234567890abcdef0
```
