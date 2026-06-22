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
  # State is stored in an Azure Storage account and authenticated with the
  # service principal supplied by the Azure DevOps pipeline. Authentication
  # (tenant_id / client_id / client_secret / subscription_id) is taken from the
  # ARM_* environment variables exported in the pipeline, and the storage
  # account / container / key are passed at init time via -backend-config.
  backend "azurerm" {
    use_azuread_auth = true # Authenticate to the storage account as the SPN via Entra ID (`ARM_USE_AZUREAD`).
  }
}

# Configure the Microsoft Fabric Terraform Provider.
# Authenticates via FABRIC_TENANT_ID, FABRIC_CLIENT_ID, FABRIC_CLIENT_SECRET env vars.
provider "fabric" {
  preview = true
}

# Configure the Azure Resource Manager provider for creating the resource group and fabric capacity.
# Authenticates via ARM_TENANT_ID, ARM_SUBSCRIPTION_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET env vars.
provider "azapi" {}

# Configure the Azure AD provider to retrieve user object ids for workspace role assignments.
# Authenticates via ARM_TENANT_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET env vars.
provider "azuread" {}
