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
