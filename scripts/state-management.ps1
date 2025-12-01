# Terraform State Management Utility Script (PowerShell)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Terraform State Management Utility" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Choose an option:" -ForegroundColor Yellow
Write-Host "1. Show current state" -ForegroundColor White
Write-Host "2. List state resources" -ForegroundColor White
Write-Host "3. Show specific resource from state" -ForegroundColor White
Write-Host "4. Clear local state files (keep AWS resources)" -ForegroundColor White
Write-Host "5. Remove specific resource from state (DANGEROUS)" -ForegroundColor Red
Write-Host "6. Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-6)"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$tfDir = Split-Path -Parent $scriptDir

Push-Location $tfDir

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Current Terraform State:" -ForegroundColor Yellow
        Write-Host "---------------------------------------" -ForegroundColor Yellow
        terraform show
    }
    
    "2" {
        Write-Host ""
        Write-Host "State Resources:" -ForegroundColor Yellow
        Write-Host "---------------------------------------" -ForegroundColor Yellow
        terraform state list
    }
    
    "3" {
        Write-Host ""
        $resource = Read-Host "Enter resource name (e.g., module.vpc.aws_vpc.main)"
        terraform state show $resource
    }
    
    "4" {
        Write-Host ""
        Write-Host "WARNING: This will remove local state files but keep AWS resources" -ForegroundColor Yellow
        $confirm = Read-Host "Continue? (type 'yes' to confirm)"
        
        if ($confirm -eq "yes") {
            if (Test-Path "terraform.tfstate") {
                Remove-Item "terraform.tfstate" -Force
                Write-Host "✓ Removed terraform.tfstate" -ForegroundColor Green
            }
            if (Test-Path "terraform.tfstate.backup") {
                Remove-Item "terraform.tfstate.backup" -Force
                Write-Host "✓ Removed terraform.tfstate.backup" -ForegroundColor Green
            }
            Write-Host ""
            Write-Host "State files cleared. AWS resources remain untouched." -ForegroundColor Green
        }
    }
    
    "5" {
        Write-Host ""
        Write-Host "WARNING: Removing a resource from state will cause Terraform to orphan it!" -ForegroundColor Red
        Write-Host "The AWS resource will continue to exist but won't be managed by Terraform." -ForegroundColor Red
        Write-Host ""
        $resource = Read-Host "Enter resource address to remove"
        $confirm = Read-Host "Type 'yes' to confirm removal of $resource"
        
        if ($confirm -eq "yes") {
            terraform state rm $resource
            Write-Host "✓ Resource removed from state" -ForegroundColor Green
        } else {
            Write-Host "Cancelled" -ForegroundColor Yellow
        }
    }
    
    "6" {
        Write-Host "Exiting..." -ForegroundColor Yellow
    }
    
    default {
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
    }
}

Pop-Location
Write-Host ""
