#!/bin/bash
###############################################################################
# Terraform Deployment Script
# Automates terraform init, plan, and apply
###############################################################################

set -e

echo "🏗️  Terraform Deployment for Smart Task Manager"
echo "==============================================="

cd "$(dirname "$0")/../infra/terraform"

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed"
    echo "📥 Install: https://www.terraform.io/downloads"
    exit 1
fi

# Initialize Terraform
echo ""
echo "1️⃣  Initializing Terraform..."
terraform init -upgrade

# Validate configuration
echo ""
echo "2️⃣  Validating configuration..."
terraform validate

# Format check
echo ""
echo "3️⃣  Formatting check..."
terraform fmt -check || terraform fmt -recursive

# Plan
echo ""
echo "4️⃣  Creating execution plan..."
terraform plan -out=tfplan

# Apply
echo ""
echo "5️⃣  Applying changes..."
read -p "Apply these changes? (yes/no): " -r
echo

if [[ $REPLY == "yes" ]]; then
    terraform apply tfplan
    rm tfplan
    
    echo ""
    echo "📊 Deployment Outputs:"
    terraform output
    
    echo ""
    echo "✅ Terraform deployment complete!"
    echo ""
    echo "🔍 Verify deployment:"
    echo "   kubectl get all -n \$(terraform output -raw namespace)"
else
    echo "❌ Deployment cancelled"
    rm tfplan
    exit 1
fi
