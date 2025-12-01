output "container_id" {
  description = "Docker container ID"
  value       = docker_container.app.id
}

output "container_name" {
  description = "Docker container name"
  value       = docker_container.app.name
}

output "image_id" {
  description = "Docker image ID"
  value       = docker_image.app.id
}

