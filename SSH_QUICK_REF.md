# SSH Key Setup - Quick Reference

## One-Line Command (Fully Automated)

```bash
bash deploy_with_ssh.sh
```

This script handles everything:
1. ✅ Generate SSH key (if needed)
2. ✅ Add public key to terraform.tfvars
3. ✅ Run terraform init/validate/plan
4. ✅ Run terraform apply
5. ✅ Output SSH connection string

---

## Manual Steps (If Preferred)

### 1. Generate SSH Key
```bash
bash generate_ssh_key.sh
```

### 2. Copy Output
Script will output:
```
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABA..."
```

### 3. Add to terraform/environments/dev.tfvars
```tfvars
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABA..."
```

### 4. Deploy
```bash
cd terraform
terraform apply -var-file=environments/dev.tfvars
```

### 5. SSH to Instance
```bash
ssh -i ssh-keys/terraform-app-key ubuntu@<elastic-ip>
```

---

## Key Files

| File | Purpose |
|------|---------|
| `generate_ssh_key.sh` | Generate SSH key pair |
| `deploy_with_ssh.sh` | Full automated workflow |
| `ssh-keys/` | Local key storage (git ignored) |
| `SSH_SETUP.md` | Detailed guide |

---

## Security Checklist

- ✅ Private key in `ssh-keys/` (git ignored)
- ✅ Private key permissions 600
- ✅ Public key in terraform.tfvars
- ✅ Terraform managing AWS key pair
- ✅ SSH restricted to VPC CIDR (update if needed)

---

## Testing SSH Access

```bash
# Get instance IP
INSTANCE_IP=$(terraform output -raw elastic_ip)

# SSH test
ssh -i ssh-keys/terraform-app-key ubuntu@$INSTANCE_IP

# Once connected, verify:
# - Docker is running
# - AWS CLI is available
# - CloudWatch logs are configured
```

---

## If SSH Connection Fails

### Check 1: SSH Key Permissions
```bash
ls -la ssh-keys/
# Should show: -rw------- terraform-app-key
```

### Check 2: Security Group
```bash
# Verify SSH (port 22) is allowed
# Should allow from ssh_allowed_cidr
```

### Check 3: Instance Status
```bash
terraform output  # Check instance_id

# AWS Console: EC2 → Instances → Check status
```

### Check 4: EC2 System Log
```bash
# AWS Console: EC2 → Instance → Monitor → System Log
# Look for: "Cloud-init finished"
```

---

## Troubleshooting

### "Permission denied (publickey)"
- Verify private key permissions: `chmod 600 ssh-keys/terraform-app-key`
- Verify public key was added to tfvars
- Verify terraform apply succeeded

### "Connection refused"
- Check security group allows SSH (port 22)
- Check instance is running: `terraform output instance_id`
- Wait 30 seconds after instance creation

### "No such file or directory"
- Generate key first: `bash generate_ssh_key.sh`
- Or use full path: `ssh -i $(pwd)/ssh-keys/terraform-app-key ubuntu@...`

---

## Next: Deploy Your Application

Once SSH works:

```bash
# Copy files to instance
scp -r -i ssh-keys/terraform-app-key ./app ubuntu@<ip>:/home/ubuntu/

# SSH into instance
ssh -i ssh-keys/terraform-app-key ubuntu@<ip>

# Inside instance:
cd ~/app
docker-compose up -d

# Or pull from ECR/Docker Hub
docker pull your-image:latest
docker run -d -p 80:3000 your-image:latest
```

---

## That's It! 🎉

SSH key setup is complete and integrated with Terraform. Your infrastructure now supports secure key-based access!
