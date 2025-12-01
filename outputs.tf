# ============================================================================
# Terraform Outputs


output "website_url" {
  description = "Website URL using Elastic IP"
  value       = "http://${module.eip.eip_address}"
}

# ============================================================================
# Elastic IP Address

output "elastic_ip" {
  description = "Elastic IP address for SSH access"
  value       = module.eip.eip_address
}

# ============================================================================
# EC2 Instance Details

output "instance_id" {
  description = "EC2 Instance ID"
  value       = module.ec2.instance_id
}

# ============================================================================
# Deployment Summary


output "deployment_summary" {
  description = "Complete deployment information"
  value = {
    website_url = "http://${module.eip.eip_address}"
    elastic_ip  = module.eip.eip_address
    instance_id = module.ec2.instance_id
    environment = var.environment
  }
}

# ============================================================================
# Vault Status
# Shows whether Vault integration is enabled

output "vault_status" {
  description = "Vault integration status"
  value       = var.enable_vault ? "Enabled at ${var.vault_address}" : "Disabled"
}

