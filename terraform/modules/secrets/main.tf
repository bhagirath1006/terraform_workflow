terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

# Configure Vault Provider - this validates connection to Vault
provider "vault" {
  address         = var.vault_addr
  skip_tls_verify = var.vault_skip_tls_verify
  token           = var.vault_token
}

# Read existing Vault secret to verify connection
data "vault_generic_secret" "app_secrets" {
  path = "secret/data/${var.environment}/app"
}

# Output secret path for reference
output "app_secrets_path" {
  value       = "secret/data/${var.environment}/app"
  description = "Path to application secrets in Vault"
}

output "vault_connected" {
  value       = true
  description = "Vault provider successfully connected"
}
