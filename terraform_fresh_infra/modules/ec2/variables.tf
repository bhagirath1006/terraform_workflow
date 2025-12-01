variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID where EC2 will be deployed"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for EC2"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID"
  type        = string
}
