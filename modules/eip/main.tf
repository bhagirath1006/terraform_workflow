terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# EIP Module - Elastic IP Management
# Data Source - Search for Existing Elastic IP
# ============================================================================
# Looks for EIP tagged with project name (only when create_new_eip = false)

data "aws_eip" "existing" {
  count = var.create_new_eip ? 0 : 1

  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-eip"]
  }
}

# ============================================================================
# Elastic IP Resource
# Creates new fixed public IP address associated with EC2 instance

resource "aws_eip" "web" {
  instance = var.instance_id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }
}

# ============================================================================
# Conditional EIP Logic
# Uses existing EIP if found, otherwise creates new one

locals {
  # Select EIP ID: existing or newly created
  eip_id = var.create_new_eip ? aws_eip.web.id : (length(data.aws_eip.existing) > 0 ? data.aws_eip.existing[0].id : aws_eip.web.id)

  # Select EIP Address: existing or newly created
  eip_address = var.create_new_eip ? aws_eip.web.public_ip : (length(data.aws_eip.existing) > 0 ? data.aws_eip.existing[0].public_ip : aws_eip.web.public_ip)

  # Select EIP Association ID: existing or newly created
  eip_association_id = var.create_new_eip ? aws_eip.web.association_id : (length(data.aws_eip.existing) > 0 ? data.aws_eip.existing[0].association_id : aws_eip.web.association_id)
}
