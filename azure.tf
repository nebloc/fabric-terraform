# GET Subscription data
data "azapi_resource_id" "subscription" {
  type        = "Microsoft.Resources/subscriptions@2021-10-01"
  resource_id = "/subscriptions/${var.subscription_id}"
}

# CREATE resource group in subscription
resource "azapi_resource" "resource_group" {
  type = "Microsoft.Resources/resourceGroups@2018-05-01"
  name = "fabricterraform-rg"
  location = var.location
  parent_id = data.azapi_resource_id.subscription.id
}

# CREATE capacity in resource group
resource "azapi_resource" "capacity" {
  type      = "Microsoft.Fabric/capacities@2023-11-01"
  name      = var.capacity_name
  parent_id = azapi_resource.resource_group.id

  location = azapi_resource.resource_group.location

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

# Get users  from Azure Entra ID  
data "azuread_users" "users" {
  user_principal_names = var.workspace_members
}


# TODO: Solve issue of resource actions not waiting until resource is ready
# resource "azapi_resource_action" "start" {
#   type                   = "Microsoft.Fabric/capacities@2023-11-01"
#   resource_id            = azapi_resource.capacity.id
#   action                 = "resume"
#   response_export_values = ["*"]
#   depends_on = [azapi_resource.capacity]
#
#   count = var.enabled ? 1 : 0
# }
#
# resource "azapi_resource_action" "stop" {
#   type                   = "Microsoft.Fabric/capacities@2023-11-01"
#   resource_id            = azapi_resource.capacity.id
#   action                 = "suspend"
#   response_export_values = ["*"]
#   depends_on = [azapi_resource.capacity]
#
#   count = var.enabled ? 0 : 1
# }
