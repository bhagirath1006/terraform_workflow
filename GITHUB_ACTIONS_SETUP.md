# GitHub Actions Deployment Workflow

## Overview

This GitHub Actions workflow automates your Terraform deployment process:

- **Plan**: Reviews changes before deployment (on PR)
- **Apply**: Deploys infrastructure (on main push)
- **Validate**: Checks code quality and format
- **Notify**: Sends deployment status notifications

## Setup Instructions

### Step 1: Create GitHub Repository

```bash
# Initialize Git repository (if not already done)
cd C:\Users\123\terraform_workflow
git init

# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/terraform_workflow.git

# Create initial commit
git add .
git commit -m "Initial Terraform configuration"

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 2: Configure GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions**

Create these secrets:

#### **Required Secrets:**

| Secret Name | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | `your_actual_access_key_id` |
| `AWS_SECRET_ACCESS_KEY` | `your_actual_secret_access_key` |
| `VAULT_TOKEN` | `root` |
| `SSH_PUBLIC_KEY_PATH` | `~/.ssh/docker-web-app-key.pub` |

#### **Optional Secrets:**

| Secret Name | Value | Purpose |
|---|---|---|
| `SLACK_WEBHOOK_URL` | Your Slack webhook | Slack notifications |

### Step 3: Add Public Key to Repository (Optional but Recommended)

For SSH access from GitHub Actions:

```bash
# Copy your public key
cat ~/.ssh/docker-web-app-key.pub

# Create a secrets directory in repo
mkdir -p .github/secrets

# Add public key (don't commit private key!)
echo "YOUR_PUBLIC_KEY_CONTENT" > .github/secrets/ssh-key.pub
```

**⚠️ NEVER commit your private key!**

### Step 4: Test the Workflow

1. **Make a test change:**
   ```bash
   git checkout -b test-deployment
   echo "# Test Deployment" >> README.md
   git add README.md
   git commit -m "Test workflow"
   git push origin test-deployment
   ```

2. **Create Pull Request:**
   - Go to GitHub repository
   - Click "Compare & pull request"
   - GitHub Actions will automatically run the Plan job
   - Review the plan in the PR comments

3. **Merge to Main (to trigger Apply):**
   - Click "Merge pull request"
   - GitHub Actions will automatically run the Apply job
   - Check the deployment summary in GitHub Actions

## Workflow Details

### Triggers

```yaml
# Triggered on:
1. Push to main branch
2. Pull requests to main
3. Manual trigger (workflow_dispatch)
4. File changes in terraform files
```

### Jobs

#### **Job 1: Terraform Plan**
- Runs on every PR and push
- Validates Terraform configuration
- Creates deployment plan
- Comments on PR with plan details
- Uploads plan artifact

#### **Job 2: Terraform Apply**
- Runs only on main branch push (after plan succeeds)
- Downloads plan artifact
- Applies infrastructure changes
- Outputs deployment information
- Sends notifications (if configured)

#### **Job 3: Cleanup**
- Runs when PR is closed (optional)
- Can destroy test resources

## GitHub Actions Files

Your workflow file is located at:
```
.github/workflows/terraform-deploy.yml
```

### Customization

#### Enable Slack Notifications

1. Create Slack Webhook:
   - Go to https://api.slack.com/messaging/webhooks
   - Create new webhook for your workspace
   - Copy webhook URL

2. Add secret to GitHub:
   - Add `SLACK_WEBHOOK_URL` secret with webhook URL

#### Enable PR Cleanup (Destroy on Close)

Edit `.github/workflows/terraform-deploy.yml`:

```yaml
- name: Terraform Destroy (Optional - uncomment to enable)
  run: terraform destroy -auto-approve
```

## Usage Examples

### Deploy on Push to Main
```bash
git push origin main
# Automatically triggers plan → apply workflow
```

### Deploy on PR Merge
```bash
# Create feature branch
git checkout -b feature/new-docker-image

# Make changes
echo "docker_image = \"my-image:latest\"" >> terraform.tfvars

# Push and create PR
git push origin feature/new-docker-image

# Review plan in PR comments, then merge
# Automatically triggers apply on merge
```

### Manual Trigger
- Go to **Actions** tab in GitHub
- Select **Terraform Deploy** workflow
- Click **Run workflow**

## Monitoring Deployments

### View Workflow Runs

1. Go to **Actions** tab in repository
2. Click **Terraform Deploy** workflow
3. See all runs with status, duration, and logs

### Check Logs

Click on a workflow run to see detailed logs:
- ✅ **Green checkmark**: Success
- ❌ **Red X**: Failed
- ⏳ **Yellow circle**: In progress

### View Deployment Summary

After successful apply, check:
- **Deployment Summary** tab in GitHub Actions
- Contains: Website URL, Elastic IP, deployment info

## Security Best Practices

### Do's ✅
- Store sensitive data in GitHub Secrets
- Use environment-specific secrets
- Rotate credentials regularly
- Review plan before merging
- Lock main branch (require PR reviews)
- Audit GitHub Actions logs

### Don'ts ❌
- Never commit AWS keys to repository
- Never commit Vault tokens
- Never commit SSH private keys
- Never use `auto-approve` in production
- Never share secrets in logs

## Troubleshooting

### Workflow Fails with "Invalid credentials"

**Solution**: Check GitHub Secrets
```bash
# Verify secret names in GitHub match workflow
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# VAULT_TOKEN
```

### Terraform State Lock Error

**Solution**: Manual unlock
```bash
# In your local terminal
terraform force-unlock LOCK_ID

# Or reset state (dev only)
terraform state list
```

### SSH Key Not Found

**Solution**: Verify key path
```bash
# Check if key exists
cat ~/.ssh/docker-web-app-key.pub

# Update SSH_PUBLIC_KEY_PATH secret if needed
```

## Advanced Configuration

### Multi-Environment Deployments

Create separate workflows for dev/staging/prod:

```yaml
# .github/workflows/deploy-staging.yml
on:
  push:
    branches:
      - staging
```

### Approval Before Apply

Add manual approval step:

```yaml
terraform-apply:
  needs: terraform-plan
  environment:
    name: production
```

Then configure environment protection rules in GitHub.

### Store State in S3

Update `provider.tf`:

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Terraform GitHub Actions](https://github.com/hashicorp/setup-terraform)
- [AWS Credentials Action](https://github.com/aws-actions/configure-aws-credentials)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices)
