# Terraform Quick Reference

## Essential Commands

```powershell
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Show plan without applying
terraform plan -out=tfplan

# Apply planned changes
terraform apply tfplan

# Destroy all resources
terraform destroy

# Show outputs
terraform output

# Show specific output
terraform output -raw website_url

# Show state
terraform state list
terraform state show aws_vpc.main

# Refresh state from AWS
terraform refresh

# Lock/unlock state manually
terraform force-unlock ID
```

## Configuration File Structure

```
terraform_fresh_infra/
├── provider.tf          # Provider configuration
├── variables.tf         # Input variable definitions
├── main.tf             # Resource definitions
├── outputs.tf          # Output definitions
├── backend.tf          # Backend configuration (commented)
├── terraform.tfvars    # Variable values
├── .terraform/         # Provider plugins (auto-generated)
├── .terraform.lock.hcl # Provider version lock (auto-generated)
├── terraform.tfstate   # Current state (auto-generated)
└── modules/
    └── ec2/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── monitoring.tf
        └── user_data.sh
```

## Variable Usage

### In terraform.tfvars
```hcl
aws_region   = "us-east-1"
project_name = "myapp"
environment  = "dev"
```

### In main.tf
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "${var.project_name}-vpc"
  }
}
```

### Via Command Line
```powershell
terraform plan -var="project_name=myapp-prod"
terraform plan -var-file="prod.tfvars"
```

## Output Reference

### Usage in Code
```hcl
output "website_url" {
  value       = "http://${aws_eip.app.public_ip}"
  description = "Website URL"
  sensitive   = false  # Set to true to hide from logs
}
```

### Retrieve in PowerShell
```powershell
# Get single output
terraform output website_url

# Get all outputs as JSON
terraform output -json

# Get raw value (useful for scripts)
terraform output -raw public_ip

# Use in script
$website = terraform output -raw website_url
Write-Host "Access your site at: $website"
```

## Resource Reference

### Common AWS Resources in This Project

| Resource | ID | Example |
|----------|----|----|
| VPC | vpc-xxxxx | aws_vpc.main |
| Subnet | subnet-xxxxx | aws_subnet.public |
| Security Group | sg-xxxxx | aws_security_group.main |
| EC2 Instance | i-xxxxx | aws_instance.app |
| Elastic IP | eip-xxxxx | aws_eip.app |
| CloudWatch Log Group | /aws/ec2/... | aws_cloudwatch_log_group.ec2_logs |

### Example: Access Resource Values
```hcl
# In code, reference resources
resource "aws_instance" "app" {
  subnet_id = aws_subnet.public.id
  security_groups = [aws_security_group.main.id]
}

# In outputs
output "instance_ip" {
  value = aws_instance.app.private_ip
}
```

## Module Reference

### Module Usage Pattern
```hcl
module "ec2" {
  source = "./modules/ec2"
  
  # Input variables
  instance_type      = "t2.micro"
  subnet_id          = aws_subnet.public.id
  security_group_id  = aws_security_group.main.id
  project_name       = var.project_name
  internet_gateway_id = aws_internet_gateway.main.id
}

# Access module outputs
output "website_url" {
  value = module.ec2.website_url
}
```

## Debugging

```powershell
# Enable debug logging
$env:TF_LOG = "DEBUG"
terraform plan

# Save debug logs to file
$env:TF_LOG_PATH = "terraform-debug.log"
terraform plan

# Check provider logs
terraform providers
terraform providers schema -json
```

## State Management

```powershell
# List all resources in state
terraform state list

# Show specific resource
terraform state show aws_instance.app

# Replace resource address
terraform state mv aws_instance.app aws_instance.web

# Remove from state (dangerous!)
terraform state rm aws_instance.app

# Clear and refresh state from AWS
terraform refresh
```

## Security

### Sensitive Variables
```hcl
variable "db_password" {
  type      = string
  sensitive = true  # Won't be logged
}

output "db_endpoint" {
  value     = aws_db_instance.main.endpoint
  sensitive = true
}
```

### State Encryption
- Always use remote state with encryption (S3 + DynamoDB)
- Never commit `terraform.tfvars` with secrets
- Use AWS Secrets Manager for sensitive data
- Rotate AWS credentials regularly

## Performance Tips

```powershell
# Parallel resource creation (default: 10)
terraform apply -parallelism=15

# Skip refreshing state
terraform plan -refresh=false

# Target specific resources
terraform plan -target=aws_instance.app
terraform apply -target=aws_instance.app

# Exclude resources
terraform plan -target='aws_*' -target='!aws_s3_*'
```

## Workspace Usage

```powershell
# List workspaces
terraform workspace list

# Create new workspace
terraform workspace new prod

# Switch workspace
terraform workspace select prod

# Delete workspace
terraform workspace delete staging

# Show current workspace
terraform workspace show
```

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| "Resource already exists" | Change `project_name` in tfvars |
| "Provider not installed" | Run `terraform init` |
| "Invalid credentials" | Check AWS credentials configuration |
| "State locked" | Run `terraform force-unlock <LOCK_ID>` |
| "Module not found" | Run `terraform init` |
| "Backend initialization failed" | Uncomment backend config carefully |

## Useful AWS CLI Commands

```powershell
# Check credentials
aws sts get-caller-identity

# List resources
aws ec2 describe-instances
aws ec2 describe-vpcs
aws ec2 describe-security-groups

# Check CloudWatch alarms
aws cloudwatch describe-alarms

# View CloudWatch logs
aws logs tail /aws/ec2/myapp-instance --follow
```

## File Locations

- **AWS Credentials**: `~/.aws/credentials`
- **AWS Config**: `~/.aws/config`
- **Terraform State**: `./terraform.tfstate`
- **Provider Plugins**: `./.terraform/providers`
- **Lock File**: `./.terraform.lock.hcl`
- **Debug Logs**: `./terraform-debug.log`

## Environment Variables

```powershell
# AWS
$env:AWS_PROFILE = "default"
$env:AWS_REGION = "us-east-1"
$env:AWS_ACCESS_KEY_ID = "xxx"
$env:AWS_SECRET_ACCESS_KEY = "xxx"

# Terraform
$env:TF_LOG = "DEBUG"
$env:TF_LOG_PATH = "terraform.log"
$env:TF_INPUT = "false"
$env:TF_PARALLELISM = "5"
```

## Terraform Cloud/Enterprise

```powershell
# Login to Terraform Cloud
terraform login

# View remote state
terraform show

# Set remote backend
terraform cloud
```

## Version Pinning

In `provider.tf`:
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Any 5.x.x version
    }
  }
}
```

## Script Examples

### Deploy and Get URL
```powershell
cd terraform_fresh_infra
terraform init
terraform plan -out=tfplan
terraform apply tfplan
$url = terraform output -raw website_url
Write-Host "Your application is available at: $url"
```

### Destroy and Cleanup
```powershell
terraform destroy
Write-Host "Infrastructure destroyed"
```

### Monitor Deployment
```powershell
$instanceId = terraform output -raw instance_id
aws ec2 wait instance-status-ok --instance-ids $instanceId
Write-Host "Instance is ready!"
```
