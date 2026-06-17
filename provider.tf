terraform {
  required_version = ">= 1.8, < 2.0"
  required_providers {
    fabric = {
      source  = "microsoft/fabric"
      version = "~> 1.11"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.10"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.1.0"
    }
  }
}

# Configure the Microsoft Fabric Terraform Provider.
provider "fabric" {
  tenant_id     = var.tenant_id
  client_id     = var.client_id
  client_secret = var.client_secret
  preview       = true
}

# Configure the Azure Resource Manager provider for creating the resource group and fabric capacity.
provider "azapi" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

# Configure the Azure AD provider to retrieve user object ids for workspace role assignments.
provider "azuread" {
  tenant_id = var.tenant_id
}
