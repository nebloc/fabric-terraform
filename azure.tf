# Subscription that hosts the resource group and capacity.
data "azapi_resource_id" "subscription" {
  type        = "Microsoft.Resources/subscriptions@2021-10-01"
  resource_id = "/subscriptions/${var.subscription_id}"
}


# Create a resource group to host the fabric capacity. 
# If you already have a resource group you want to use, you can comment out this resource and uncomment the data source below to reference the existing resource group instead.
# IMPORTANT see note on parent_id in the capacity resource below.
resource "azapi_resource" "resource_group" {
  type      = "Microsoft.Resources/resourceGroups@2018-05-01"
  name      = var.resource_group_name
  location  = var.location
  parent_id = data.azapi_resource_id.subscription.id
}

# # Existing resource group used to host the Fabric capacity.
# data "azapi_resource" "resource_group" {
#   type      = "Microsoft.Resources/resourceGroups@2018-05-01"
#   name      = var.resource_group_name
#   parent_id = data.azapi_resource_id.subscription.id
# }

# Fabric capacity created in the resource group above.
resource "azapi_resource" "capacity" {
  type      = "Microsoft.Fabric/capacities@2023-11-01"
  name      = var.capacity_name
  parent_id = resource.azapi_resource.resource_group.id # IMPORTANT if you use an existsing capacity make sure to change the `resource.` to `data.`
  location  = var.location

  body = {
    sku = {
      tier = "Fabric"
      name = var.fabric_tier
    }
    properties = {
      administration = {
        members = concat([var.enterprise_object_id], var.administrators)
      }
    }
  }
}
