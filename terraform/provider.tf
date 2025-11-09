terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
    helm = {
      source  = "hashicorp/helm"
      # Option 1: Pin to v2.x until gitops_bridge_bootstrap module is updated
      version = "~> 2.17, < 3.0"

      # Option 2: Use v3.x if module has been updated (uncomment and remove above)
      # version = "~> 3.0"
    }
  }
  required_version = ">= 1.1.0"
}

data "azurerm_client_config" "current" {}

provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "local_file" "kubeconfig" {
  content  = module.aks.kube_config_raw
  filename = "${path.module}/kubeconfig"
}

provider "kubernetes" {
  config_path = local_file.kubeconfig.filename
}

# Helm provider configuration
# Updated syntax for v3+ (if using helm v3.x)
provider "helm" {
  kubernetes = {
    config_path = local_file.kubeconfig.filename
  }

  # Optional: Enable experimental features
  # experiments = {
  #   manifest = true
  # }
}

# Note: If you need to use v2.x syntax, use:
# provider "helm" {
#   kubernetes {
#     config_path = local_file.kubeconfig.filename
#   }
# }

provider "random" {}
