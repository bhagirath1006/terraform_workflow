variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "terraform-app"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# VPC Variables
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "ssh_allowed_cidr" {
  description = "CIDR blocks allowed for SSH access (restrict to your IP)"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

# EC2 Variables
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring and alarms"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 access (generated with ssh-keygen)"
  type        = string
  default     = ""
  sensitive   = true
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
  description = "Skip TLS verification for Vault"
  type        = bool
  default     = false
}