terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "terraform/${var.environment}/app-secrets"
  description             = "Application secrets for ${var.environment}"
  recovery_window_in_days = var.recovery_window_days

  tags = {
    Name        = "${var.project_name}-secrets"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    docker_username = var.docker_username
    docker_password = var.docker_password
    db_username     = var.db_username
    db_password     = var.db_password
    api_key         = var.api_key
  })
}

resource "aws_secretsmanager_secret" "database_credentials" {
  count                   = var.create_db_secret ? 1 : 0
  name                    = "terraform/${var.environment}/db-credentials"
  description             = "Database credentials for ${var.environment}"
  recovery_window_in_days = var.recovery_window_days

  tags = {
    Name        = "${var.project_name}-db-secrets"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "database_credentials" {
  count     = var.create_db_secret ? 1 : 0
  secret_id = aws_secretsmanager_secret.database_credentials[0].id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    engine   = "postgres"
    port     = 5432
  })
}
