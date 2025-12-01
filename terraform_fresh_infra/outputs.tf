output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "subnet_id" {
  value       = aws_subnet.public.id
  description = "Public subnet ID"
}

output "security_group_id" {
  value       = aws_security_group.main.id
  description = "Security group ID"
}

output "instance_id" {
  value       = module.ec2.instance_id
  description = "EC2 instance ID"
}

output "private_ip" {
  value       = module.ec2.private_ip
  description = "EC2 private IP address"
}

output "public_ip" {
  value       = module.ec2.public_ip
  description = "Elastic IP address"
}

output "website_url" {
  value       = module.ec2.website_url
  description = "Website URL"
}
