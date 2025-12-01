terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

# ============================================================================
# AWS Provider Configuration
# ============================================================================
# Configures AWS region and applies default tags to all resources

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ============================================================================
# Docker Provider Configuration
# ============================================================================
# Connects to Docker daemon on EC2 instance for container management

provider "docker" {
  host = var.docker_host
}

# ============================================================================
# Vault Provider Configuration
# ============================================================================
# Configured in vault module (optional, only enabled when var.enable_vault = true)
