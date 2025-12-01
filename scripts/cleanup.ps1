# Terraform Cleanup Script for PowerShell
# This script destroys all resources created by Terraform and clears the state

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Terraform Infrastructure Cleanup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Check if terraform is installed
$terraformCmd = Get-Command terraform -ErrorAction SilentlyContinue
if (-not $terraformCmd) {
    Write-Host "ERROR: Terraform is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Get current directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$tfDir = Split-Path -Parent $scriptDir

Write-Host "Working directory: $tfDir" -ForegroundColor Yellow
Write-Host ""

# Check if terraform.tfstate exists
$tfStateFile = Join-Path $tfDir "terraform.tfstate"
if (-not (Test-Path $tfStateFile)) {
    Write-Host "WARNING: No terraform.tfstate found in $tfDir" -ForegroundColor Yellow
    Write-Host "This means no resources have been created yet, or state has already been cleared." -ForegroundColor Yellow
    exit 0
}

# Confirm before destroying
Write-Host "WARNING: This will destroy ALL infrastructure resources created by Terraform!" -ForegroundColor Red
Write-Host "This includes:" -ForegroundColor Red
Write-Host "  - EC2 instances" -ForegroundColor Red
Write-Host "  - Elastic IPs" -ForegroundColor Red
Write-Host "  - VPC and subnets" -ForegroundColor Red
Write-Host "  - Security groups" -ForegroundColor Red
Write-Host "  - And all other managed resources" -ForegroundColor Red
Write-Host ""

$confirm = Read-Host "Are you sure you want to proceed? (type 'yes' to confirm)"

if ($confirm -ne "yes") {
    Write-Host "Cleanup cancelled." -ForegroundColor Yellow
    exit 0
}

Push-Location $tfDir

Write-Host ""
Write-Host "Running terraform destroy..." -ForegroundColor Yellow
terraform destroy -auto-approve

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Removing Terraform state files..." -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Remove state files
if (Test-Path "terraform.tfstate") {
    Remove-Item "terraform.tfstate" -Force
    Write-Host "✓ Removed terraform.tfstate" -ForegroundColor Green
}

if (Test-Path "terraform.tfstate.backup") {
    Remove-Item "terraform.tfstate.backup" -Force
    Write-Host "✓ Removed terraform.tfstate.backup" -ForegroundColor Green
}

# Remove .terraform directory and lock file
if (Test-Path ".terraform") {
    Remove-Item ".terraform" -Recurse -Force
    Write-Host "✓ Removed .terraform directory" -ForegroundColor Green
}

if (Test-Path ".terraform.lock.hcl") {
    Remove-Item ".terraform.lock.hcl" -Force
    Write-Host "✓ Removed .terraform.lock.hcl" -ForegroundColor Green
}

Pop-Location

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Cleanup Complete!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Green
Write-Host "  ✓ All infrastructure resources destroyed" -ForegroundColor Green
Write-Host "  ✓ Terraform state files removed" -ForegroundColor Green
Write-Host "  ✓ Terraform lock files removed" -ForegroundColor Green
Write-Host ""
Write-Host "The workspace is now clean and ready for re-deployment." -ForegroundColor Green
Write-Host ""
