aws_region      = "us-east-1"
project_name    = "terraform-app"
environment     = "dev"
vpc_cidr        = "10.0.0.0/16"
instance_type   = "t3.micro"
ssh_allowed_cidr = "0.0.0.0/0"

# Docker configuration (update with your values)
docker_registry_server = "docker.io"
docker_username        = "your-docker-username"
docker_password        = "your-docker-password"
docker_image_uri       = "your-docker-image:latest"
container_port         = 8080
host_port              = 80

# Secrets (use AWS Secrets Manager in production)
app_secret_value = "dev-secret-change-me"
db_username      = "devadmin"
db_password      = "dev-password-change-me"
api_key          = "dev-api-key-change-me"

# Monitoring
enable_monitoring    = false
log_retention_days   = 3
