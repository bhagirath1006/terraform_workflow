# Vault Module Outputs

output "app_secrets_path" {
  description = "Path to application secrets in Vault"
  value       = vault_generic_secret.app_secrets
}

output "database_secret_path" {
  description = "Path to database credentials in Vault"
  value       = var.enable_database_secrets ? "${var.kv_path}/database" : null
}

output "app_config_secret_path" {
  description = "Path to application configuration in Vault"
  value       = var.enable_app_config ? "${var.kv_path}/app-config" : null
}

output "app_policy_name" {
  description = "Name of the application access policy"
  value       = vault_policy.app_policy.name
}

output "approle_role_id" {
  description = "AppRole Role ID for authentication"
  value       = try(data.vault_approle_auth_backend_role_id.app_role_id[0].role_id, null)
  sensitive   = true
}

output "approle_secret_id" {
  description = "AppRole Secret ID for authentication"
  value       = try(vault_approle_auth_backend_role_secret_id.app_secret[0].secret_id, null)
  sensitive   = true
}

output "vault_address" {
  description = "Vault server address"
  value       = var.vault_address
}

output "kv_path" {
  description = "Base path for KV secrets"
  value       = var.kv_path
}
