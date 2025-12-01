variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

# Vault Configuration
variable "vault_addr" {
  description = "Vault server address"
  type        = string
  sensitive   = true
}

variable "vault_token" {
  description = "Vault authentication token"
  type        = string
  sensitive   = true
}

variable "vault_skip_tls_verify" {
  description = "Skip TLS verification for Vault (not recommended for production)"
  type        = bool
  default     = false
}

# Secret Variables
variable "docker_username" {
  description = "Docker registry username"
  type        = string
  sensitive   = true
}

variable "docker_password" {
  description = "Docker registry password"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "Database host"
  type        = string
  default     = "localhost"
}

variable "api_key" {
  description = "API key"
  type        = string
  sensitive   = true
}

variable "create_db_secret" {
  description = "Create database secret"
  type        = bool
  default     = true
}
