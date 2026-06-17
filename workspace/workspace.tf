terraform {
  required_providers {
    fabric = {
      source  = "microsoft/fabric"
      version = "~> 1.11"
    }
  }
}

variable "workspace_name" {
  description = "Name of the workspace"
  type        = string
}

variable "description" {
  description = "Description of the workspace"
  type = string
}

variable "capacity" {
  description = "The capacity id to assign the workspace to"
  type = string
}

variable "users" {
  description = "Users to assign to the workspace"
  type        = list(string)
}

variable "users_role" {
  description = "The role to give users within the workspace"
  type        = string
}

# Create a Fabric workspace with Workspace Identity enabled
resource "fabric_workspace" "workspace" {
  display_name = var.workspace_name
  description  = var.description
  capacity_id  = var.capacity
}

# Assign users to the admin role for the workspace. This has to be done with the user's object id, 
# which can be found in the Azure portal or retrieved via the Microsoft Graph API.
resource "fabric_workspace_role_assignment" "users" {
  for_each     = { for idx, val in var.users : idx => val }
  workspace_id = fabric_workspace.workspace.id
  principal = {
    id   = each.value
    type = "User"
  }
  role = var.users_role
}

# Create an empty demo lakehouse 
resource "fabric_lakehouse" "lakehouse" {
  display_name = "DemoLakehouse"
  description  = "Lakehouse"
  workspace_id = fabric_workspace.workspace.id

  configuration = {
    enable_schemas = true
  }
}

# Create a lakehouse to be used for shortcut testing.
resource "fabric_lakehouse" "lakehouse_shortcut" {
  display_name = "DemoLakehouse_shortcut"
  description  = "Lakehouse"
  workspace_id = fabric_workspace.workspace.id

  configuration = {
    enable_schemas = true
  }
}

# Create an empty demo warehouse
resource "fabric_warehouse" "warehouse" {
  display_name = "DemoWarehouse"
  description  = "Warehouse"
  workspace_id = fabric_workspace.workspace.id
}

# Outputs are used to retrieve the resource ids of the created resources, which can be used to reference these resources in other modules or for retrieving the resources after deployment.
output "workspace_id" {
  value = fabric_workspace.workspace.id
}
output "lakehouse_id" {
  value = fabric_lakehouse.lakehouse.id
}
output "warehouse_id" {
  value = fabric_warehouse.warehouse.id
}
