#!/bin/bash
set -e

# Update system packages
apt-get update
apt-get upgrade -y

# Install Docker
apt-get install -y docker.io docker-compose curl wget jq

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Start Docker service
systemctl start docker
systemctl enable docker

# Login to Docker registry if credentials provided
if [ -n "${docker_username}" ] && [ -n "${docker_password}" ]; then
  echo "${docker_password}" | docker login -u "${docker_username}" --password-stdin ${docker_registry_server}
fi

# Pull and run container
docker pull ${docker_image_uri}
docker run -d \
  --name ${project_name} \
  --restart unless-stopped \
  -p ${host_port}:${container_port} \
  ${docker_image_uri}

# Log deployment
echo "Container deployment complete: ${docker_image_uri}" >> /var/log/deployment.log
date >> /var/log/deployment.log
