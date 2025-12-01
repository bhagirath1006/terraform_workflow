variable "instance_id" {
  description = "EC2 instance ID to associate with EIP"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "create_new_eip" {
  description = "Whether to create a new EIP or use existing"
  type        = bool
  default     = true
}

variable "depends_on" {
  description = "Dependencies for the module"
  type        = list(any)
  default     = []
}
