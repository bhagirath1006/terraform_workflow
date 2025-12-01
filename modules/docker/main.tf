# ============================================================================
# Docker Module - Container Management
# ============================================================================
# Simple Docker provider configuration to pull and run a container
# Note: Requires Docker daemon to be running on EC2 instance

# ============================================================================
# Docker Image Resource
# ============================================================================
# Pulls Docker image from registry (Docker Hub, ECR, etc.)
# Re-pulls image on each apply if pull_triggers changes

resource "docker_image" "app" {
  name          = var.docker_image
  pull_triggers = [var.docker_image]  # Re-pull if image tag changes
  pull          = true                 # Always pull latest version
}

# ============================================================================
# Docker Container Resource
# ============================================================================
# Runs Docker container with port mapping and restart policy
# Container automatically restarts on EC2 reboot

resource "docker_container" "app" {
  name  = var.container_name
  image = docker_image.app.image_id

  # ============================================================================
  # Port Mapping
  # ============================================================================
  # Maps container port to host port (container_port -> host_port)
  # Example: container port 8080 exposed on host port 80
  
  ports {
    internal = var.container_port
    external = var.host_port
    protocol = "tcp"
  }

  # ============================================================================
  # Restart Policy
  # ============================================================================
  # Container restarts automatically unless manually stopped
  # Options: no, always, on-failure, unless-stopped
  
  restart_policy {
    condition = var.restart_policy
  }

  depends_on = [docker_image.app]
}
