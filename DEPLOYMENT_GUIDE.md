# Terraform Deployment Guide

## Quick Start

### 1. Prerequisites
- Terraform 1.14.0+
- AWS CLI configured with credentials
- AWS IAM user with appropriate permissions
- Git (for CI/CD)

### 2. Validate Configuration
```powershell
cd terraform_fresh_infra
terraform validate
```

### 3. Plan Deployment
```powershell
terraform plan -out=tfplan
```

### 4. Apply Infrastructure
```powershell
terraform apply tfplan
```

### 5. Access Your Application
```powershell
terraform output website_url
# Output: http://YOUR-ELASTIC-IP
```

---

## Deployment Steps

### Step 1: Validate Terraform Files
Ensure all Terraform files are syntactically correct:
```powershell
cd terraform_fresh_infra
terraform validate
# Expected output: Success! The configuration is valid.
```

### Step 2: Format Check (Optional)
Format all Terraform files to standards:
```powershell
terraform fmt -recursive
```

### Step 3: Initialize Terraform
Download required providers and initialize backend:
```powershell
terraform init
# Expected output: Terraform has been successfully initialized!
```

### Step 4: Plan Deployment
Preview all infrastructure changes before applying:
```powershell
terraform plan -out=tfplan
# Review the output - shows: Plan: 8 to add, 0 to change, 0 to destroy
```

### Step 5: Apply Configuration
Deploy infrastructure to AWS:
```powershell
terraform apply tfplan
# Wait 2-3 minutes for EC2 instance and container to start
```

### Step 6: Verify Deployment
Check that all resources are created:
```powershell
terraform output
# Shows VPC ID, Subnet ID, Instance ID, Public IP, Website URL
```

### Step 7: Access Application
Use the elastic IP to access your NGINX container:
```powershell
$url = terraform output -raw website_url
Start-Process $url
```

---

## Infrastructure Components

### Network (VPC)
- **CIDR Block**: 10.0.0.0/16
- **Public Subnet**: 10.0.1.0/24 (us-east-1a)
- **Internet Gateway**: For external connectivity
- **Route Table**: Routes 0.0.0.0/0 to IGW

### Security
- **Security Group**: Opens ports 22 (SSH) and 80 (HTTP)
- **No Public SSH Key**: Set one via AWS console if needed

### Compute (EC2)
- **Instance Type**: t2.micro (free tier eligible)
- **AMI**: Ubuntu 22.04 LTS (latest)
- **Elastic IP**: Fixed public IP address
- **User Data**: Auto-installs Docker and deploys NGINX

### Container
- **Image**: nginx:latest
- **Port Mapping**: 80:80
- **Restart Policy**: Unless stopped

### Monitoring
- **CloudWatch Logs**: 7-day retention
- **CPU Alarm**: Triggers when > 80%
- **Status Check Alarm**: Triggers on instance health failures

---

## Outputs Reference

After deployment, use these commands to retrieve information:

```powershell
# Get specific outputs
terraform output vpc_id
terraform output website_url
terraform output instance_id

# Get all outputs in JSON
terraform output -json | ConvertFrom-Json

# Get raw output (for scripts)
terraform output -raw public_ip
```

---

## Troubleshooting

### Issue: "Error: AWS credentials not found"

**Solution:**
1. Configure AWS credentials in `~/.aws/credentials`:
   ```
   [default]
   aws_access_key_id = YOUR_KEY_ID
   aws_secret_access_key = YOUR_SECRET_KEY
   ```

2. Or set environment variables:
   ```powershell
   $env:AWS_ACCESS_KEY_ID = "YOUR_KEY_ID"
   $env:AWS_SECRET_ACCESS_KEY = "YOUR_SECRET_KEY"
   ```

3. Test credentials:
   ```powershell
   aws sts get-caller-identity
   ```

### Issue: "Error: Security group rule conflict"

**Solution:** This means you're deploying to a region where security groups with these rules already exist. Change the `project_name` in `terraform.tfvars`:
```hcl
project_name = "myapp-v2"
```

Then run:
```powershell
terraform plan -out=tfplan
terraform apply tfplan
```

### Issue: "Error: AMI not found in region"

**Solution:** The Ubuntu AMI might not exist in your region. Change `aws_region` in `terraform.tfvars`:
```hcl
aws_region = "us-west-2"
```

Then reinitialize:
```powershell
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Issue: "terraform init fails with provider installation errors"

**Solution:** Clear the Terraform cache and reinitialize:
```powershell
rm -r .terraform
rm .terraform.lock.hcl
terraform init
```

### Issue: "Container not running after EC2 launch"

**Solution:** SSH into the instance and check logs:
```powershell
# Get instance IP
$ip = terraform output -raw public_ip

# SSH into instance (if you set a key pair)
ssh -i your-key.pem ubuntu@$ip

# Check container status
docker ps
docker logs myapp-web

# Check user_data logs
tail -f /var/log/cloud-init-output.log
```

### Issue: "Cannot reach website on public IP"

**Solution:** 
1. Verify security group allows port 80:
   ```powershell
   terraform output security_group_id
   # Check in AWS console that it allows 0.0.0.0/0 on port 80
   ```

2. Check container is running:
   ```powershell
   # SSH into instance and run:
   docker ps
   docker logs myapp-web
   ```

3. Wait 2-3 minutes for instance startup:
   ```powershell
   # Check instance status in AWS console
   # Status should be "2/2 checks passed"
   ```

---

## State Management

### Local State (Current)
Terraform state is stored locally in `terraform.tfstate`. For team collaboration, use remote state.

### Remote State with S3 (Recommended)

1. Run backend setup script:
   ```bash
   bash scripts/setup_backend.sh
   ```

2. Uncomment the `terraform` block in `backend.tf`:
   ```hcl
   terraform {
     backend "s3" {
       bucket         = "myapp-terraform-state-ACCOUNT_ID"
       key            = "terraform_fresh_infra/terraform.tfstate"
       region         = "us-east-1"
       encrypt        = true
       dynamodb_table = "terraform-locks"
     }
   }
   ```

3. Reinitialize Terraform:
   ```powershell
   terraform init
   # Choose "yes" to migrate state to S3
   ```

---

## Cleanup & Destruction

### Remove Infrastructure
To destroy all resources and avoid AWS charges:

```powershell
terraform destroy
# Review the output and confirm with 'yes'
```

### Verification
Verify all resources are deleted in AWS console:
- EC2 Instances
- Elastic IPs
- VPCs
- Security Groups

---

## CI/CD Integration

### GitHub Actions
The workflow in `.github/workflows/terraform.yml` provides:

1. **Validation**: On every push to `main`
   - Terraform format check
   - Terraform validation
   - TFLint analysis
   - Checkov security scan

2. **Planning**: On every pull request
   - Terraform plan
   - Plan artifact uploaded
   - PR commented with plan summary

### To Enable CI/CD
1. Push code to GitHub repository
2. Add AWS credentials as repository secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
3. Create a pull request to trigger the workflow

---

## Best Practices

1. **Always review `terraform plan` output before applying**
2. **Use remote state for team collaboration**
3. **Enable state locking with DynamoDB**
4. **Use `terraform.tfvars` for environment-specific values**
5. **Keep sensitive data in AWS Secrets Manager**
6. **Enable CloudWatch monitoring and alarms**
7. **Use tags for resource organization**
8. **Implement state backups**
9. **Use Terraform workspaces for multiple environments**
10. **Document your infrastructure changes in PR descriptions**

---

## Advanced Topics

### Multi-Environment Setup
Create separate directories for prod/staging:
```
terraform_fresh_infra/  # dev
terraform_prod_infra/   # prod
terraform_staging_infra/ # staging
```

### Using Terraform Workspaces
```powershell
terraform workspace new prod
terraform workspace select prod
terraform plan  # Plans for prod workspace
```

### Importing Existing Resources
```powershell
# Find the resource ID in AWS console
terraform import aws_instance.app i-0123456789abcdef0
```

---

## Support & Documentation

- **Terraform Docs**: https://www.terraform.io/docs
- **AWS Provider Docs**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **Community**: https://discuss.hashicorp.com/c/terraform/

---

## Deployment Checklist

- [ ] AWS credentials configured
- [ ] Terraform version >= 1.14.0
- [ ] `terraform validate` passes
- [ ] `terraform plan` reviewed and correct
- [ ] Security group rules reviewed
- [ ] AMI available in target region
- [ ] AWS account has sufficient resources
- [ ] Backup existing state (if applicable)
- [ ] Team notified of deployment
- [ ] Monitoring alarms configured
- [ ] Post-deployment verification complete
