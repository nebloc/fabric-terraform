# Fabric Terrafrorm Example

This project shows how terraform can be used to scaffold a data platform project. It uses [hashicorp/azuread](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs), [Azure/azapi](https://registry.terraform.io/providers/Azure/azapi/latest/docs), [hashicorp/azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) and [microsoft/fabric](https://registry.terraform.io/providers/microsoft/fabric/latest/docs) providers to manage users, resource groups, Fabric capacities and Fabric itself respectively.
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

## Creating a Shortcut

The script `create.sh` will run terraform apply, and then use the output and az-cli to perform a [REST API call to create a shortcut](https://learn.microsoft.com/en-us/rest/api/fabric/core/onelake-shortcuts/create-shortcut?tabs=HTTP#code-try-0)

It does this by sending the body from a file called req.json. This is ommitted from the git repo but can be created based on the following template:
```json
{
  "path": "Files",
  "name": "<shortcut_name>",
  "target": {
    "type": "AdlsGen2",
    "adlsGen2": {
      "location": "https://<storageaccount>.dfs.core.windows.net",
      "subpath": "/<container_name>/<path>",
      "connectionId": "<connection_id>"
    }
  }
}
```
> The connection will need to be created in the Fabric `Manage Connections and Gateways` menu ahead of this and the connection ID captured for the request.
