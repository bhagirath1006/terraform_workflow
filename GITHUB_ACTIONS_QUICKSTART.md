# 🚀 Quick Start: GitHub Actions Deployment

## What's New

✅ **GitHub Actions Workflow Created** - Automated Terraform deployment pipeline  
✅ **Setup Guide** - Complete instructions in `GITHUB_ACTIONS_SETUP.md`  
✅ **Security** - GitHub Secrets for sensitive data  

---

## ⚡ Quick Setup (5 minutes)

### 1. Push Code to GitHub

```bash
cd C:\Users\123\terraform_workflow

# Initialize Git (if not already done)
git init
git remote add origin https://github.com/YOUR_USERNAME/terraform_workflow.git

# Create initial commit
git add .
git commit -m "Initial Terraform + GitHub Actions setup"
git branch -M main
git push -u origin main
```

### 2. Add GitHub Secrets

Go to: **Your Repo** → **Settings** → **Secrets and variables** → **Actions**

Add these 4 secrets:

```
AWS_ACCESS_KEY_ID = your_actual_access_key_id
AWS_SECRET_ACCESS_KEY = your_actual_secret_access_key
VAULT_TOKEN = root
SSH_PUBLIC_KEY_PATH = ~/.ssh/docker-web-app-key.pub
```

### 3. Create a Test PR

```bash
git checkout -b test-workflow
echo "# Test Deployment" >> README.md
git add README.md
git commit -m "Test GitHub Actions"
git push origin test-workflow
```

Then on GitHub:
- Click "Compare & pull request"
- GitHub Actions will automatically run the **Plan** job
- Review the plan in the PR comments

### 4. Merge to Deploy

- Click "Merge pull request"
- GitHub Actions will automatically run the **Apply** job
- Check the deployment in **Actions** tab

---

## 📁 Workflow File Location

```
.github/workflows/terraform-deploy.yml
```

---

## 🔄 Workflow Triggers

| Trigger | Action |
|---------|--------|
| Push to `main` | Run Plan + Apply |
| Create PR to `main` | Run Plan (comment on PR) |
| Manual dispatch | Run Plan + Apply |
| PR close | Cleanup (optional) |

---

## 📊 Monitoring

### View Runs
- Go to **Actions** tab in GitHub
- Click **Terraform Deploy**
- See all runs with status

### Check Logs
- Click on a workflow run
- See detailed logs for each step
- Check deployment summary

### Failed Deployment?
- Click on failed job
- Scroll to failed step
- Read error message and logs

---

## 🔐 Security Checklist

✅ AWS credentials in GitHub Secrets (not in code)  
✅ Vault token in GitHub Secrets  
✅ SSH keys only in `.ssh/` (not committed)  
✅ `.gitignore` prevents secret commits  
✅ PR review before merge (recommended)  

---

## 📚 Full Documentation

See `GITHUB_ACTIONS_SETUP.md` for:
- Detailed setup instructions
- Customization options
- Troubleshooting guide
- Advanced configurations
- Multi-environment setup

---

## 🎯 Next Steps

1. ✅ Push code to GitHub
2. ✅ Add GitHub Secrets
3. ✅ Create test PR
4. ✅ Merge to deploy
5. ✅ Monitor deployment in Actions tab

---

**Need help?** Check:
- `.github/workflows/terraform-deploy.yml` - Workflow definition
- `GITHUB_ACTIONS_SETUP.md` - Full setup guide
- GitHub Actions logs - Troubleshooting

**Happy deploying! 🚀**
