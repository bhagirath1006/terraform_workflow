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
  default     = ["0.0.0.0/0"]  # Change this to your IP for security
}

# EC2 Configuration
variable "ami_id" {
  description = "AMI ID (Ubuntu 22.04 LTS)"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"  # Replace with your region's Ubuntu AMI
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"  # Free tier eligible
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

# EC2 User Data - Docker Installation Only (Containers managed by Terraform)
variable "user_data_script" {
  description = "User data script for EC2 initialization (Docker installation only)"
  type        = string
  default     = <<-EOF
              #!/bin/bash
              set -e
              
              # Update system
              apt-get update
              apt-get upgrade -y
              
              # Install Docker
              apt-get install -y docker.io curl wget

              # Install Docker Compose (optional)
              curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
              chmod +x /usr/local/bin/docker-compose

              # Add current user to docker group
              usermod -aG docker ubuntu
              
              # Start Docker service
              systemctl start docker
              systemctl enable docker
              
              # Create Docker log directory
              mkdir -p /var/log/docker-app
              
              # Log initialization complete
              echo "Docker installation completed at $(date)" > /var/log/docker-init.log
              echo "Containers will be managed by Terraform" >> /var/log/docker-init.log
              EOF
}

# Vault Configuration (Optional)
variable "enable_vault" {
  type    = bool
  default = false
}

variable "vault_address" {
  type    = string
  default = "http://localhost:8200"
}

variable "vault_skip_tls_verify" {
  type    = bool
  default = true
}

variable "vault_token" {
  type      = string
  default   = ""
  sensitive = true
}

variable "vault_auth_method" {
  type    = string
  default = "token"
}

variable "vault_secrets" {
  type      = map(any)
  default   = {}
  sensitive = true
}

# Docker Provider Configuration
variable "docker_host" {
  description = "Docker daemon host"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "enable_docker_provider" {
  description = "Enable Docker provider for container management"
  type        = bool
  default     = true
}

# Docker Container Configuration
variable "docker_image" {
  description = "Docker image to deploy"
  type        = string
  default     = "nginx:latest"
}

variable "docker_container_name" {
  description = "Docker container name"
  type        = string
  default     = "website-app"
}

variable "docker_container_port" {
  description = "Container internal port"
  type        = number
  default     = 80
}

variable "docker_host_port" {
  description = "Host port mapping"
  type        = number
  default     = 80
}

variable "docker_restart_policy" {
  description = "Docker restart policy"
  type        = string
  default     = "unless-stopped"
}

