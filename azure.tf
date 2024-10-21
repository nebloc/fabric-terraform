resource "azurerm_resource_group" "fabricterraform" {
   name     = "fabricterraform-rg"
   location = var.location
}

resource "azapi_resource" "capacity" {
  type      = "Microsoft.Fabric/capacities@2023-11-01"
  name      = var.capacity_name
  parent_id = azurerm_resource_group.fabricterraform.id

  location = azurerm_resource_group.fabricterraform.location

  body = {
    sku = {
      tier = "Fabric"
      name = var.fabric_tier
    }
    properties = {
      administration = {
        members = var.administrators
      }
    }
  }
}

data "azuread_users" "users" {
  user_principal_names = var.workspace_members
}