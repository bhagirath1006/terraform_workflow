terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "app" {
  name          = var.docker_image
  pull_triggers = [var.docker_image]
  keep_locally  = false
}

resource "docker_container" "app" {
  name  = var.container_name
  image = docker_image.app.image_id

  ports {
    internal = var.container_port
    external = var.host_port
  }

  restart_policy_name             = var.restart_policy_name
  restart_policy_maximum_retry_count = var.restart_policy_retry

  depends_on = [docker_image.app]
}
