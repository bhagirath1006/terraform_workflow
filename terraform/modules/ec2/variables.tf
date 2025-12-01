variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "security_group_id" {
  description = "Application security group ID"
  type        = string
}

variable "ssh_security_group_id" {
  description = "SSH security group ID"
  type        = string
  default     = ""
}

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

variable "docker_registry_server" {
  description = "Docker registry server"
  type        = string
  default     = "docker.io"
  sensitive   = true
}

variable "docker_image_uri" {
  description = "Docker image URI"
  type        = string
  default     = "nginx:latest"
  sensitive   = true
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 80
}

variable "host_port" {
  description = "Host port to map to container"
  type        = number
  default     = 80
}

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring and alarms"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention days"
  type        = number
  default     = 7
}
