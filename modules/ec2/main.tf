# ============================================================================
# IAM Role for EC2 - Docker and CloudWatch Permissions
# ============================================================================
# EC2 service role with permissions for CloudWatch logging
# Replaces SSM Session Manager with SSH key-based access

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

# ============================================================================
# CloudWatch Logs Policy Attachment
# ============================================================================
# Allows EC2 instance to send logs to CloudWatch

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsAgentServerPolicy"
}

# ============================================================================
# IAM Instance Profile
# ============================================================================
# Attaches IAM role to EC2 instance for policy permissions

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# ============================================================================
# EC2 Key Pair - SSH Access
# ============================================================================
# Creates SSH key pair from provided public key file
# If ssh_public_key_path is empty, uses existing key by name

resource "aws_key_pair" "deployer" {
  count              = var.ssh_public_key_path != "" ? 1 : 0
  key_name           = var.ssh_key_name
  public_key         = file(var.ssh_public_key_path)
  tags = {
    Name = "${var.project_name}-key"
  }
}

# ============================================================================
# EC2 Instance - Web Server
# ============================================================================
# Main compute resource for running Docker containers
# SSH access via key pair (no SSM required)
# User data installs Docker on instance startup

resource "aws_instance" "web" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # SSH key for secure access
  key_name = var.ssh_key_name

  # User data for Docker installation only (containers managed by Terraform)
  user_data = base64encode(var.user_data_script)

  # Storage configuration
  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # Enable detailed CloudWatch monitoring
  monitoring = true

  tags = {
    Name = "${var.project_name}-web-server"
  }

  depends_on = [aws_iam_instance_profile.ec2_profile]
}

