#!/bin/bash
set -e

# Update system packages
apt-get update
apt-get upgrade -y

# Install Docker and dependencies
apt-get install -y docker.io curl wget jq aws-cli git

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Start Docker service
systemctl start docker
systemctl enable docker

# Create application directory
mkdir -p /opt/app
cd /opt/app

# Log initialization
echo "EC2 instance initialized for ${project_name}" >> /var/log/deployment.log
echo "Docker and AWS CLI ready" >> /var/log/deployment.log
date >> /var/log/deployment.log
