# Copilot Instructions

## Commands

```bash
# Dev shell (Nix)
nix develop

# Formatting
terraform fmt -recursive

# Validate (requires init first)
terraform init -backend=false   # local-only, skips remote state
terraform validate

# Plan / Apply
terraform plan -out=tfplan
terraform apply tfplan

# Target a single environment
terraform apply -target='module.workspace["dev"]'
```

There are no automated tests. Validation is `terraform fmt -check -recursive && terraform validate`.

## Architecture

This is a flat Terraform root module that provisions a Microsoft Fabric CI/CD lab across multiple environments (dev, test, prod, feature).

**Root module** (`*.tf` in repo root):
- `provider.tf` — Terraform version constraints, provider configs (fabric, azapi, azuread), and azurerm backend for remote state.
- `azure.tf` — Resource Group and Fabric Capacity via the `azapi` provider (ARM-level resources).
- `fabric.tf` — Looks up the capacity, resolves UPN→object-id via `azuread_users`, invokes the `workspace` module per environment, and creates a shared `fabric_connection` for CopyJob.
- `variables.tf` — All root input variables. Sensitive values (`client_id`, `client_secret`, `enterprise_object_id`) are marked `sensitive = true`.

**Child module** (`./workspace/workspace.tf`):
- Called once per key in `local.environments` (defined in `fabric.tf`).
- Creates: Fabric Workspace → role assignments → two Lakehouses (schemas enabled) → one Warehouse.
- Outputs resource IDs consumed by root outputs.

**CI/CD** (`azure-pipelines.yml`):
- Azure DevOps pipeline with stages: Validate → Plan → Apply.
- Apply only runs on `main` branch and requires environment approval.
- All secrets come from a variable group named `fabric-terraform` backed by Key Vault.
- Backend config is passed at `terraform init` via `-backend-config` flags.

## Conventions

- Use `azapi` (not `azurerm`) for ARM resources — this gives direct control over API versions for Fabric capacity.
- The `fabric` provider requires `preview = true` for preview-gated resources.
- Environments are defined in `local.environments` map in `fabric.tf` — add new environments there.
- Workspace admins are resolved from UPNs to object IDs via `data "azuread_users"` — always pass UPNs (email addresses), not object IDs, in variables.
- All root outputs are maps keyed by environment name.
- Never commit `terraform.tfvars` — it contains secrets. Use `TF_VAR_*` env vars or a variable group in CI.
- When switching to an existing resource group, change `resource.azapi_resource.resource_group` references to `data.azapi_resource.resource_group` in `azure.tf`.
- Nix flake (`flake.nix`) provides the dev shell with terraform and azure-cli.
