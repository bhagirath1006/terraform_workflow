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
  value       = try(module.ec2.instance_id, "pending")
}

output "instance_private_ip" {
  description = "EC2 instance private IP"
  value       = try(module.ec2.private_ip, "pending")
}

output "instance_public_ip" {
  description = "EC2 instance Elastic IP"
  value       = try(module.ec2.public_ip, "pending")
}

output "website_url" {
  description = "Website URL"
  value       = try(module.ec2.website_url, "pending")
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = try(module.ec2.log_group_name, "pending")
}

output "elastic_ip" {
  description = "Elastic IP address"
  value       = try(module.ec2.public_ip, "pending")
}

output "vault_secrets_path" {
  description = "Path to application secrets in Vault"
  value       = module.secrets.app_secrets_path
  sensitive   = false
}
