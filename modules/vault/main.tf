# Vault Provider Configuration
terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

provider "vault" {
  address         = var.vault_address
  skip_tls_verify = var.skip_tls_verify
  
  auth_login {
    path      = var.auth_method_path
    method    = var.auth_method
    parameters = var.auth_parameters
  }
}

# Create KV v2 Secrets Engine
resource "vault_generic_secret" "app_secrets" {
  for_each = var.secrets

  path            = "${var.kv_path}/${each.key}"
  ignore_absence  = true
  disable_read    = false

  data_json = jsonencode(each.value)

  lifecycle {
    ignore_changes = [data_json]
  }
}

# Create Database Credentials Secret
resource "vault_generic_secret" "database_credentials" {
  count = var.enable_database_secrets ? 1 : 0

  path            = "${var.kv_path}/database"
  ignore_absence  = true
  disable_read    = false

  data_json = jsonencode({
    username     = var.db_username
    password     = var.db_password
    host         = var.db_host
    port         = var.db_port
    database     = var.db_name
  })
}

# Create Application Configuration Secret
resource "vault_generic_secret" "app_config" {
  count = var.enable_app_config ? 1 : 0

  path            = "${var.kv_path}/app-config"
  ignore_absence  = true
  disable_read    = false

  data_json = jsonencode({
    environment  = var.environment
    api_key      = var.api_key
    debug_mode   = var.debug_mode
  })
}

# Policy for Application Access
resource "vault_policy" "app_policy" {
  name = "${var.environment}-app-policy"

  policy = <<EOH
path "${var.kv_path}/*" {
  capabilities = ["read", "list"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}
EOH
}

# AppRole Authentication (for automated access)
resource "vault_approle_auth_backend_role" "app_role" {
  count = var.enable_approle ? 1 : 0

  backend            = vault_auth_method.approle[0].path
  role_name          = "${var.environment}-app-role"
  token_num_uses     = 0
  token_ttl          = var.token_ttl
  token_max_ttl      = var.token_max_ttl
  secret_id_num_uses = 0
  secret_id_ttl      = var.secret_id_ttl
  policies           = [vault_policy.app_policy.name]
}

# AppRole Auth Backend
resource "vault_auth_method" "approle" {
  count = var.enable_approle ? 1 : 0
  type  = "approle"
  path  = "approle"
}

# Role ID
resource "vault_approle_auth_backend_role_secret_id" "app_secret" {
  count           = var.enable_approle ? 1 : 0
  backend         = vault_auth_method.approle[0].path
  role_name       = vault_approle_auth_backend_role.app_role[0].role_name
  cidr_list       = var.cidr_list
  metadata        = jsonencode({ created_by = "terraform" })
}

# Output RoleID for application
data "vault_approle_auth_backend_role_id" "app_role_id" {
  count      = var.enable_approle ? 1 : 0
  backend    = vault_auth_method.approle[0].path
  role_name  = vault_approle_auth_backend_role.app_role[0].role_name
  depends_on = [vault_approle_auth_backend_role.app_role]
}
