# Terraform State Management Guide

## Current State Issue

You have Terraform infrastructure resources already created in AWS, but the state file is empty or doesn't know about them. This causes conflicts when applying Terraform configurations.

**Symptoms:**
- Errors like "EntityAlreadyExists" when running terraform apply
- Errors like "VpcLimitExceeded" 
- Resources exist in AWS but Terraform tries to recreate them

**Root Cause:**
- Resources were created in previous manual AWS deployments or earlier Terraform runs
- The new S3 remote state backend doesn't contain information about these resources
- Terraform's local state was empty or lost between runs

## Solution Options

### Option 1: Clean Slate (Recommended for this setup)
**Scenario:** Start fresh with clean AWS resources and proper state tracking

**Steps:**
```bash
# 1. Run cleanup script to delete existing resources
bash cleanup_aws.sh

# 2. Initialize Terraform with new backend
cd terraform
terraform init

# 3. Create everything fresh
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"

# 4. Verify resources created
terraform state list
aws ec2 describe-instances --region ap-south-1 --filters "Name=tag:Project,Values=terraform-app"
```

**Pros:**
- Clean state file
- All resources properly tracked
- No state mismatch issues
- Easier to debug future problems

**Cons:**
- Need to recreate resources (takes ~2-3 minutes)
- Temporary service downtime if production

### Option 2: Import Existing Resources
**Scenario:** Keep existing resources and import them into state

**Steps:**
```bash
# 1. Run import script
bash import_state.sh

# 2. Verify all resources imported
terraform state list

# 3. Run plan to see if any changes needed
terraform plan -var-file="environments/dev.tfvars"

# 4. Apply any changes
terraform apply -var-file="environments/dev.tfvars"
```

**Pros:**
- Keeps existing resources running
- No downtime
- Preserves data/configuration

**Cons:**
- State file may be incomplete
- Resource IDs must be manually mapped
- Requires knowledge of existing resource structure

## Recommended: Option 1 (Clean Slate)

For this project, **Option 1 is recommended** because:

1. ✅ This appears to be a dev environment (dev.tfvars)
2. ✅ EC2 instances are stateless (deployed via Docker container from user_data)
3. ✅ EIP prevents VPC from being lost (prevent_destroy)
4. ✅ Faster iteration and cleaner state
5. ✅ Fresh state means no lingering configuration drift

## How the Fix Works

### Current Architecture
```
Local Terraform Code
        ↓
Terraform Init
        ↓
S3 Backend (Empty)
        ↓
AWS (Existing Resources) ← MISMATCH!
```

### After Cleanup & Fresh Apply
```
Local Terraform Code
        ↓
Terraform Init
        ↓
S3 Backend (Populated with resource IDs)
        ↓
AWS (Resources created fresh) ← IN SYNC!
```

### State File Content
After successful apply, your state file will contain:
```
module.vpc.aws_vpc.main
module.vpc.aws_subnet.public
module.vpc.aws_subnet.private
module.vpc.aws_security_group.ssh
module.vpc.aws_security_group.app
module.vpc.aws_nat_gateway.main
module.vpc.aws_eip.nat
module.vpc.aws_cloudwatch_log_group.vpc_flow_logs
module.vpc.aws_flow_logs.vpc
module.vpc.aws_kms_key.vpc_logs
module.vpc.aws_kms_alias.vpc_logs
module.vpc.aws_iam_role.vpc_flow_logs
module.vpc.aws_iam_role_policy.vpc_flow_logs

module.ec2.aws_instance.app
module.ec2.aws_eip.app
module.ec2.aws_cloudwatch_log_group.app
module.ec2.aws_kms_key.ec2_logs
module.ec2.aws_kms_alias.ec2_logs
module.ec2.aws_iam_role.ec2
module.ec2.aws_iam_role_policy.ec2
module.ec2.aws_iam_instance_profile.ec2
```

## Recovery Steps (If Needed)

**If you make a mistake:**

### Recover from local state
```bash
# 1. Check if .terraform/terraform.tfstate exists locally
ls -la .terraform/

# 2. Recover from it
cp .terraform/terraform.tfstate terraform.tfstate.backup

# 3. Run init again
terraform init
```

### Recover from S3
```bash
# 1. List state file versions
aws s3api list-object-versions \
  --bucket terraform-app-state-bucket \
  --key dev/terraform.tfstate

# 2. Restore previous version
aws s3api get-object \
  --bucket terraform-app-state-bucket \
  --key dev/terraform.tfstate \
  --version-id VERSION_ID \
  terraform.tfstate.restored

# 3. Use restored state
cp terraform.tfstate.restored terraform.tfstate
terraform init
```

### Lock Issues
```bash
# If state is locked and apply hangs:

# 1. Check lock
aws dynamodb scan \
  --table-name terraform-app-locks \
  --region ap-south-1

# 2. Force unlock (ONLY if you're sure no one is applying)
terraform force-unlock LOCK_ID
```

## Monitoring State Health

### Check state periodically
```bash
# View all resources in state
terraform state list

# Inspect specific resource
terraform state show module.vpc.aws_vpc.main

# Pull latest state from backend
terraform refresh

# Plan to see if state matches reality
terraform plan
```

### Watch for drift
```bash
# Setup drift detection
terraform plan > plan.txt
grep -E "^(~|\+|-)" plan.txt || echo "✅ No drift detected"
```

## Future Deployments

After cleanup and first successful apply:

1. **Automatic Bootstrap**
   - GitHub Actions runs bootstrap.sh
   - S3 bucket and DynamoDB table already exist (idempotent)
   - Terraform init connects to existing backend

2. **State Persistence**
   - All resources stay in S3 state
   - prevent_destroy on VPC and EIP prevents accidental deletion
   - Each apply updates only changed resources

3. **CI/CD Flow**
   ```
   Push to main
        ↓
   GitHub Actions triggered
        ↓
   Bootstrap (creates backend if needed)
        ↓
   Terraform Init (uses existing backend)
        ↓
   Terraform Plan (shows what will change)
        ↓
   Terraform Apply (updates only changed resources)
        ↓
   Resources in AWS updated ✅
   ```

## Cleanup Script Overview

The `cleanup_aws.sh` script:

1. ✅ Finds EC2 instances with `Project=terraform-app` tag
2. ✅ Terminates them and waits for completion
3. ✅ Finds and releases Elastic IPs
4. ✅ Finds VPCs and deletes all associated resources:
   - VPC Flow Logs
   - CloudWatch Log Groups
   - Internet Gateways
   - Subnets
   - Security Groups
5. ✅ Deletes VPC itself
6. ✅ Finds and deletes IAM Roles and Policies
7. ✅ Schedules KMS Keys for deletion (7-day pending)

**Safety:** Uses only read-only queries first, then deletion with verbose output.

## After Cleanup

Once cleanup completes:

```bash
# 1. Verify everything deleted
aws ec2 describe-instances --region ap-south-1 --filters "Name=tag:Project,Values=terraform-app"
# Should return empty

# 2. Initialize Terraform
cd terraform
terraform init

# 3. Check plan
terraform plan -var-file="environments/dev.tfvars"

# 4. Apply
terraform apply -var-file="environments/dev.tfvars"

# 5. Commit and push
cd ..
git add -A
git commit -m "fix: cleaned up AWS resources and state"
git push

# 6. GitHub Actions will automatically run
```

## Questions?

- **"Will my data be lost?"** - Yes, cleanup deletes everything. This is dev environment.
- **"Can I keep existing resources?"** - Use `import_state.sh` instead of cleanup
- **"How long does cleanup take?"** - ~2-3 minutes
- **"Is cleanup reversible?"** - No, resources are deleted. But easy to recreate with terraform apply
- **"Will prevent_destroy help?"** - No, cleanup explicitly disables this. But prevent_destroy will protect against future accidental deletes
