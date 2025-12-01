#!/bin/bash

# Complete SSH + Terraform Deploy Workflow
# This script handles key generation and deployment

set -e

PROJECT_DIR=\"$(cd \"$(dirname \"${BASH_SOURCE[0]}\")\" && pwd)\"
TERRAFORM_DIR=\"$PROJECT_DIR/terraform\"
ENV_FILE=\"$TERRAFORM_DIR/environments/dev.tfvars\"

echo \"\"
echo \"🚀 SSH Key + Terraform Deploy Workflow\"
echo \"======================================\"
echo \"\"

# Step 1: Generate SSH Key
echo \"Step 1️⃣  - Generate SSH Key\"
echo \"---------------------------------\"

if [ -f \"$PROJECT_DIR/ssh-keys/terraform-app-key\" ]; then
  read -p \"SSH key already exists. Use existing key? (yes/no): \" -r
  if [[ ! \$REPLY =~ ^[Yy][Ee][Ss]\$ ]]; then
    echo \"Generating new key...\"
    bash \"$PROJECT_DIR/generate_ssh_key.sh\"
  else
    echo \"Using existing key\"
  fi
else
  bash \"$PROJECT_DIR/generate_ssh_key.sh\"
fi

echo \"\"
echo \"Step 2️⃣  - Extract Public Key\"
echo \"---------------------------------\"

PUBLIC_KEY=\$(cat \"$PROJECT_DIR/ssh-keys/terraform-app-key.pub\")
echo \"Public key extracted: \${PUBLIC_KEY:0:50}...\"

echo \"\"
echo \"Step 3️⃣  - Update terraform.tfvars\"
echo \"---------------------------------\"

# Check if key already in tfvars
if grep -q \"ssh_public_key\" \"$ENV_FILE\"; then
  echo \"Updating existing ssh_public_key in $ENV_FILE\"
  # macOS sed needs -i '' but Linux sed needs -i
  if [[ \"\$OSTYPE\" == \"darwin\"* ]]; then
    sed -i '' \"s|# ssh_public_key = .*|ssh_public_key = \\\"$PUBLIC_KEY\\\"|g\" \"$ENV_FILE\"
    sed -i '' \"s|ssh_public_key = .*|ssh_public_key = \\\"$PUBLIC_KEY\\\"|g\" \"$ENV_FILE\"
  else
    sed -i \"s|# ssh_public_key = .*|ssh_public_key = \\\"$PUBLIC_KEY\\\"|g\" \"$ENV_FILE\"
    sed -i \"s|ssh_public_key = .*|ssh_public_key = \\\"$PUBLIC_KEY\\\"|g\" \"$ENV_FILE\"
  fi
else
  echo \"Adding ssh_public_key to $ENV_FILE\"
  echo \"\" >> \"$ENV_FILE\"
  echo \"# SSH Public Key\" >> \"$ENV_FILE\"
  echo \"ssh_public_key = \\\"$PUBLIC_KEY\\\"\" >> \"$ENV_FILE\"
fi

echo \"✅ terraform.tfvars updated\"

echo \"\"
echo \"Step 4️⃣  - Run terraform init\"
echo \"---------------------------------\"

cd \"$TERRAFORM_DIR\"
terraform init

echo \"\"
echo \"Step 5️⃣  - Run terraform validate\"
echo \"---------------------------------\"

terraform validate

echo \"\"
echo \"Step 6️⃣  - Run terraform plan\"
echo \"---------------------------------\"

terraform plan -var-file=environments/dev.tfvars

echo \"\"
read -p \"Ready to apply? (yes/no): \" -r
if [[ \$REPLY =~ ^[Yy][Ee][Ss]\$ ]]; then
  echo \"\"
  echo \"Step 7️⃣  - Run terraform apply\"
  echo \"---------------------------------\"
  
  terraform apply -auto-approve -var-file=environments/dev.tfvars
  
  echo \"\"
  echo \"✅ Deployment complete!\"
  echo \"\"
  
  ELASTIC_IP=\$(terraform output -raw elastic_ip 2>/dev/null || echo \"<pending>\")
  
  echo \"📋 Connection Details:\"
  echo \"   Elastic IP: \$ELASTIC_IP\"
  echo \"   Private Key: ssh-keys/terraform-app-key\"
  echo \"\"
  echo \"🔐 SSH Command:\"
  echo \"   ssh -i ssh-keys/terraform-app-key ubuntu@\$ELASTIC_IP\"
  echo \"\"
else
  echo \"Deploy cancelled\"
  exit 1
fi

echo \"\"
echo \"✨ All done!\"
echo \"\"
