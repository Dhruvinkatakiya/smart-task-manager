###############################################################################
# Terraform Provider Configuration
###############################################################################

terraform {
  required_version = ">= 1.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }

  # Optional: Remote backend for state management (uncomment for production)
  # backend "s3" {
  #   bucket = "my-terraform-state-bucket"
  #   key    = "smart-task-manager/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Kubernetes Provider - Uses local kubeconfig or environment variable
provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kube_context
}

