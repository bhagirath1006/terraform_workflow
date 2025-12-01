aws_region      = "us-east-1"
project_name    = "terraform-app"
environment     = "staging"
vpc_cidr        = "10.1.0.0/16"
instance_type   = "t3.small"
ssh_allowed_cidr = "10.0.0.0/8"

# Docker configuration (update with your values)
docker_registry_server = "docker.io"
docker_username        = "your-docker-username"
docker_password        = "your-docker-password"
docker_image_uri       = "your-docker-image:staging"
container_port         = 8080
host_port              = 80

# Secrets (use AWS Secrets Manager in production)
app_secret_value = "staging-secret-change-me"
db_username      = "stagingadmin"
db_password      = "staging-password-change-me"
api_key          = "staging-api-key-change-me"

# Monitoring
enable_monitoring    = true
log_retention_days   = 14
