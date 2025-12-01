output "app_secrets_arn" {
  value = aws_secretsmanager_secret.app_secrets.arn
}

output "app_secrets_name" {
  value = aws_secretsmanager_secret.app_secrets.name
}

output "db_secrets_arn" {
  value = try(aws_secretsmanager_secret.database_credentials[0].arn, null)
}

output "db_secrets_name" {
  value = try(aws_secretsmanager_secret.database_credentials[0].name, null)
}
