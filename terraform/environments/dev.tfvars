aws_region       = "ap-south-1"
project_name     = "terraform-app"
environment      = "dev"
vpc_cidr         = "10.0.0.0/16"
instance_type    = "t3.micro"
ssh_allowed_cidr = ["10.0.0.0/8"]

# Vault configuration (update with your Vault details)
vault_addr            = "http://localhost:8200"
vault_token           = "your-vault-token"
vault_skip_tls_verify = true

# Monitoring
enable_monitoring  = true
log_retention_days = 7
