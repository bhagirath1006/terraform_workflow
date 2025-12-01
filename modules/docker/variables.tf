variable "project_name" {
  description = "Project name"
  type        = string
}

variable "docker_image" {
  description = "Docker image to run"
  type        = string
  default     = "nginx:latest"
}

variable "container_name" {
  description = "Docker container name"
  type        = string
  default     = "app-container"
}

variable "container_port" {
  description = "Container internal port"
  type        = number
  default     = 80
}

variable "host_port" {
  description = "Host port to map"
  type        = number
  default     = 80
}

variable "restart_policy" {
  description = "Container restart policy"
  type        = string
  default     = "unless-stopped"
}

