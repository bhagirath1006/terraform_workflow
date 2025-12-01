
module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = var.availability_zone
  allowed_ssh_cidrs  = var.allowed_ssh_cidrs
}

# EC2 Module - Compute Instance with SSH Access

module "ec2" {
  source = "./modules/ec2"

  project_name        = var.project_name
  ami_id              = var.ami_id
  instance_type       = var.instance_type
  subnet_id           = module.vpc.public_subnet_id
  security_group_id   = module.vpc.security_group_id
  user_data_script    = var.user_data_script
  root_volume_size    = var.root_volume_size
  ssh_key_name        = var.ssh_key_name
  ssh_public_key_path = var.ssh_public_key_path
}

# EIP Module - Fixed Public IP Address

module "eip" {
  source = "./modules/eip"

  project_name   = var.project_name
  instance_id    = module.ec2.instance_id
  create_new_eip = var.create_new_eip
  depends_on     = [module.ec2]
}

# Integrates HashiCorp Vault for secure secret storage and retrieval

module "vault" {
  count  = var.enable_vault ? 1 : 0
  source = "./modules/vault"

  vault_address    = var.vault_address
  skip_tls_verify  = var.vault_skip_tls_verify
  auth_method      = var.vault_auth_method
  auth_method_path = var.vault_auth_method_path
  auth_parameters  = var.vault_auth_parameters

  environment             = var.environment
  secrets                 = var.vault_secrets
  enable_database_secrets = var.enable_vault_database_secrets
  db_username             = var.vault_db_username
  db_password             = var.vault_db_password
  db_host                 = var.vault_db_host
  db_port                 = var.vault_db_port
  db_name                 = var.vault_db_name
  enable_app_config       = var.enable_vault_app_config
  api_key                 = var.vault_api_key
  debug_mode              = var.vault_debug_mode
  enable_approle          = var.enable_vault_approle
  token_ttl               = var.vault_token_ttl
  token_max_ttl           = var.vault_token_max_ttl
  secret_id_ttl           = var.vault_secret_id_ttl
  cidr_list               = var.vault_cidr_list
}
