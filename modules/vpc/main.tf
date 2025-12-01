# ============================================================================
# VPC Module - Virtual Private Cloud Configuration
# ============================================================================
# Creates VPC, subnets, routing, and security groups for web traffic

# ============================================================================
# VPC Resource
# ============================================================================
# Main Virtual Private Cloud with DNS enabled

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# ============================================================================
# Internet Gateway
# ============================================================================
# Enables communication between VPC and the internet

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# ============================================================================
# Public Subnet
# ============================================================================
# Subnet where EC2 instance will be launched with automatic public IP

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# ============================================================================
# Route Table - Public Subnet
# ============================================================================
# Routes all traffic to internet gateway (routes to 0.0.0.0/0 go to IGW)

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# ============================================================================
# Route Table Association
# ============================================================================
# Associates public subnet with public route table

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ============================================================================
# Security Group - Web Traffic
# ============================================================================
# Firewall rules: allows HTTP (80), HTTPS (443), SSH (22), all outbound

resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web traffic (HTTP, HTTPS, SSH)"
  vpc_id      = aws_vpc.main.id

  # ============================================================================
  # Ingress Rules - Inbound Traffic
  # ============================================================================
  
  # Allow HTTP traffic on port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  # Allow HTTPS traffic on port 443
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }

  # Allow SSH traffic on port 22 (from specific CIDRs for security)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
    description = "Allow SSH from specified CIDRs"
  }

  # ============================================================================
  # Egress Rules - Outbound Traffic
  # ============================================================================
  
  # Allow all outbound traffic (required for Docker pulls, updates, etc.)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}
