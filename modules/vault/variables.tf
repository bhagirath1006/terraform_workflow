# Vault Module Variables

variable "vault_address" {
  description = "Address of the Vault server"
  type        = string
  default     = "http://vault.example.com:8200"
}

variable "vault_token" {
  description = "Vault authentication token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "skip_tls_verify" {
  description = "Skip TLS verification for Vault"
  type        = bool
  default     = false
}

variable "auth_method" {
  description = "Authentication method for Vault (e.g., token, approle, ldap)"
  type        = string
  default     = "token"
}

variable "auth_method_path" {
  description = "Path for the authentication method"
  type        = string
  default     = "token"
}

variable "auth_parameters" {
  description = "Parameters for Vault authentication"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "kv_path" {
  description = "Base path for KV secrets"
  type        = string
  default     = "secret/data/app"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "secrets" {
  description = "Map of secrets to store in Vault"
  type        = map(any)
  default     = {}
}

variable "enable_database_secrets" {
  description = "Enable database credentials in Vault"
  type        = bool
  default     = false
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_host" {
  description = "Database host"
  type        = string
  default     = ""
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = ""
}

variable "enable_app_config" {
  description = "Enable application configuration in Vault"
  type        = bool
  default     = false
}

variable "api_key" {
  description = "API key for the application"
  type        = string
  default     = ""
  sensitive   = true
}

variable "debug_mode" {
  description = "Enable debug mode"
  type        = bool
  default     = false
}

variable "enable_approle" {
  description = "Enable AppRole authentication"
  type        = bool
  default     = false
}

variable "token_ttl" {
  description = "Token TTL"
  type        = string
  default     = "1h"
}

variable "token_max_ttl" {
  description = "Token max TTL"
  type        = string
  default     = "24h"
}

variable "secret_id_ttl" {
  description = "SecretID TTL"
  type        = string
  default     = "30m"
}

variable "cidr_list" {
  description = "CIDR blocks allowed to use the AppRole"
  type        = list(string)
  default     = []
}
