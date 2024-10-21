# Fabric Terrafrorm Example

This project shows how terraform can be used to scaffold a data platform project. It uses `hashicorp/azuread`, `Azure/azapi` and `microsoft/fabric` providers to manage users, Azure resources and Fabric respectively.
A nix flake is included, allowing for `nix develop` to drop in to a shell with Azure CLI and terraform ready to be used.

You will need to authenticate with Azure cli as a first step with `az login`.

Create a variables file `terraform.tfvars` with the required configuration:
```toml
tenant_id = "<Azure Entra ID Tenant ID>"

subscription_id = "<Azure subscription ID>"

capacity_name = "terraformexamplecapacity"
administrators = ["<user prinicple of Fabric Capacity administrator>", "<user prinicple of Fabric Capacity administrator>"]
fabric_tier = "<default is F2>"
location = "<default is 'uk south'>"

workspace_display_name = "Data Platform"
workspace_members = ["<Other user principle names of extra users to add to the workspace>"]
```

> WARNING: the user running the scipt will be the owner of the created Lakehouse and Warehouse in Fabric. There is no way to change this at present and if the user becomes deactivated the SQL endpoints and shortcuts will be effected.
>
> Use a service principle instead to get around this. I'll be adding alternat authentication later

Run `$ terraform plan` to view what will be created;
1. Resource Group
2. Fabric Capacity
3. Fabric Workspace associated with capacity
4. Raw, Enriched and Curated Lakehouses or Warehouses
5. Member role assignments
