terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

# ============================================================================
# AWS Provider Configuration

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

# Vault Provider Configuration

provider "vault" {
  address         = var.vault_address
  skip_tls_verify = var.vault_skip_tls_verify
  token           = var.vault_token != "" ? var.vault_token : null
}

