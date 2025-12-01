output "instance_id" {
  value       = aws_instance.app.id
  description = "EC2 instance ID"
}

output "private_ip" {
  value       = aws_instance.app.private_ip
  description = "EC2 private IP address"
}

output "public_ip" {
  value       = aws_eip.app.public_ip
  description = "Elastic IP address"
}

output "website_url" {
  value       = "http://${aws_eip.app.public_ip}"
  description = "Website URL"
}

output "cloudwatch_log_group" {
  value       = aws_cloudwatch_log_group.ec2_logs.name
  description = "CloudWatch log group name"
}

output "cpu_alarm_id" {
  value       = aws_cloudwatch_metric_alarm.ec2_cpu_high.alarm_name
  description = "CloudWatch CPU alarm name"
}

output "status_alarm_id" {
  value       = aws_cloudwatch_metric_alarm.ec2_status_check_failed.alarm_name
  description = "CloudWatch status check alarm name"
}
