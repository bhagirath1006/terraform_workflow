# VPC Module
module "vpc" {
  source = "./modules/vpc"

  project_name     = var.project_name
  environment      = var.environment
  vpc_cidr         = var.vpc_cidr
  public_subnets   = var.public_subnet_cidrs
  private_subnets  = var.private_subnet_cidrs
  ssh_allowed_cidr = var.ssh_allowed_cidr
}

# Secrets Module (with Vault backend)
module "secrets" {
  source = "./modules/secrets"

  project_name          = var.project_name
  environment           = var.environment
  vault_addr            = var.vault_addr
  vault_token           = var.vault_token
  vault_skip_tls_verify = var.vault_skip_tls_verify
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  project_name          = var.project_name
  environment           = var.environment
  instance_type         = var.instance_type
  subnet_id             = module.vpc.public_subnet_ids[0]
  security_group_id     = module.vpc.security_group_id
  ssh_security_group_id = module.vpc.ssh_security_group_id
  enable_monitoring     = var.enable_monitoring
  log_retention_days    = var.log_retention_days
  ssh_public_key        = var.ssh_public_key
}
