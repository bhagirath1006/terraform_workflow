output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.vpc.security_group_id
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "instance_private_ip" {
  description = "EC2 instance private IP"
  value       = module.ec2.private_ip
}

output "instance_public_ip" {
  description = "EC2 instance Elastic IP"
  value       = module.ec2.public_ip
}

output "website_url" {
  description = "Website URL"
  value       = module.ec2.website_url
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = module.ec2.log_group_name
}

output "app_secret_arn" {
  description = "Path to application secrets in Vault"
  value       = module.secrets.app_secrets_path
  sensitive   = true
}

output "database_secret_arn" {
  description = "Path to database secrets in Vault"
  value       = module.secrets.database_secrets_path
  sensitive   = true
}

output "api_secret_arn" {
  description = "Vault policy name for EC2 instances"
  value       = module.secrets.ec2_policy_name
  sensitive   = true
}
