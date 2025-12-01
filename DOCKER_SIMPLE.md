# Docker Module - Simplified

## Overview

A minimal Docker module that:
1. Pulls a Docker image from registry
2. Runs a single container
3. Maps ports (internal → external)
4. Sets restart policy

## Configuration

Edit `terraform.tfvars`:

```hcl
# Enable Docker management
enable_docker_provider = true

# Docker image to run
docker_image = "nginx:latest"

# Container name
docker_container_name = "website-app"

# Port mapping
docker_container_port = 80  # Container port
docker_host_port = 80       # Host/external port

# Restart policy
docker_restart_policy = "unless-stopped"
```

## Quick Examples

### Simple Web Server
```hcl
docker_image = "nginx:latest"
```

### Node.js App
```hcl
docker_image = "node:18-alpine"
docker_container_port = 3000
docker_host_port = 3000
```

### Custom Image from ECR
```hcl
docker_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
```

## Workflow

1. **Edit Configuration**
```bash
# Update terraform.tfvars with your Docker image
docker_image = "your-image:tag"
```

2. **Deploy**
```bash
terraform apply
```

3. **Verify**
```bash
# SSH to instance
ssh -i key.pem ubuntu@<elastic-ip>

# Check container
docker ps
docker logs website-app
```

4. **Update Container**
```bash
# Change image or port in terraform.tfvars
docker_image = "new-image:tag"

# Reapply
terraform apply
```

## Access Your Application

```
http://<elastic-ip>:<docker_host_port>
```

Example:
```
http://203.0.113.1:80
```

## Disable Docker

To disable Docker container management (EC2 still runs):

```hcl
enable_docker_provider = false
```

Then apply:
```bash
terraform apply
```

## Available Restart Policies

- `no` - Do not restart
- `always` - Always restart if stops
- `unless-stopped` - Always restart unless explicitly stopped (recommended)
- `on-failure` - Restart only on error

## That's It!

The Docker module is now simple and straightforward. Just set the image and port, and Terraform handles the rest.
