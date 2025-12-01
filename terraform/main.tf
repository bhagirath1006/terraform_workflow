# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  ssh_allowed_cidr   = var.ssh_allowed_cidr
}

# Secrets Module
module "secrets" {
  source = "./modules/secrets"

  project_name       = var.project_name
  environment        = var.environment
  app_secret_value   = var.app_secret_value
  db_username        = var.db_username
  db_password        = var.db_password
  api_key            = var.api_key
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  project_name              = var.project_name
  environment               = var.environment
  instance_type             = var.instance_type
  subnet_id                 = module.vpc.public_subnet_ids[0]
  security_group_id         = module.vpc.security_group_id
  docker_registry_server    = var.docker_registry_server
  docker_username           = var.docker_username
  docker_password           = var.docker_password
  docker_image_uri          = var.docker_image_uri
  container_port            = var.container_port
  host_port                 = var.host_port
  enable_monitoring         = var.enable_monitoring
  log_retention_days        = var.log_retention_days
}
