# ============================================================================
# EIP Module - Elastic IP Management
# ============================================================================
# Creates or reuses fixed public IP address for EC2 instance
# Supports conditional logic: create new or search for existing

# ============================================================================
# Data Source - Search for Existing Elastic IP
# ============================================================================
# Looks for EIP tagged with project name (only when create_new_eip = false)

data "aws_eip" "existing" {
  count = var.create_new_eip ? 0 : 1
  
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-eip"]
  }
  
  depends_on = [var.depends_on]
}

# ============================================================================
# Elastic IP Resource
# ============================================================================
# Creates new fixed public IP address associated with EC2 instance
# Can be associated with a specific instance via instance parameter

resource "aws_eip" "web" {
  instance = var.instance_id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip"
  }

  depends_on = var.depends_on
}

# ============================================================================
# Conditional EIP Logic
# ============================================================================
# Uses existing EIP if found, otherwise creates new one
# Outputs EIP address for access to application

locals {
  # Select EIP ID: existing or newly created
  eip_id            = var.create_new_eip ? aws_eip.web.id : (length(data.aws_eip.existing) > 0 ? data.aws_eip.existing[0].id : aws_eip.web.id)
  
  # Select EIP Address: existing or newly created
  eip_address       = var.create_new_eip ? aws_eip.web.public_ip : (length(data.aws_eip.existing) > 0 ? data.aws_eip.existing[0].public_ip : aws_eip.web.public_ip)
  
  # Select EIP Association ID: existing or newly created
  eip_association_id = var.create_new_eip ? aws_eip.web.association_id : (length(data.aws_eip.existing) > 0 ? data.aws_eip.existing[0].association_id : aws_eip.web.association_id)
}
