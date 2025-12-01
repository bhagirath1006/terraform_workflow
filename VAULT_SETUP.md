# HashiCorp Vault Integration Guide

## Overview

This Terraform project includes integrated HashiCorp Vault support for secret and configuration management. Vault provides secure storage and dynamic secrets for your infrastructure.

## Quick Setup

### 1. Prerequisites

- HashiCorp Vault server running and accessible
- Vault CLI installed on your machine (optional but recommended)
- Valid Vault credentials (token or AppRole)

### 2. Local Vault Setup (Development - WSL)

To quickly test with a local Vault instance in WSL:

#### **Step 1: Start Vault in WSL Terminal**

```bash
# Start Vault in dev mode (data is stored in memory)
vault server -dev
```

You'll see output like:
```
WARNING! dev mode is enabled! In this mode, Vault runs entirely in-memory
and every restart will lose all your data. Never use dev mode in production.

Unseal Key: XXXXXXX...
Root Token: s.XXXXXXXXXXXXXXXXXX
```

**⚠️ Copy and save the Root Token** - you'll need it in the next steps.

#### **Step 2: Configure Vault (New WSL Terminal)**

Open a **new WSL terminal** and run:

```bash
# Set Vault address
export VAULT_ADDR="http://127.0.0.1:8200"

# Set the root token (from Step 1 output)
export VAULT_TOKEN="s.XXXXXXXXXXXXXXXXXX"

# Verify Vault is accessible
vault status

# Enable KV v2 secrets engine
vault secrets enable -version=2 -path=secret kv
```

#### **From PowerShell (Windows)**

To access Vault from Windows PowerShell (if needed):

```powershell
# Set environment variables
$env:VAULT_ADDR = "http://127.0.0.1:8200"
$env:VAULT_TOKEN = "s.XXXXXXXXXXXXXXXXXX"

# Verify connection
vault status
```

### 3. Configure terraform.tfvars

Update your `terraform.tfvars` with your Vault configuration:

```hcl
# ============================================================================
# Vault Configuration (Optional)
# ============================================================================
# Enable Vault for secret management
enable_vault                     = true

# Vault server address
vault_address                    = "http://localhost:8200"

# Skip TLS verification (dev only, use false for production)
vault_skip_tls_verify            = true

# Authentication method
vault_auth_method                = "token"

# Your Vault root token (from vault server -dev output)
vault_token                      = "s.XXXXXXXXXXXXXXXXXX"

# ============================================================================
# Store Your Secrets in Vault
# ============================================================================
vault_secrets = {
  # Docker credentials (if using private Docker registry)
  "docker-credentials" = {
    username = "admin"
    password = "your-secure-password"
  }
  
  # API keys (example)
  "api-keys" = {
    stripe_key = "sk_test_xxx"
    aws_key    = "AKIAIOSFODNN7EXAMPLE"
  }
  
  # Database credentials (example)
  "database-credentials" = {
    host     = "db.example.com"
    port     = "5432"
    username = "db-user"
    password = "db-pass"
  }
}
```

### 4. Set Environment Variables (Alternative)

Instead of storing the token in tfvars, use environment variables:

```powershell
$env:VAULT_ADDR = "http://localhost:8200"
$env:VAULT_TOKEN = "s.xxxxxxxx..."
$env:TF_VAR_vault_address = "http://localhost:8200"
$env:TF_VAR_vault_token = "s.xxxxxxxx..."
```

## Vault Features

### Secrets Storage

Store and retrieve secrets in Vault:

```hcl
vault_secrets = {
  "docker-credentials" = {
    username = "admin"
    password = "secure-pass"
  }
  "database-credentials" = {
    host     = "db.example.com"
    port     = 5432
    username = "db-user"
    password = "db-pass"
  }
}
```

### Database Credentials

Optionally manage database credentials in Vault:

```hcl
enable_vault_database_secrets = true
vault_db_username             = "postgres"
vault_db_password             = "secure-password"
vault_db_host                 = "db.example.com"
vault_db_port                 = 5432
vault_db_name                 = "production"
```

### Application Configuration

Store application-level configuration:

```hcl
enable_vault_app_config = true
vault_api_key           = "sk_live_xxxxxxxx"
vault_debug_mode        = false
```

### AppRole Authentication

For automated, non-interactive authentication:

```hcl
enable_vault_approle = true
vault_token_ttl      = "3600"
vault_token_max_ttl  = "86400"
vault_cidr_list      = ["10.0.0.0/16"]  # Restrict access
```

When enabled, Terraform will output:
- `vault_approle_role_id`: Use this in your application
- `vault_approle_secret_id`: Use this in your application

## Accessing Vault Secrets from EC2 Instance

### Method 1: Via SSH + Vault CLI

```bash
# SSH into your EC2 instance
ssh -i your-key.pem ubuntu@<elastic-ip>

# Install Vault CLI
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vault

# Set Vault address
export VAULT_ADDR="http://vault.example.com:8200"

# Authenticate (if using AppRole)
export VAULT_ROLE_ID="your-role-id"
export VAULT_SECRET_ID="your-secret-id"
vault write -method=POST auth/approle/login role_id=$VAULT_ROLE_ID secret_id=$VAULT_SECRET_ID

# Read secrets
vault kv get secret/data/app/docker-credentials
```

### Method 2: Via Docker Container

Pass Vault credentials to your Docker container:

```bash
docker run -e VAULT_ADDR=http://vault.example.com:8200 \
           -e VAULT_TOKEN=your-token \
           your-image:latest
```

## Deploying with Vault Integration

### Step-by-Step Deployment

1. **Setup Vault Server** (if not already running)
   ```powershell
   vault server -dev
   ```

2. **Configure Variables**
   Edit `terraform.tfvars` and set your Vault address and token

3. **Deploy Infrastructure**
   ```powershell
   .\scripts\deploy.ps1
   ```

4. **Access Secrets from Outputs**
   ```powershell
   terraform output vault_kv_path
   terraform output vault_app_policy_name
   ```

## Vault CLI Commands

```bash
# List all secrets at a path
vault kv list secret/data/app

# Read a specific secret
vault kv get secret/data/app/docker-credentials

# Update a secret
vault kv put secret/data/app/docker-credentials username=newuser password=newpass

# Create access policy
vault policy write app-policy - <<EOF
path "secret/data/app/*" {
  capabilities = ["read", "list"]
}
EOF

# Assign policy to token
vault token create -policy=app-policy

# View AppRole configuration
vault read auth/approle/role/production-app-role
```

## Security Best Practices

### Production Deployment

1. **Enable TLS**
   ```hcl
   vault_skip_tls_verify = false
   vault_address         = "https://vault.prod.example.com:8200"
   ```

2. **Use Restricted CIDR Blocks**
   ```hcl
   vault_cidr_list = ["10.0.1.0/24"]  # Only EC2 subnet
   ```

3. **Store Token Securely**
   - Use `aws_secretsmanager` to store the Vault token
   - Or use IAM-based authentication with AppRole

4. **Rotate Secrets Regularly**
   ```bash
   vault kv put secret/data/app/docker-credentials \
     username=admin \
     password=$(openssl rand -base64 32)
   ```

5. **Audit Vault Access**
   ```bash
   vault audit enable file file_path=/vault/logs/vault-audit.log
   vault audit list
   ```

## Troubleshooting

### Connection Issues

```powershell
# Check if Vault is accessible
$response = Invoke-WebRequest -Uri "http://localhost:8200/v1/sys/health" -ErrorAction SilentlyContinue
if ($response.StatusCode -eq 200) {
    Write-Host "Vault is accessible"
} else {
    Write-Host "Cannot connect to Vault"
}
```

### Authentication Issues

```bash
# Verify token
vault token lookup

# Renew token
vault token renew

# Create new token if needed
vault token create
```

### Secret Access Issues

```bash
# Verify policy
vault policy read app-policy

# Check token policies
vault token lookup-self

# Test policy with different operations
vault kv get secret/data/app/test  # should work if policy allows
```

## Disabling Vault Integration

To disable Vault without affecting other infrastructure:

```hcl
enable_vault = false
```

Then re-deploy:

```powershell
.\scripts\deploy.ps1
```

Vault resources won't be created or modified, but existing infrastructure remains intact.

## Advanced Configuration

### Custom Secret Paths

```hcl
vault_kv_path = "secret/data/production"  # Custom path
```

### Multiple Environments

Create separate `terraform.tfvars` files:

```powershell
# Development
terraform apply -var-file="env/dev.tfvars"

# Staging
terraform apply -var-file="env/staging.tfvars"

# Production
terraform apply -var-file="env/prod.tfvars"
```

### LDAP Authentication

```hcl
vault_auth_method = "ldap"
vault_auth_parameters = {
  username = "your-ldap-user"
  password = "your-ldap-password"
}
```

## Resources

- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs)
- [Vault CLI Commands](https://www.vaultproject.io/docs/commands)
- [Terraform Vault Provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)
- [Vault AppRole Auth Method](https://www.vaultproject.io/docs/auth/approle)
