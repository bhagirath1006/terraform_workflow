output "instance_id" {
  value = aws_instance.app.id
}

output "private_ip" {
  value = aws_instance.app.private_ip
}

output "public_ip" {
  value = aws_eip.app.public_ip
}

output "website_url" {
  value = "http://${aws_eip.app.public_ip}"
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.app.name
}
