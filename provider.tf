terraform {
  required_version = ">= 1.8, < 2.0"
  required_providers {
    fabric = {
      source  = "microsoft/fabric"
      version = "1.6.0"
    }
    azapi = {
      source = "Azure/azapi"
      version = "2.0.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
}

# Configure the Microsoft Fabric Terraform Provider
provider "fabric" {
  # Configuration options
  tenant_id     = var.use_sp ? var.tenant_id : null
  client_id     = var.use_sp ? var.client_id : null
  client_secret = var.use_sp ? var.client_secret : null
  preview       = true
}

provider "azuread" {
  tenant_id = var.tenant_id
}
