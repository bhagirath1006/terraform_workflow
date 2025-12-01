# ============================================================================
# Terraform Outputs
# ============================================================================
# Key information from deployed infrastructure

# ============================================================================
# Website Access URL
# ============================================================================
# Access deployed website via this URL (HTTP on configured port)

output "website_url" {
  description = "Website URL using Elastic IP"
  value       = "http://${module.eip.eip_address}"
}

# ============================================================================
# Elastic IP Address
# ============================================================================
# Fixed public IP address associated with EC2 instance

output "elastic_ip" {
  description = "Elastic IP address for SSH access"
  value       = module.eip.eip_address
}

# ============================================================================
# Docker Container ID
# ============================================================================
# Container ID of deployed application

output "docker_container_id" {
  description = "Docker container ID (null if Docker disabled)"
  value       = try(module.docker[0].container_id, null)
}

# ============================================================================
# Deployment Summary
# ============================================================================
# Quick reference of all deployment details

output "deployment_summary" {
  description = "Complete deployment information"
  value = {
    website_url  = "http://${module.eip.eip_address}"
    elastic_ip   = module.eip.eip_address
    instance_id  = module.ec2.instance_id
    docker_image = var.docker_image
  }
}

# ============================================================================
# Vault Status
# ============================================================================
# Shows whether Vault integration is enabled

output "vault_status" {
  description = "Vault integration status"
  value       = var.enable_vault ? "Enabled at ${var.vault_address}" : "Disabled"
}
