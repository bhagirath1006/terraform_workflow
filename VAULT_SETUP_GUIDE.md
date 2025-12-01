# HashiCorp Vault Setup Guide

This guide provides step-by-step instructions to set up HashiCorp Vault for your Terraform infrastructure.

## Prerequisites

- HashiCorp Vault (installed and running)
- Terraform 1.0+
- AWS CLI configured with appropriate credentials
- Access to Vault admin credentials

## 1. Installing and Running Vault Locally (Development)

### Option A: Using Docker

```bash
docker run -d -p 8200:8200 \
  --name vault \
  -e VAULT_DEV_ROOT_TOKEN_ID=my-root-token \
  vault:latest
```

### Option B: Binary Installation

```bash
# Download Vault from https://www.vaultproject.io/downloads
unzip vault_*.zip
sudo mv vault /usr/local/bin/

# Start Vault in dev mode
vault server -dev -dev-root-token-id=my-root-token
```

## 2. Accessing Vault

```bash
# Set the Vault address
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='my-root-token'

# Verify Vault is running
vault status
```

## 3. Initialize KV v2 Secrets Engine

```bash
# Enable KV v2 secrets engine at "secret" path
vault secrets enable -version=2 kv

# Verify it's enabled
vault secrets list
```

## 4. Create Secrets in Vault

```bash
# Store application secrets for dev environment
vault kv put secret/dev/app \
  docker_username="your-docker-user" \
  docker_password="your-docker-password" \
  db_username="devadmin" \
  db_password="dev-secure-password" \
  api_key="dev-api-key"

# Store database secrets
vault kv put secret/dev/database \
  username="devadmin" \
  password="dev-db-password" \
  engine="postgres" \
  port=5432 \
  host="localhost"
```

## 5. Configure AppRole for EC2 Instances

```bash
# Enable AppRole authentication
vault auth enable approle

# Create AppRole role for EC2
vault write auth/approle/role/terraform-app-ec2-dev \
  token_num_uses=0 \
  token_ttl=3600 \
  token_max_ttl=86400 \
  secret_id_num_uses=0

# Get Role ID
vault read auth/approle/role/terraform-app-ec2-dev/role-id

# Generate Secret ID
vault write -f auth/approle/role/terraform-app-ec2-dev/secret-id
```

## 6. Create Vault Policy for EC2

```bash
# Create a policy file: ec2-policy.hcl
cat > ec2-policy.hcl <<EOF
path "secret/data/dev/*" {
  capabilities = ["read", "list"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}
EOF

# Write policy to Vault
vault policy write terraform-app-ec2-dev ec2-policy.hcl

# Attach policy to AppRole
vault write auth/approle/role/terraform-app-ec2-dev/policies \
  policies=terraform-app-ec2-dev
```

## 7. Configure Terraform Variables

Update your environment tfvars file (e.g., `terraform/environments/dev.tfvars`):

```hcl
# Vault Configuration
vault_addr            = "http://localhost:8200"
vault_token           = "my-root-token"  # Use AppRole token in production
vault_skip_tls_verify = true             # Set to false in production

# Other variables
docker_username = "your-docker-user"
docker_password = "your-docker-password"
db_username     = "devadmin"
db_password     = "dev-db-password"
api_key         = "dev-api-key"
```

## 8. Deploy Infrastructure

```bash
# Initialize Terraform
cd terraform
terraform init

# Plan deployment
terraform plan -var-file="environments/dev.tfvars" -out=tfplan

# Apply configuration
terraform apply tfplan
```

## 9. Production Considerations

### For Staging/Production:

1. **Use Vault Enterprise or Vault Cloud**
   - High availability setup
   - Automated backups
   - Audit logging

2. **Enable TLS**
   ```hcl
   vault_addr            = "https://vault.prod.example.com:8200"
   vault_skip_tls_verify = false
   ```

3. **Use AppRole for Authentication**
   - Generate Role ID and Secret ID
   - Store Secret ID in AWS Secrets Manager or GitHub Secrets
   - Rotate Secret IDs regularly

4. **Set Up Vault Logging and Audit**
   ```bash
   # Enable audit logging
   vault audit enable file file_path=/vault/logs/audit.log
   ```

5. **Configure High Availability**
   - Use S3 backend for state storage
   - Set up multiple Vault nodes
   - Configure auto-unsealing with AWS KMS

## 10. GitHub Actions Integration

Update your GitHub Actions workflow to use Vault:

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Authenticate to Vault
        uses: hashicorp/vault-action@v2
        with:
          url: ${{ secrets.VAULT_ADDR }}
          role: terraform-app-ec2-dev
          method: approle
          roleId: ${{ secrets.VAULT_ROLE_ID }}
          secretId: ${{ secrets.VAULT_SECRET_ID }}
          jwtPayloadFormat: "wrapped"
          exportToken: true

      - name: Deploy with Terraform
        env:
          VAULT_ADDR: ${{ secrets.VAULT_ADDR }}
          VAULT_TOKEN: ${{ env.VAULT_TOKEN }}
        run: |
          cd terraform
          terraform apply -var-file="environments/dev.tfvars" -auto-approve
```

## 11. EC2 Instance Configuration

The EC2 instance will automatically receive AppRole credentials via user_data script:

```bash
#!/bin/bash
# /opt/vault/config.hcl

role_id_unwrap_token="<TOKEN_FROM_VAULT>"
secret_id_unwrap_token="<TOKEN_FROM_VAULT>"

# Store these in secure location on EC2
# Use AWS Systems Manager Parameter Store for additional security
```

## 12. Troubleshooting

### Check Vault Status
```bash
vault status
```

### List Secrets
```bash
vault kv list secret/dev
vault kv get secret/dev/app
```

### Check AppRole Configuration
```bash
vault read auth/approle/role/terraform-app-ec2-dev
```

### View Terraform Logs
```bash
TF_LOG=DEBUG terraform apply -var-file="environments/dev.tfvars"
```

## 13. Security Best Practices

1. **Rotate Secrets Regularly**
   ```bash
   vault kv put secret/dev/app docker_password="new-password"
   ```

2. **Use Least Privilege Access**
   - Create separate AppRoles for each service
   - Limit policy capabilities

3. **Enable Audit Logging**
   - Monitor all secret access
   - Review audit logs regularly

4. **Implement Secret Rotation**
   - Use Vault's secret engines for dynamic secrets
   - Rotate database passwords automatically

5. **Backup Vault Keys**
   - Use Vault's backup utilities
   - Store in secure, separate location
   - Test restore procedures regularly

6. **Network Security**
   - Run Vault in private network
   - Use VPN for remote access
   - Implement firewall rules

## Additional Resources

- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs)
- [Vault AppRole Auth](https://www.vaultproject.io/docs/auth/approle)
- [Terraform Vault Provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)
- [Vault Best Practices](https://learn.hashicorp.com/tutorials/vault/pattern-approle)
