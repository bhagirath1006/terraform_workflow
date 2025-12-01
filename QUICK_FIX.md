# Quick Fix: Terraform State Mismatch

## Problem
You're getting errors like:
- `EntityAlreadyExists` for IAM roles
- `AlreadyExistsException` for KMS aliases  
- `VpcLimitExceeded` when creating VPC

**Why?** Resources exist in AWS but Terraform state is empty.

## Solution (3 steps)

### 1. Clean Up Existing Resources
```bash
bash cleanup_aws.sh
```
Takes ~2 minutes. Safely deletes all terraform-app resources from AWS.

### 2. Fresh Terraform Apply
```bash
cd terraform
terraform init
terraform apply -var-file="environments/dev.tfvars"
```

### 3. Verify & Commit
```bash
terraform state list  # Should show all resources
git add -A
git commit -m "fix: cleaned AWS state mismatch"
git push  # Triggers GitHub Actions
```

## What cleanup_aws.sh Does
✅ Terminates EC2 instances  
✅ Releases Elastic IPs  
✅ Deletes VPCs and all subnets/security groups  
✅ Deletes IAM roles and policies  
✅ Schedules KMS keys for deletion  

## After This Works
Next GitHub Actions run will:
1. Bootstrap S3 bucket (creates if needed)
2. Initialize Terraform with proper state
3. Create fresh resources
4. Track everything in S3 state file

**No more "resource already exists" errors!**

---

**Need to keep existing resources instead?** See `STATE_MANAGEMENT_GUIDE.md` Option 2 (import existing)
