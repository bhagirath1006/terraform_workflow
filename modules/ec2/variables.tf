variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for EC2 instance"
  type        = string
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "user_data_script" {
  description = "User data script for EC2 initialization"
  type        = string
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 8
}

variable "ssh_key_name" {
  description = "AWS EC2 Key Pair name for SSH access"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file (optional, used if key_name doesn't exist)"
  type        = string
  default     = ""
}
