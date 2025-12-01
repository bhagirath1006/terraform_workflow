# AWS Configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "docker-web-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for resources"
  type        = string
  default     = "us-east-1a"
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Change this to your IP for security
}

# EC2 Configuration
variable "ami_id" {
  description = "AMI ID (Ubuntu 22.04 LTS)"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Replace with your region's Ubuntu AMI
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro" # Free tier eligible
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

# SSH Key Configuration
variable "ssh_key_name" {
  description = "AWS EC2 Key Pair name (create one in AWS Console or use 'aws ec2 create-key-pair')"
  type        = string
  default     = "docker-web-app-key"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file (e.g., ~/.ssh/id_rsa.pub). If empty, uses existing key by name"
  type        = string
  default     = ""
}

# EIP Configuration
variable "create_new_eip" {
  description = "Whether to create a new Elastic IP (false will search for existing)"
  type        = bool
  default     = true
}

# EC2 User Data - Docker Installation and Container Deployment
variable "user_data_script" {
  description = "User data script for EC2 initialization (Docker installation and container deployment)"
  type        = string
  default     = <<-EOF
              #!/bin/bash
              set -e
              
              # Update system
              apt-get update
              apt-get upgrade -y
              
              # Install Docker
              apt-get install -y docker.io curl wget

              # Install Docker Compose
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose

              # Add current user to docker group
              usermod -aG docker ubuntu
              
              # Start Docker service
              systemctl start docker
              systemctl enable docker
              
              # Create Docker log directory
              mkdir -p /var/log/docker-app
              
              # Pull and run Docker container (can be customized via variables)
              docker pull nginx:latest
              docker run -d \
                --name website-app \
                --restart unless-stopped \
                -p 80:80 \
                -v /var/log/docker-app:/var/log/app \
                nginx:latest
              
              # Log initialization complete
              echo "Docker installation and container deployment completed at $(date)" > /var/log/docker-init.log
              EOF
}

# Vault Configuration (Optional)
variable "enable_vault" {
  type    = bool
  default = false
}

variable "vault_address" {
  description = "Vault server address"
  type        = string
  default     = "http://localhost:8200"
}

variable "vault_skip_tls_verify" {
  description = "Skip TLS verification for Vault"
  type        = bool
  default     = true
}

variable "vault_namespace" {
  description = "Vault namespace"
  type        = string
  default     = ""
}

variable "vault_auth_method" {
  description = "Vault authentication method"
  type        = string
  default     = "token"
}

variable "auth_method_path" {
  description = "Vault authentication method path"
  type        = string
  default     = "auth/token"
}

variable "vault_auth_method_path" {
  description = "Vault authentication method path"
  type        = string
  default     = "auth/token"
}

variable "vault_auth_parameters" {
  description = "Vault authentication parameters"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "vault_token" {
  description = "Vault authentication token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "vault_kv_path" {
  description = "Vault KV secrets path"
  type        = string
  default     = "secret/data/app"
}

variable "vault_secrets" {
  description = "Vault secrets configuration"
  type        = map(any)
  default     = {}
}

variable "enable_vault_database_secrets" {
  description = "Enable database secrets in Vault"
  type        = bool
  default     = false
}

variable "vault_db_username" {
  description = "Database username for Vault"
  type        = string
  default     = ""
  sensitive   = true
}

variable "vault_db_password" {
  description = "Database password for Vault"
  type        = string
  default     = ""
  sensitive   = true
}

variable "vault_db_host" {
  description = "Database host for Vault"
  type        = string
  default     = ""
}

variable "vault_db_port" {
  description = "Database port for Vault"
  type        = number
  default     = 5432
}

variable "vault_db_name" {
  description = "Database name for Vault"
  type        = string
  default     = ""
}

variable "enable_vault_app_config" {
  description = "Enable application configuration in Vault"
  type        = bool
  default     = false
}

variable "vault_api_key" {
  description = "API key for Vault app config"
  type        = string
  default     = ""
  sensitive   = true
}

variable "vault_debug_mode" {
  description = "Enable debug mode in Vault app config"
  type        = bool
  default     = false
}

variable "enable_vault_approle" {
  description = "Enable AppRole authentication in Vault"
  type        = bool
  default     = false
}

variable "vault_token_ttl" {
  description = "Token TTL for Vault AppRole"
  type        = string
  default     = "1h"
}

variable "vault_token_max_ttl" {
  description = "Token max TTL for Vault AppRole"
  type        = string
  default     = "24h"
}

variable "vault_secret_id_ttl" {
  description = "Secret ID TTL for Vault AppRole"
  type        = string
  default     = "30m"
}

variable "vault_cidr_list" {
  description = "CIDR list for Vault AppRole"
  type        = list(string)
  default     = []
}
