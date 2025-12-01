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
  value       = module.ec2.instance_private_ip
}

output "instance_public_ip" {
  description = "EC2 instance Elastic IP"
  value       = module.ec2.instance_public_ip
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
  description = "Application secret ARN"
  value       = module.secrets.app_secret_arn
  sensitive   = true
}

output "database_secret_arn" {
  description = "Database secret ARN"
  value       = module.secrets.database_secret_arn
  sensitive   = true
}

output "api_secret_arn" {
  description = "API key secret ARN"
  value       = module.secrets.api_secret_arn
  sensitive   = true
}
