output "app_secrets_path" {
  description = "Path to application secrets in Vault"
  value       = vault_generic_secret.app_secrets.path
}

output "database_secrets_path" {
  description = "Path to database secrets in Vault"
  value       = try(vault_generic_secret.database_credentials[0].path, null)
}

output "ec2_role_id" {
  description = "AppRole ID for EC2 instances"
  value       = vault_approle_auth_backend_role.ec2_role.role_id
  sensitive   = true
}

output "ec2_secret_id" {
  description = "AppRole Secret ID for EC2 instances"
  value       = vault_approle_auth_backend_role_secret_id.ec2_secret.secret_id
  sensitive   = true
}

output "vault_addr" {
  description = "Vault server address"
  value       = var.vault_addr
}

output "ec2_policy_name" {
  description = "Vault policy name for EC2 instances"
  value       = vault_policy.ec2_policy.name
}
