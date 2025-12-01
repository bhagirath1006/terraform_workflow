aws_region       = "ap-south-1"
project_name     = "terraform-app"
environment      = "staging"
vpc_cidr         = "10.1.0.0/16"
instance_type    = "t3.small"
ssh_allowed_cidr = ["10.0.0.0/8"]

# Vault configuration
vault_addr            = "https://vault.staging.example.com:8200"
vault_token           = "your-vault-token"
vault_skip_tls_verify = false

# Monitoring
enable_monitoring  = true
log_retention_days = 14
