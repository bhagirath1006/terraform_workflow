aws_region      = "us-east-1"
project_name    = "terraform-app"
environment     = "prod"
vpc_cidr        = "10.2.0.0/16"
instance_type   = "t3.medium"
ssh_allowed_cidr = "10.0.0.0/8"

# Docker configuration (update with your values)
docker_registry_server = "docker.io"
docker_username        = "your-docker-username"
docker_password        = "your-docker-password"
docker_image_uri       = "your-docker-image:latest"
container_port         = 8080
host_port              = 80

# Secrets (use AWS Secrets Manager in production)
db_username      = "prodadmin"
db_password      = "prod-password-change-me"
api_key          = "prod-api-key-change-me"

# Monitoring
enable_monitoring    = true
log_retention_days   = 30
