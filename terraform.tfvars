# AWS Configuration
aws_region        = "us-east-1"
availability_zone = "us-east-1a"

# Project Configuration
project_name = "docker-web-app"
environment  = "production"

# VPC Configuration
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidr = "10.0.1.0/24"

# EC2 Configuration
ami_id            = "ami-0c55b159cbfafe1f0"
instance_type     = "t2.micro"
allowed_ssh_cidrs = ["0.0.0.0/0"]
root_volume_size  = 20

# SSH Key Configuration
# Option 1: Use existing EC2 key pair (create in AWS Console first)
# ssh_key_name = "docker-web-app-key"

# Option 2: Create new key pair from public key file (RECOMMENDED)
ssh_key_name        = "docker-web-app-key"
ssh_public_key_path = "~/.ssh/docker-web-app-key.pub"

# EIP Configuration
create_new_eip = true

# Vault Configuration (Optional)
enable_vault          = true
vault_address         = "http://localhost:8200"
vault_skip_tls_verify = true
vault_token           = "root"

# ============================================================================
# Store Your Secrets in Vault
# ============================================================================
vault_secrets = {
  # AWS Credentials - Add your actual values in GitHub Secrets, NOT here!
  "aws-credentials" = {
    access_key = "YOUR_AWS_ACCESS_KEY" # Set in GitHub Secrets
    secret_key = "YOUR_AWS_SECRET_KEY" # Set in GitHub Secrets
  }

  # Docker Credentials (optional, for private registries)
  "docker-credentials" = {
    username = "admin"
    password = "docker-password"
  }
}

