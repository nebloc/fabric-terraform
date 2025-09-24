data "fabric_capacity" "capacity" {
  display_name = azapi_resource.capacity.name
}

resource "fabric_workspace" "workspace" {
  display_name = var.workspace_display_name
  description = "Getting started workspace"
  capacity_id = data.fabric_capacity.capacity.id
  identity = {
    type = "SystemAssigned"
  }
}

resource "fabric_workspace_role_assignment" "user_members" {
  for_each = {for idx, val in data.azuread_users.users.object_ids: idx => val}
  workspace_id   = fabric_workspace.workspace.id
  principal      = {
    id    = each.value
    type  = "User"
  }
  role           = "Member"
}
resource "fabric_workspace_role_assignment" "sp_members" {
  for_each = {for idx, val in var.workspace_sp_members: idx => val}
  workspace_id   = fabric_workspace.workspace.id
  principal      = {
    id    = each.value
    type  = "ServicePrincipal"
  }
  role           = "Member"
}


resource "fabric_lakehouse" "bronze" {
  display_name = "BRONZE"
  description  = "Lakehouse for shortcutting source data to"
  workspace_id = fabric_workspace.workspace.id

  configuration = {
    enable_schemas = true
  }
}

resource "fabric_lakehouse" "silver" {
  display_name = "SILVER"
  description  = "Lakehouse for enriched and standardised data"
  workspace_id = fabric_workspace.workspace.id

  configuration = {
    enable_schemas = true
  }
}

resource "fabric_warehouse" "gold" {
  display_name = "GOLD"
  description = "Warehouse for modelled Gold data products"
  workspace_id = fabric_workspace.workspace.id
}

resource "fabric_data_pipeline" "copy_pipeline_example" {
  display_name              = "Copy ADLSGEN2 to Bronze"
  description               = "example with definition bootstrapping"
  workspace_id              = fabric_workspace.workspace.id
  format                    = "Default"
  definition_update_enabled = true
  definition = {
    "pipeline-content.json" = {
      source = "./pipelines/copy_to_bronze.json"
      tokens = {
        "workspace" = fabric_workspace.workspace.id
        "bronze" = fabric_lakehouse.bronze.id
      }
    }
  }
}

resource "fabric_shortcut" "adls_gen2" {
  workspace_id  = fabric_workspace.workspace.id
  item_id       = fabric_lakehouse.bronze.id
  name          = "adls_data"
  path          = "Files/"
  target = {
    adls_gen2: {
      location: "https://becoleman.dfs.core.windows.net"
      subpath: "/data"
      connection_id: "d5e617fb-5c00-4040-90b7-db9d20cc9ecb"
    }
  }
}
output "GoldConnectionString" {
  value = fabric_warehouse.gold.properties.connection_string
}

output "BronzeLakehouseID" {
  value = fabric_lakehouse.bronze.id
}

output "WorkspaceID" {
  value = fabric_workspace.workspace.id
}
