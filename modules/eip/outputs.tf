output "eip_id" {
  description = "Elastic IP ID"
  value       = local.eip_id
}

output "eip_address" {
  description = "Elastic IP address"
  value       = local.eip_address
}

output "eip_association_id" {
  description = "Elastic IP association ID"
  value       = local.eip_association_id
}

output "is_new_eip" {
  description = "Whether a new EIP was created"
  value       = var.create_new_eip
}
