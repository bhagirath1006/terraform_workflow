#!/bin/bash
set -e

# Update system packages
apt-get update
apt-get upgrade -y

# Install Docker
apt-get install -y docker.io curl wget

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Start Docker service
systemctl start docker
systemctl enable docker

# Deploy NGINX container
docker pull nginx:latest
docker run -d \
  --name ${project_name}-web \
  --restart unless-stopped \
  -p 80:80 \
  -p 443:443 \
  nginx:latest

echo "Container deployment complete" > /var/log/deployment.log
