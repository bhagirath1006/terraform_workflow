# Vault Module Outputs

output "app_secrets_paths" {
  description = "Paths to application secrets in Vault"
  value       = { for key, secret in vault_kv_secret_v2.app_secrets : key => secret.name }
}

output "database_secret_path" {
  description = "Path to database credentials in Vault"
  value       = try(vault_kv_secret_v2.database_credentials[0].name, null)
}

output "app_config_secret_path" {
  description = "Path to application configuration in Vault"
  value       = try(vault_kv_secret_v2.app_config[0].name, null)
}

output "app_policy_name" {
  description = "Name of the application access policy"
  value       = vault_policy.app_policy.name
}

output "approle_role_name" {
  description = "AppRole Role Name"
  value       = try(vault_approle_auth_backend_role.app_role[0].role_name, null)
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