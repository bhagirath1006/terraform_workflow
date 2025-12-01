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

# Create KV v2 secret engine path for application secrets
resource "vault_generic_secret" "app_secrets" {
  path = "secret/data/${var.environment}/app"

  data_json = jsonencode({
    docker_username = var.docker_username
    docker_password = var.docker_password
    db_username     = var.db_username
    db_password     = var.db_password
    api_key         = var.api_key
  })
}

# Create KV v2 secret engine path for database credentials
resource "vault_generic_secret" "database_credentials" {
  count = var.create_db_secret ? 1 : 0
  path  = "secret/data/${var.environment}/database"

  data_json = jsonencode({
    username = var.db_username
    password = var.db_password
    engine   = "postgres"
    port     = 5432
    host     = var.db_host
  })
}

# Create authentication token policy for EC2 instances
resource "vault_policy" "ec2_policy" {
  name = "${var.project_name}-ec2-policy-${var.environment}"

  policy = <<EOH
path "secret/data/${var.environment}/*" {
  capabilities = ["read", "list"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}
EOH
}

# Create AppRole for EC2 instances to authenticate to Vault
resource "vault_approle_auth_backend_role" "ec2_role" {
  backend            = vault_auth_backend.approle.path
  role_name          = "${var.project_name}-ec2-${var.environment}"
  token_num_uses     = 0
  token_ttl          = 3600
  token_max_ttl      = 86400
  bind_secret_id     = true
  secret_id_num_uses = 0
}

# Enable AppRole authentication
resource "vault_auth_backend" "approle" {
  type = "approle"
  path = "approle"
}

# Get the Role ID
resource "vault_approle_auth_backend_role_secret_id" "ec2_secret" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.ec2_role.role_name
}

# Attach policy to AppRole
resource "vault_generic_secret" "ec2_approle_policy" {
  path = "approle/role/${vault_approle_auth_backend_role.ec2_role.role_name}/policies"

  data_json = jsonencode({
    policies = vault_policy.ec2_policy.name
  })
}
