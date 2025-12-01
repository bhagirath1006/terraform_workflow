# Docker Website Deployment with Terraform & HashiCorp Vault

A complete, production-ready Terraform project using **module-based architecture** to deploy a website in a Docker container on AWS EC2 instances with a fixed Elastic IP and integrated HashiCorp Vault for secret management.

## Project Overview

This project demonstrates:
- **Modular Terraform architecture** with separate modules for VPC, EC2, EIP, Docker, and Vault
- **Parameterized configuration** using `variables.tf` and `terraform.tfvars`
- **Conditional Elastic IP logic** - automatically checks if EIP exists before creating a new one
- **Docker deployment** on EC2 instances
- **HashiCorp Vault integration** for secure secret management
- **Complete cleanup workflow** with Terraform state removal
- **Production-ready practices** including IAM roles, security groups, and proper tagging

## Project Structure

```
terraform_workflow/
├── modules/
│   ├── vpc/                          # VPC, subnets, security groups
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ec2/                          # EC2 instances and IAM roles
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── eip/                          # Elastic IP with conditional logic
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── docker/                       # Docker configuration templates
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── vault/                        # HashiCorp Vault integration
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── scripts/
│   ├── deploy.ps1                    # PowerShell deployment script
│   ├── deploy.sh                     # Bash deployment script
│   ├── cleanup.ps1                   # PowerShell cleanup script
│   └── cleanup.sh                    # Bash cleanup script
├── provider.tf                       # AWS and Vault provider configuration
├── main.tf                           # Root module orchestration
├── variables.tf                      # Root variables and defaults
├── outputs.tf                        # Root outputs
├── terraform.tfvars                  # Variable values
├── VAULT_SETUP.md                    # HashiCorp Vault configuration guide
└── README.md                         # This file
```

## Features

### 1. Module-Based Architecture
- **VPC Module**: Creates VPC, subnets, internet gateway, route tables, and security groups
- **EC2 Module**: Provisions EC2 instances with IAM roles and user data scripts
- **EIP Module**: Manages Elastic IPs with intelligent logic to check for existing EIPs
- **Docker Module**: Template variables for Docker configuration (extensible)
- **Vault Module**: Integrates HashiCorp Vault for secure secret storage and management

### 2. Parameterized Configuration
All infrastructure parameters are configurable via `terraform.tfvars`:
- AWS region and availability zone
- VPC CIDR blocks and subnet ranges
- EC2 instance type and root volume size
- Docker image and port mappings
- SSH access CIDR blocks
- Elastic IP creation behavior
- Vault server address and authentication credentials
- Secret storage and retrieval configurations

### 3. Elastic IP Management
The EIP module includes conditional logic:
- **Option 1**: Create a new Elastic IP for the instance
- **Option 2**: Search for an existing Elastic IP tagged with your project name
- Set `create_new_eip = true/false` in `terraform.tfvars` to control this behavior

### 4. Docker Deployment
The user data script automatically:
1. Updates the system
2. Installs Docker
3. Pulls and runs a Docker container (default: nginx)
4. Configures Docker to start on reboot
5. Logs deployment status

### 5. HashiCorp Vault Integration
Secure secret management with:
- **KV v2 Secrets Storage**: Store application secrets, API keys, credentials
- **Database Credentials**: Manage database connection secrets
- **AppRole Authentication**: Automated, non-interactive authentication for applications
- **Access Policies**: Fine-grained access control to secrets
- **Audit Trail**: Complete logging of secret access
- **Conditional Deployment**: Enable/disable Vault integration with `enable_vault = true/false`

For detailed Vault setup and usage, see [VAULT_SETUP.md](./VAULT_SETUP.md)

### 6. Cleanup Workflow
- **Terraform destroy**: Removes all AWS resources
- **State removal**: Deletes `.tfstate` and `.terraform` files
- **Complete cleanup**: Leaves workspace in fresh state for re-deployment

## Prerequisites

- **Terraform** >= 1.0 (download from [terraform.io](https://www.terraform.io/downloads))
- **AWS Account** with appropriate IAM permissions
- **AWS CLI** configured with credentials (optional, but recommended)
- **PowerShell 5.1+** (Windows) or **Bash** (Linux/macOS)
- **HashiCorp Vault** (optional, for secret management)

### Required AWS Permissions

The IAM user/role needs permissions to:
- Create/manage VPC, subnets, security groups
- Create/manage EC2 instances
- Create/manage Elastic IPs
- Create/manage IAM roles and instance profiles
- Manage CloudWatch monitoring

### Vault Setup (Optional)

If using Vault integration:
1. Have a Vault server running (local dev or remote)
2. Generate an authentication token
3. Create KV v2 secrets engine at `secret/data/app`
4. Update `terraform.tfvars` with Vault address and token

See [VAULT_SETUP.md](./VAULT_SETUP.md) for detailed instructions.

## Quick Start

### 1. Clone or Download This Project

```bash
cd c:\Users\123\terraform_workflow
```

### 2. Configure Variables (Optional)

Edit `terraform.tfvars` to customize infrastructure and Vault settings:
```hcl
# Infrastructure
aws_region     = "us-east-1"
project_name   = "my-docker-app"
ami_id         = "ami-0c55b159cbfafe1f0"
instance_type  = "t2.micro"
create_new_eip = true

# Vault Configuration
enable_vault      = true
vault_address     = "http://localhost:8200"
vault_token       = "s.xxxxxxxx..."
vault_secrets = {
  "docker-credentials" = {
    username = "admin"
    password = "secure-password"
  }
}
```

### 3. Deploy Infrastructure

**On Windows (PowerShell):**
```powershell
.\scripts\deploy.ps1
```

**On Linux/macOS (Bash):**
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### 4. View Deployment Outputs

After deployment completes, view the website URL and Vault integration status:
```bash
terraform output elastic_ip_address
terraform output website_url
terraform output vault_integration_status
```

### 5. Access Your Website

Open the elastic IP address in your browser:
```
http://<ELASTIC_IP>
```

### 6. Access Vault Secrets (if enabled)

```bash
terraform output vault_kv_path
terraform output vault_app_policy_name
```

## Configuration Guide

## Customizing Docker Containers

### Configure Docker via Terraform

Docker containers are now fully managed by Terraform. Update `terraform.tfvars` to customize:

```hcl
# Docker image to deploy
docker_image           = "nginx:latest"
docker_container_name  = "website-app"

# Port mappings
docker_port_mappings = [
  {
    internal = 80
    external = 80
    protocol = "tcp"
  }
]

# Environment variables
docker_environment_variables = {
  "NODE_ENV"  = "production"
  "DEBUG"     = "false"
}

# Resource limits
docker_memory_limit = 512   # MB
docker_cpu_limit    = 0.5   # CPU fraction

# Health checks
docker_enable_healthcheck = true
```

For detailed Docker configuration, see [DOCKER_CONFIG.md](./DOCKER_CONFIG.md)

### Using an Existing Elastic IP

Set `create_new_eip = false` in `terraform.tfvars`. Terraform will search for an existing EIP tagged with your project name:

```hcl
create_new_eip = false
```

### Restricting SSH Access

Update `allowed_ssh_cidrs` in `terraform.tfvars` with your IP address:

```hcl
allowed_ssh_cidrs = ["203.0.113.0/32"]  # Replace with your IP
```

## Usage Commands

### Initialize Terraform

```bash
terraform init
```

### Validate Configuration

```bash
terraform validate
```

### Format Code

```bash
terraform fmt -recursive
```

### Plan Deployment

```bash
terraform plan
terraform plan -out=tfplan          # Save plan to file
terraform plan -var-file=prod.tfvars # Use different vars file
```

### Apply Configuration

```bash
terraform apply
terraform apply tfplan              # Apply saved plan
terraform apply -auto-approve       # Automatic approval (use with caution)
```

### View Outputs

```bash
terraform output
terraform output elastic_ip_address
terraform output website_url
terraform output docker_container_status
terraform output deployment_summary
```

### Show State

```bash
terraform show
terraform state list
terraform state show module.docker
```

### Destroy Resources

```bash
terraform destroy
terraform destroy -auto-approve     # Without confirmation
```

### Full Cleanup (With State Removal)

**On Windows (PowerShell):**
```powershell
.\scripts\cleanup.ps1
```

**On Linux/macOS (Bash):**
```bash
./scripts/cleanup.sh
```

## Module Details

### VPC Module (`modules/vpc/`)
**Creates:**
- VPC with customizable CIDR
- Public subnet with auto-assign public IP
- Internet Gateway
- Route table with public route
- Security group for HTTP/HTTPS/SSH traffic

**Variables:**
- `vpc_cidr`: VPC CIDR block
- `public_subnet_cidr`: Subnet CIDR block
- `availability_zone`: AZ for resources
- `allowed_ssh_cidrs`: CIDR blocks for SSH

**Outputs:**
- `vpc_id`: VPC identifier
- `public_subnet_id`: Subnet identifier
- `security_group_id`: Security group ID
- `internet_gateway_id`: IGW identifier

### EC2 Module (`modules/ec2/`)
**Creates:**
- EC2 instance with user data
- IAM role and instance profile
- EBS root volume configuration

**Variables:**
- `ami_id`: Amazon Machine Image ID
- `instance_type`: Instance type (t2.micro, t2.small, etc.)
- `subnet_id`: Subnet for instance placement
- `security_group_id`: Security group
- `user_data_script`: Initialization script
- `root_volume_size`: Root volume size in GB

**Outputs:**
- `instance_id`: EC2 instance ID
- `private_ip`: Private IP address
- `public_ip`: Public IP address (before EIP)
- `instance_arn`: Instance ARN

### EIP Module (`modules/eip/`)
**Creates or Finds:**
- Elastic IP address
- Associates EIP with EC2 instance
- Checks for existing EIP if `create_new_eip = false`

**Variables:**
- `instance_id`: EC2 instance to associate with
- `project_name`: Project name for tagging and searching
- `create_new_eip`: Boolean to create new or find existing

**Outputs:**
- `eip_id`: Elastic IP ID
- `eip_address`: Elastic IP address
- `eip_association_id`: Association ID
- `is_new_eip`: Whether newly created

### Docker Module (`modules/docker/`)
**Provides:**
- Template variables for Docker configuration
- Extensible for future Docker management

**Variables:**
- `docker_image`: Docker image URI
- `container_port`: Container port
- `host_port`: Host port mapping

## Troubleshooting

### Terraform Init Fails
**Issue**: `No valid credential sources found`
- **Solution**: Configure AWS credentials:
  ```bash
  aws configure
  # or set environment variables
  set AWS_ACCESS_KEY_ID=...
  set AWS_SECRET_ACCESS_KEY=...
  ```

### Invalid AMI ID
**Issue**: `InvalidAMIID.Malformed` or `InvalidAMIID.NotFound`
- **Solution**: Update `ami_id` in `terraform.tfvars` for your region:
  - us-east-1: ami-0c55b159cbfafe1f0
  - us-west-2: ami-0a8e758f5e873d1c1
  - eu-west-1: ami-0d2a4a5d69e46ea0b
  - (Search for Ubuntu 22.04 LTS in your region)

### EC2 Instance Not Starting Docker
**Issue**: Container not running after deployment
- **Solution**: 
  1. SSH into instance: `ssh -i your-key.pem ubuntu@<ELASTIC_IP>`
  2. Check logs: `cloud-init-output.log` and `docker-deployment.log`
  3. Check Docker: `docker ps`, `docker logs container-name`

### EIP Association Fails
**Issue**: Cannot associate existing EIP
- **Solution**: Ensure EIP is not already associated with another instance
  - Check AWS console or run: `aws ec2 describe-addresses --region us-east-1`

### Port Already in Use
**Issue**: Terraform fails with port conflict
- **Solution**: Change `host_port` in `terraform.tfvars` or terminate conflicting container

### Vault Connection Issues
**Error**: Connection refused to Vault
- **Solution**: 
  1. Verify Vault server is running: `vault status`
  2. Check firewall/security groups allow Vault port
  3. Verify `vault_address` in `terraform.tfvars` is correct
  4. Test connectivity: `curl http://vault-address:8200/v1/sys/health`

## HashiCorp Vault Integration

### Overview

This project includes full HashiCorp Vault support for managing secrets securely. Vault provides:

- **Centralized Secret Storage**: Store API keys, database credentials, and other sensitive data
- **Dynamic Credentials**: Generate temporary credentials for applications
- **Audit Logging**: Track all secret access for compliance
- **Access Control**: Fine-grained policies for who can access what
- **Encryption**: All secrets encrypted at rest

### Quick Vault Setup

1. **Start Vault locally (Development)**:
   ```powershell
   # Install Vault from https://www.vaultproject.io/downloads
   vault server -dev
   ```

2. **Enable KV Secrets Engine**:
   ```bash
   export VAULT_ADDR="http://127.0.0.1:8200"
   export VAULT_TOKEN="s.xxxxxxxx"  # From vault output
   vault secrets enable -version=2 -path=secret kv
   ```

3. **Configure terraform.tfvars**:
   ```hcl
   enable_vault          = true
   vault_address         = "http://localhost:8200"
   vault_token           = "s.xxxxxxxx"
   
   vault_secrets = {
     "docker-credentials" = {
       username = "admin"
       password = "secure-password"
     }
   }
   ```

4. **Deploy with Vault**:
   ```powershell
   .\scripts\deploy.ps1
   ```

### Accessing Secrets from EC2

```bash
# SSH into EC2
ssh -i your-key.pem ubuntu@<ELASTIC_IP>

# Install Vault CLI
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vault

# Authenticate to Vault
export VAULT_ADDR="http://vault.example.com:8200"
vault login -method=token token=s.xxxxxxxx

# Read secrets
vault kv get secret/data/app/docker-credentials
```

### Vault Features in This Project

- **Docker Credentials**: Store Docker registry credentials
- **Database Secrets**: Manage database connection strings
- **API Keys**: Store external API keys and tokens
- **AppRole Auth**: Automated authentication for applications
- **Access Policies**: Role-based access control

For comprehensive Vault documentation, see [VAULT_SETUP.md](./VAULT_SETUP.md)

## Advanced Configuration

### Using Remote State (S3 Backend)

Uncomment the backend configuration in `provider.tf`:
```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "terraform-workflow/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-locks"
}
```

Then run:
```bash
terraform init
```

### Multiple Environments

Create separate `tfvars` files:
```bash
terraform apply -var-file=dev.tfvars
terraform apply -var-file=prod.tfvars
```

### Custom Domain

After deployment:
1. Update Route53 DNS records to point to the Elastic IP
2. Or use the Elastic IP directly with SSL/TLS certificate

## Security Best Practices

✓ Use security groups to restrict traffic
✓ Restrict SSH access to specific IPs (not 0.0.0.0/0)
✓ Run Docker containers with minimal privileges
✓ Use IAM roles instead of hardcoded credentials
✓ Enable VPC flow logs for monitoring
✓ Use S3 backend with encryption for state files
✓ Implement regular backups
✓ **Enable TLS for Vault in production** (`vault_skip_tls_verify = false`)
✓ **Restrict Vault CIDR access** (not 0.0.0.0/0)
✓ **Rotate secrets regularly**
✓ **Enable Vault audit logging**

## Cost Estimation

Using default configuration (free tier eligible):
- **EC2 t2.micro**: Free tier (750 hours/month)
- **Elastic IP**: Free while associated with instance
- **VPC/NAT**: Free
- **Vault**: Free (open source), or managed service costs

**Estimated Monthly Cost**: $0 (within free tier)

When moving to production:
- t2.small: ~$20/month
- t3.medium: ~$40/month
- Vault licensing: Varies ($0 for open source, $100-500+ for enterprise)
- Additional data transfer charges may apply

## Cleanup and Destroying Resources

### Option 1: Keep Terraform State
```bash
terraform destroy -auto-approve
```

Keeps state files for re-deployment.

### Option 2: Complete Cleanup (Recommended for Development)
```powershell
# Windows
.\scripts\cleanup.ps1

# Linux/macOS
./scripts/cleanup.sh
```

Removes all resources AND state files, leaving a clean workspace.

## Outputs After Deployment

After successful deployment, you'll see:
```
elastic_ip_address = "203.0.113.1"
elastic_ip_id = "eipalloc-xxxxxxxxx"
instance_id = "i-xxxxxxxxx"
instance_private_ip = "10.0.1.50"
website_url = "http://203.0.113.1"
vpc_id = "vpc-xxxxxxxxx"

deployment_summary = {
  "elastic_ip" = "203.0.113.1"
  "instance_id" = "i-xxxxxxxxx"
  "project_name" = "docker-web-app"
  "vpc_id" = "vpc-xxxxxxxxx"
  "website_url" = "http://203.0.113.1"
}
```

## Further Customization

### Add Database
Create `modules/rds/` for database deployment

### Add Load Balancer
Create `modules/alb/` for Application Load Balancer

### Add Monitoring
Create `modules/cloudwatch/` for custom metrics and alarms

### Add CDN
Integrate CloudFront for content distribution

## Support & Documentation

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Terraform Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Vault Terraform Provider](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)
- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs)
- [Docker Documentation](https://docs.docker.com/)
- [AWS EC2 User Guide](https://docs.aws.amazon.com/ec2/)

## GitHub Actions CI/CD

### Overview

This project includes a complete GitHub Actions workflow for automated deployment:

- **Automated Plan**: Validates and plans deployment on every PR
- **Automated Apply**: Applies infrastructure changes on merge to main
- **PR Comments**: Provides plan details in pull request comments
- **Deployment Summary**: Shows deployment outputs and website URL
- **Security**: Uses GitHub Secrets for sensitive credentials
- **Notifications**: Sends deployment status (optional Slack integration)

### Quick Setup

1. **Push to GitHub**:
   ```bash
   git push origin main
   ```

2. **Add GitHub Secrets** (Settings → Secrets and variables → Actions):
   ```
   AWS_ACCESS_KEY_ID = your_actual_access_key_id
   AWS_SECRET_ACCESS_KEY = your_actual_secret_access_key
   VAULT_TOKEN = root
   SSH_PUBLIC_KEY_PATH = ~/.ssh/docker-web-app-key.pub
   ```

3. **Create PR to test**:
   ```bash
   git checkout -b feature-branch
   git push origin feature-branch
   # Create PR on GitHub
   ```

4. **Merge to deploy**:
   - Merge PR to main
   - GitHub Actions automatically deploys!

### Workflow Features

**`.github/workflows/terraform-deploy.yml`**:
- Validates Terraform syntax
- Checks code formatting
- Creates deployment plan
- Comments on PRs with plan details
- Applies on main branch push
- Provides deployment summary
- Optional Slack notifications

### Documentation

For complete GitHub Actions setup and customization:
- **GITHUB_ACTIONS_OVERVIEW.md** - Quick start and overview
- **GITHUB_ACTIONS_SETUP.md** - Complete detailed setup guide
- **GITHUB_ACTIONS_QUICKSTART.md** - Quick reference

### Usage

**Deploy via GitHub**:
1. Make code changes
2. Create Pull Request
3. Review plan in PR comments
4. Merge to main
5. GitHub Actions deploys automatically
6. Check Actions tab for deployment summary

**Manual Deploy** (if needed):
- Go to Actions tab → Terraform Deploy → Run workflow



## License

This project is provided as-is for educational and production use.

## Version History

- **v2.0** (Dec 2025): Added HashiCorp Vault integration for secret management
- **v1.0** (Dec 2025): Initial release with core modules and deployment scripts

---

**Ready to deploy?** Start with `./scripts/deploy.ps1` or `./scripts/deploy.sh`

**For Vault setup:** See [VAULT_SETUP.md](./VAULT_SETUP.md)
