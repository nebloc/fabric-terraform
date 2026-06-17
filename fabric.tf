# Get the Fabric Capacity so we can use it for workspace assignment.
# The Fabric terraform provider doesn't provide a way to create a capacity, so we do that separately and then make it a dependency by referencing it's output.
data "fabric_capacity" "capacity" {
  # If Capacity already exists replace below with existing name
  display_name = azapi_resource.capacity.name
  lifecycle {
    postcondition {
      condition     = self.state == "Active"
      error_message = "Fabric Capacity is not in Active state. Please check the Fabric Capacity status."
    }
  }
}

# This is used to retrieve the object ids of the users to assign workspace roles to, based on their user principal names (email addresses).
# The Azure AD provider is used for this purpose.
data "azuread_users" "users" {
  user_principal_names = var.workspace_admins
}

# Module workspace is reused to create multiple workspaces for different environments (dev, test, prod).
# The capacity and workspace admins are passed in as variables to the module. The outputs of the module are used to retrieve the resource ids of the created resources.
locals {
  environments = {
    dev  = {
      desc = "Development environment"
      users_role = "Viewer"
    }
    test  = {
      desc = "Testing environment"
      users_role = "Viewer"
    }
    prod  = {
      desc = "Production environment"
      users_role = "Viewer"
    }
    feature = {
      desc = "Feature workspace for development"
      users_role = "Admin"
    }
  }
}

module "workspace" {
  source   = "./workspace"
  for_each = local.environments # Loop over the environments to create multiple workspaces

  workspace_name = "${var.workspace_name_prefix}-${each.key}"
  description    = each.value.desc

  capacity         = data.fabric_capacity.capacity.id
  users = data.azuread_users.users.object_ids
  users_role = each.value.users_role
}

# Fabric Connection for generic CopyJob to be used in pipelines.
resource "fabric_connection" "copyjob" {
  display_name                        = "CopyJob"
  connectivity_type                   = "ShareableCloud"
  privacy_level                       = "Organizational"
  allow_usage_in_user_controlled_code = true
  connection_details = {
    creation_method = "CopyJob.Actions"
    type            = "CopyJob"
    parameters = [ ]
  }
  credential_details = {
    credential_type       = "ServicePrincipal"
    service_principal_credentials = {
      client_id                 = var.client_id
      client_secret_wo          = var.client_secret
      client_secret_wo_version  = 1 # Need to bump this if the secret is rotated
      tenant_id                 = var.tenant_id
    }
  }
}

# Assign Workspace Admins to the CopyJob connection.
resource "fabric_connection_role_assignment" "copyjob_admins" {
  for_each = toset(data.azuread_users.users.object_ids)
  connection_id = fabric_connection.copyjob.id
  principal = {
    id = each.value
    type = "User"
  }
  role = "Owner"
}

# TODO: Use Key Vault to store the client secret and retrieve it in the fabric_connection resource above.

output "workspace_ids" {
  description = "Map of environment name to workspace id."
  value       = { for env, mod in module.workspace : env => mod.workspace_id }
}

output "lakehouse_ids" {
  description = "Map of environment name to lakehouse id."
  value       = { for env, mod in module.workspace : env => mod.lakehouse_id }
}

output "warehouse_ids" {
  description = "Map of environment name to warehouse id."
  value       = { for env, mod in module.workspace : env => mod.warehouse_id }
}

output "copyjob_connection_id" {
  description = "The id of the CopyJob connection."
  value       = fabric_connection.copyjob.id
}
