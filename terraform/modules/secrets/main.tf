terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

# Configure Vault Provider
provider "vault" {
  address         = var.vault_addr
  skip_tls_verify = var.vault_skip_tls_verify
  token           = var.vault_token
}

# Output secret path for reference (data source removed to allow plan without Vault running)
output "app_secrets_path" {
  value       = "secret/data/${var.environment}/app"
  description = "Path to application secrets in Vault"
}
