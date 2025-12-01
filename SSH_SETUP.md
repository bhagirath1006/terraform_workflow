# SSH Key Setup Guide

## Quick Start

### 1. Generate SSH Key Locally

```bash
bash generate_ssh_key.sh
```

This will:
- Generate RSA 4096-bit key pair
- Store keys in `ssh-keys/` directory
- Output the public key content

### 2. Copy Public Key to terraform.tfvars

The script will output something like:

```
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABA..."
```

Add this line to `terraform/environments/dev.tfvars`:

```tfvars
# SSH Public Key
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABA..."
```

### 3. Deploy Infrastructure

```bash
cd terraform
terraform apply -auto-approve
```

### 4. SSH to Your EC2 Instance

```bash
# Get the Elastic IP from outputs
terraform output elastic_ip

# SSH using the private key
ssh -i ssh-keys/terraform-app-key ubuntu@<elastic-ip>
```

---

## Key Files

| File | Purpose |
|------|---------|
| `generate_ssh_key.sh` | Generate SSH key pair locally |
| `ssh-keys/terraform-app-key` | Private key (KEEP SAFE) |
| `ssh-keys/terraform-app-key.pub` | Public key (deploy to AWS) |
| `terraform/environments/dev.tfvars` | Add public key here |

---

## Security Recommendations

### 1. Protect Your Private Key

```bash
# Private key should be readable only by you
chmod 600 ssh-keys/terraform-app-key

# Never commit to git
echo "ssh-keys/" >> .gitignore
```

### 2. Use Key Passphrase (Optional)

For enhanced security, generate key with passphrase:

```bash
ssh-keygen -t rsa -b 4096 -f ssh-keys/terraform-app-key -C "terraform-app"
```

Then when you SSH, you'll be prompted for the passphrase.

### 3. Restrict SSH Access

Update `ssh_allowed_cidr` in `terraform/environments/dev.tfvars` to restrict SSH to your IP:

```tfvars
# Instead of 10.0.0.0/8, use your actual IP with /32
ssh_allowed_cidr = ["YOUR_IP/32"]
```

---

## Terraform Changes

### Added to EC2 Module:

**variables.tf:**
- `ssh_public_key` - Public key content

**main.tf:**
- `aws_key_pair.deployer` - Creates key pair in AWS
- `key_name` on EC2 instance - Links instance to key pair

### Root Terraform:

**variables.tf:**
- `ssh_public_key` variable

**main.tf:**
- Passes `ssh_public_key` to EC2 module

**environments/dev.tfvars:**
- Comment showing where to add public key

---

## Troubleshooting

### Key Not Working for SSH?

```bash
# Verify key permissions
ls -la ssh-keys/

# Should show:
# -rw------- (600) terraform-app-key
# -rw-r--r-- (644) terraform-app-key.pub
```

### Instance Has Old Key?

```bash
# Destroy and recreate (after cleanup)
terraform destroy -auto-approve
bash cleanup_aws.sh
terraform apply -auto-approve
```

### Can't Find Elastic IP?

```bash
# Get the output
terraform output elastic_ip

# Or check AWS console:
# EC2 → Elastic IPs → terraform-app-eip
```

---

## Workflow Summary

```mermaid
1. Generate SSH Key Locally
   ↓
2. Add Public Key to terraform.tfvars
   ↓
3. Run terraform apply
   ↓
4. AWS creates EC2 with key pair
   ↓
5. SSH to instance using private key
   ↓
6. Deploy your application
```

---

## Next Steps

1. ✅ Generate SSH key: `bash generate_ssh_key.sh`
2. ✅ Add to terraform.tfvars
3. ✅ Run terraform apply
4. ✅ Test SSH access
5. Deploy your application/container
