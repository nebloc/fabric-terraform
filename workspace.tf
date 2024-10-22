data "fabric_capacity" "capacity" {
  display_name = azapi_resource.capacity.name
}

resource "fabric_workspace" "workspace" {
  display_name = var.workspace_display_name
  description = "Getting started workspace"
  capacity_id = data.fabric_capacity.capacity.id
}

resource "fabric_workspace_role_assignment" "members" {
  for_each = {for idx, val in data.azuread_users.users.object_ids: idx => val}
  workspace_id   = fabric_workspace.workspace.id
  principal_id   = each.value
  principal_type = "User"
  role           = "Member"
}


resource "fabric_lakehouse" "raw" {
  display_name = "RAW"
  description  = "Lakehouse for shortcutting source data to"
  workspace_id = fabric_workspace.workspace.id

  configuration = {
    enable_schemas = true
  }
}

resource "fabric_lakehouse" "enriched" {
  display_name = "ENRICHED"
  description  = "Lakehouse for enriched and standardised data"
  workspace_id = fabric_workspace.workspace.id

  configuration = {
    enable_schemas = true
  }
}

resource "fabric_warehouse" "curated" {
  display_name = "CURATED"
  description = "Warehouse for modelled curated data products"
  workspace_id = fabric_workspace.workspace.id
}

output "CuratedConnectionString" {
  value = fabric_warehouse.curated.properties.connection_string
}
