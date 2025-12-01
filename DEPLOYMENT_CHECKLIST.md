# 📋 Deployment Checklist

## ✅ Pre-Deployment Verification

### Local Environment
- [ ] Terraform installed (`terraform version` works)
- [ ] AWS CLI configured with credentials
- [ ] SSH key created: `~/.ssh/docker-web-app-key`
- [ ] Vault running in WSL: `vault status` works
- [ ] All environment variables set:
  - `$env:AWS_ACCESS_KEY_ID`
  - `$env:AWS_SECRET_ACCESS_KEY`
  - `$env:AWS_DEFAULT_REGION`

### Repository Setup
- [ ] Git repository initialized
- [ ] Remote added: `git remote -v`
- [ ] Code committed: `git log`
- [ ] All files tracked: `git status`

### Configuration Files
- [ ] `terraform.tfvars` configured with:
  - [ ] AWS region and AZ
  - [ ] SSH key name and path
  - [ ] Vault token and address
  - [ ] Docker image settings
  - [ ] AWS credentials in vault_secrets

- [ ] `modules/ec2/main.tf` - SSH key resource
- [ ] `modules/docker/main.tf` - Container config
- [ ] `.github/workflows/terraform-deploy.yml` - Workflow file

### Vault Setup
- [ ] Vault server running (`vault server -dev`)
- [ ] KV secrets engine enabled (`vault secrets enable -version=2 -path=secret kv`)
- [ ] AWS secrets stored: `vault kv get secret/app/aws-credentials`

---

## 🚀 Deployment Steps (Local)

### Step 1: Verify Configuration
```bash
cd C:\Users\123\terraform_workflow
terraform fmt -check -recursive
terraform validate
```

**Expected:** No errors

### Step 2: Initialize Terraform
```bash
terraform init
```

**Expected:** Providers downloaded, backend initialized

### Step 3: Create Plan
```bash
terraform plan -out=tfplan
```

**Expected:** Plan shows resources to be created (VPC, EC2, EIP, etc.)

### Step 4: Review Plan
```bash
# Review the plan output
# Check for correct resources, counts, and configurations
# Verify no sensitive data exposed
```

**Expected:** All resources look correct

### Step 5: Apply Plan
```bash
terraform apply tfplan
```

**Expected:** Resources created successfully, outputs shown

### Step 6: Verify Deployment
```bash
# Check outputs
terraform output

# Should show:
# - website_url
# - elastic_ip
# - docker_container_id
# - deployment_summary
# - vault_status
```

---

## 🔗 GitHub Actions Deployment

### Step 1: Push to GitHub
```bash
git add .
git commit -m "Deploy infrastructure with GitHub Actions"
git push origin main
```

**Expected:** Code pushed to GitHub main branch

### Step 2: Create GitHub Secrets
Go to: **Repo** → **Settings** → **Secrets and variables** → **Actions**

Add secrets:
- [ ] `AWS_ACCESS_KEY_ID`
- [ ] `AWS_SECRET_ACCESS_KEY`
- [ ] `VAULT_TOKEN`
- [ ] `SSH_PUBLIC_KEY_PATH`

**Expected:** All 4 secrets added successfully

### Step 3: Create Test PR
```bash
git checkout -b test-workflow
echo "# Test" >> README.md
git add README.md
git commit -m "Test GitHub Actions"
git push origin test-workflow
```

Then on GitHub:
- [ ] Create Pull Request
- [ ] Wait for **Terraform Plan** to complete
- [ ] Review plan in PR comments

**Expected:** Plan job completes without errors

### Step 4: Merge to Deploy
- [ ] Click **Merge pull request**
- [ ] Wait for **Terraform Apply** to complete

**Expected:** Apply job completes, deployment summary shown

### Step 5: Verify Deployment
- [ ] Check **Actions** tab → **Terraform Deploy**
- [ ] View deployment summary
- [ ] Check AWS Console for created resources

**Expected:** Resources created in AWS

---

## ✔️ Post-Deployment Verification

### Local Verification
```bash
# Check Terraform state
terraform state list

# View outputs
terraform output

# Connect to EC2
ssh -i ~/.ssh/docker-web-app-key ubuntu@<ELASTIC_IP>
docker ps
```

### AWS Console Verification
- [ ] VPC created: `docker-web-app-vpc`
- [ ] EC2 instance running
- [ ] Elastic IP associated
- [ ] Security groups configured
- [ ] Docker container running

### Application Access
- [ ] Access website: `http://<ELASTIC_IP>`
- [ ] See nginx welcome page or your application
- [ ] HTTP status 200 OK

### Vault Verification
- [ ] Secrets stored: `vault kv list secret/app`
- [ ] AWS credentials accessible: `vault kv get secret/app/aws-credentials`

---

## 🧹 Cleanup

### If Need to Destroy (Development Only)
```bash
# Plan destruction
terraform plan -destroy

# Destroy resources
terraform destroy

# Confirm prompt
```

### Clean Up GitHub
- [ ] Delete feature branches
- [ ] Close old PRs
- [ ] Review secrets are secure

---

## 🐛 Troubleshooting

### Terraform Plan Fails
```bash
# Check validation
terraform validate

# Check format
terraform fmt -recursive

# Check variables
terraform plan -var-file=terraform.tfvars
```

### Terraform Apply Fails
```bash
# Check state
terraform state list

# Check resources
terraform show

# Check AWS permissions
aws ec2 describe-instances
```

### GitHub Actions Fails
- [ ] Check job logs in **Actions** tab
- [ ] Verify secrets are set correctly
- [ ] Check terraform files are committed
- [ ] Verify branch is main

### Connection Issues
```bash
# Check if EC2 is running
aws ec2 describe-instances --instance-ids i-xxxxx

# Check security group
aws ec2 describe-security-groups --group-ids sg-xxxxx

# SSH with verbose logging
ssh -v -i ~/.ssh/docker-web-app-key ubuntu@<IP>
```

---

## 📊 Expected Outputs

After successful deployment, you should see:

```
Outputs:

deployment_summary = {
  "docker_image" = "nginx:latest"
  "elastic_ip" = "XX.XX.XX.XX"
  "instance_id" = "i-0123456789abcdef"
  "website_url" = "http://XX.XX.XX.XX"
}
docker_container_id = "abc123def456..."
elastic_ip = "XX.XX.XX.XX"
vault_status = "Enabled at http://localhost:8200"
website_url = "http://XX.XX.XX.XX"
```

---

## 📝 Sign-Off

- [ ] Local deployment successful
- [ ] GitHub Actions workflow working
- [ ] Application accessible via website URL
- [ ] Vault secrets stored and accessible
- [ ] Documentation reviewed
- [ ] Cleanup procedures understood

**Deployment Complete! 🎉**
