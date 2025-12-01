terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

# --------------------------
# 1. Store App Secrets
# --------------------------
resource "vault_kv_secret_v2" "app_secrets" {
  for_each = var.secrets

  mount     = "secret"
  name      = "app/${each.key}"
  data_json = jsonencode(each.value)
}

# --------------------------
# 2. Store DB Credentials
# --------------------------
resource "vault_kv_secret_v2" "database_credentials" {
  count = var.enable_database_secrets ? 1 : 0

  mount = "secret"
  name  = "db/credentials"
  data_json = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = var.db_host
    port     = var.db_port
    database = var.db_name
  })
}

# --------------------------
# 3. Store App Config
# --------------------------
resource "vault_kv_secret_v2" "app_config" {
  count = var.enable_app_config ? 1 : 0

  mount = "secret"
  name  = "app/config"
  data_json = jsonencode({
    api_key     = var.api_key
    debug_mode  = var.debug_mode
    environment = var.environment
  })
}

# --------------------------
# 4. Create Vault Policy
# --------------------------
resource "vault_policy" "app_policy" {
  name = "${var.environment}-app-policy"

  policy = <<EOH
path "secret/data/app/*" {
  capabilities = ["read", "list"]
}

path "secret/data/db/*" {
  capabilities = ["read", "list"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}
EOH
}

# --------------------------
# 5. Enable AppRole Auth (Optional)
# --------------------------
resource "vault_auth_backend" "approle" {
  count = var.enable_approle ? 1 : 0
  type  = "approle"
  path  = "approle"
}

resource "vault_approle_auth_backend_role" "app_role" {
  count = var.enable_approle ? 1 : 0

  backend        = vault_auth_backend.approle[0].path
  role_name      = "${var.environment}-app-role"
  token_ttl      = var.token_ttl
  token_max_ttl  = var.token_max_ttl
  token_policies = [vault_policy.app_policy.name]
}

resource "vault_approle_auth_backend_role_secret_id" "app_secret" {
  count = var.enable_approle ? 1 : 0

  backend   = vault_auth_backend.approle[0].path
  role_name = vault_approle_auth_backend_role.app_role[0].role_name
}
