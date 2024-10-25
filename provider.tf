terraform {
  required_version = ">= 1.8, < 2.0"
  required_providers {
    fabric = {
      source  = "microsoft/fabric"
      version = "0.1.0-beta.4"
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
}

provider "azuread" {
  tenant_id = var.tenant_id
}
