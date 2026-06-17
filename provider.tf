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
  backend "azurerm" {
    use_oidc                         = true                                    # Can also be set via `ARM_USE_OIDC` environment variable.
    oidc_azure_service_connection_id = "00000000-0000-0000-0000-000000000000"  # Can also be set via `ARM_OIDC_AZURE_SERVICE_CONNECTION_ID` environment variable.
    use_azuread_auth                 = true                                    # Can also be set via `ARM_USE_AZUREAD` environment variable.
    tenant_id                        = "00000000-0000-0000-0000-000000000000"  # Can also be set via `ARM_TENANT_ID` environment variable.
    client_id                        = "00000000-0000-0000-0000-000000000000"  # Can also be set via `ARM_CLIENT_ID` environment variable.
    storage_account_name             = "abcd1234"                              # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name                   = "tfstate"                               # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                              = "prod.terraform.tfstate"                # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
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
