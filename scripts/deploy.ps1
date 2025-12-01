# Terraform Deployment Script for PowerShell
# This script initializes and deploys the infrastructure with Vault integration

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Terraform Infrastructure Deployment" -ForegroundColor Cyan
Write-Host "With HashiCorp Vault Secret Management" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if terraform is installed
$terraformCmd = Get-Command terraform -ErrorAction SilentlyContinue
if (-not $terraformCmd) {
    Write-Host "ERROR: Terraform is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Terraform from: https://www.terraform.io/downloads" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Terraform is installed: $(terraform version -json | ConvertFrom-Json | Select-Object -ExpandProperty terraform_version)" -ForegroundColor Green
Write-Host ""

# Check Vault connectivity if enabled
$enableVault = (Get-Content terraform.tfvars | Select-String "enable_vault\s*=\s*true" -Quiet)
if ($enableVault) {
    Write-Host "Checking Vault connectivity..." -ForegroundColor Yellow
    $vaultAddress = (Get-Content terraform.tfvars | Select-String "vault_address" | Select-Object -First 1)
    Write-Host "Vault configured: $vaultAddress" -ForegroundColor Green
    Write-Host ""
}

# Get current directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$tfDir = Split-Path -Parent $scriptDir

Write-Host "Working directory: $tfDir" -ForegroundColor Yellow
Write-Host ""

Push-Location $tfDir

# Step 1: Terraform Init
Write-Host "Step 1: Initializing Terraform..." -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow
terraform init
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Terraform init failed" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "✓ Terraform initialized successfully" -ForegroundColor Green
Write-Host ""

# Step 2: Validate configuration
Write-Host "Step 2: Validating Terraform configuration..." -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow
terraform validate
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Terraform validation failed" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "✓ Configuration is valid" -ForegroundColor Green
Write-Host ""

# Step 3: Format check
Write-Host "Step 3: Checking Terraform formatting..." -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow
terraform fmt -check -recursive
if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Some files may not be properly formatted" -ForegroundColor Yellow
    Write-Host "Running terraform fmt to fix formatting..." -ForegroundColor Yellow
    terraform fmt -recursive
}
Write-Host "✓ Formatting check complete" -ForegroundColor Green
Write-Host ""

# Step 4: Plan
Write-Host "Step 4: Creating Terraform plan..." -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow
terraform plan -out=tfplan
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Terraform plan failed" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "✓ Plan created successfully" -ForegroundColor Green
Write-Host ""

# Step 5: Ask for confirmation
Write-Host "Step 5: Confirmation" -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow
Write-Host ""
Write-Host "Review the plan above to ensure it matches your expectations." -ForegroundColor Yellow
Write-Host "This will deploy:" -ForegroundColor Yellow
Write-Host "  • VPC and subnet" -ForegroundColor White
Write-Host "  • EC2 instance with Docker" -ForegroundColor White
Write-Host "  • Elastic IP (fixed)" -ForegroundColor White
if ($enableVault) {
    Write-Host "  • HashiCorp Vault secrets integration" -ForegroundColor White
}
Write-Host ""

$confirm = Read-Host "Do you want to apply these changes? (type 'yes' to confirm)"

if ($confirm -ne "yes") {
    Write-Host ""
    Write-Host "Deployment cancelled. Plan saved as 'tfplan'." -ForegroundColor Yellow
    Pop-Location
    exit 0
}

Write-Host ""

# Step 6: Apply
Write-Host "Step 6: Applying Terraform configuration..." -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow
terraform apply tfplan
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Terraform apply failed" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "✓ Infrastructure deployed successfully" -ForegroundColor Green
Write-Host ""

# Step 7: Output
Write-Host "Step 7: Deployment Summary" -ForegroundColor Yellow
Write-Host "---------------------------------------" -ForegroundColor Yellow
terraform output deployment_summary
if ($enableVault) {
    Write-Host ""
    Write-Host "Vault Integration:" -ForegroundColor Yellow
    terraform output vault_integration_status
}
Write-Host ""

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  terraform output                     # View all outputs" -ForegroundColor White
Write-Host "  terraform show                       # Show current state" -ForegroundColor White
Write-Host "  terraform plan                       # Create a new plan" -ForegroundColor White
Write-Host "  terraform destroy                    # Destroy all resources" -ForegroundColor White
Write-Host "  .\scripts\cleanup.ps1               # Full cleanup with state removal" -ForegroundColor White
Write-Host ""

Pop-Location

