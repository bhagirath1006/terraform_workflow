output "instance_id" {
  value       = try(aws_instance.app.id, null)
  description = "EC2 instance ID"
}

output "private_ip" {
  value       = try(aws_instance.app.private_ip, null)
  description = "EC2 instance private IP"
}

output "public_ip" {
  value       = try(aws_eip.app.public_ip, null)
  description = "Elastic IP address"
}

output "website_url" {
  value       = try("http://${aws_eip.app.public_ip}", null)
  description = "Website URL via Elastic IP"
}

output "log_group_name" {
  value       = try(aws_cloudwatch_log_group.app.name, null)
  description = "CloudWatch log group name"
}
