terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Public"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${var.project_name}-private-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Private"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Restrict default security group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-default-sg"
    Environment = var.environment
  }
}

# SSH Security Group - Attached to EC2 instance in ec2 module
# checkov:skip=CKV2_AWS_5:Security group is attached to EC2 in separate module
resource "aws_security_group" "ssh" {
  name        = "${var.project_name}-ssh-sg"
  description = "Security group for SSH access"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-ssh-sg"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.ssh.id
  description       = "SSH from allowed CIDR"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = "10.0.0.0/8"

  tags = {
    Name = "ssh-ingress"
  }
}

resource "aws_vpc_security_group_egress_rule" "ssh_https" {
  security_group_id = aws_security_group.ssh.id
  description       = "Allow outbound HTTPS"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "ssh-https-egress"
  }
}

resource "aws_vpc_security_group_egress_rule" "ssh_dns" {
  security_group_id = aws_security_group.ssh.id
  description       = "Allow outbound DNS"
  from_port         = 53
  to_port           = 53
  ip_protocol       = "udp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "ssh-dns-egress"
  }
}

# Application Security Group - Attached to EC2 instance in ec2 module
# checkov:skip=CKV2_AWS_5:Security group is attached to EC2 in separate module
resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for application HTTP/HTTPS traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-app-sg"
    Environment = var.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_https" {
  security_group_id = aws_security_group.app.id
  description       = "HTTPS from internet"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "https-ingress"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_http_restricted" {
  security_group_id = aws_security_group.app.id
  description       = "HTTP restricted - only from internal or specific sources"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "10.0.0.0/8"

  tags = {
    Name = "http-ingress-restricted"
  }
}

resource "aws_vpc_security_group_egress_rule" "app_https_out" {
  security_group_id = aws_security_group.app.id
  description       = "Allow outbound HTTPS"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "https-egress"
  }
}

resource "aws_vpc_security_group_egress_rule" "app_http_out" {
  security_group_id = aws_security_group.app.id
  description       = "Allow outbound HTTP"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "http-egress"
  }
}

resource "aws_vpc_security_group_egress_rule" "app_dns" {
  security_group_id = aws_security_group.app.id
  description       = "Allow outbound DNS"
  from_port         = 53
  to_port           = 53
  ip_protocol       = "udp"
  cidr_ipv4         = "0.0.0.0/0"

  tags = {
    Name = "dns-egress"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Enable VPC Flow Logs
resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-flow-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flowlogs/${var.project_name}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.vpc_logs.arn

  tags = {
    Name        = "${var.project_name}-vpc-flow-logs"
    Environment = var.environment
  }
}

# KMS key for VPC Flow Logs encryption
resource "aws_kms_key" "vpc_logs" {
  description             = "KMS key for encrypting VPC Flow Logs"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_vpc_logs.json

  tags = {
    Name        = "${var.project_name}-vpc-logs-key"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "vpc_logs" {
  name          = "alias/${var.project_name}-vpc-logs"
  target_key_id = aws_kms_key.vpc_logs.key_id
}

data "aws_iam_policy_document" "kms_vpc_logs" {
  version = "2012-10-17"

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow VPC Flow Logs"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com", "logs.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey"
    ]

    resources = ["*"]

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  name = "${var.project_name}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-vpc-flow-logs-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "${var.project_name}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CreateLogGroup"
        Action = ["logs:CreateLogGroup"]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/flowlogs/${var.project_name}"
        ]
      },
      {
        Sid = "CreateLogStreamAndPutLogEvents"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc/flowlogs/${var.project_name}:*"
        ]
      }
    ]
  })
}
