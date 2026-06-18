variable "workspace_name_prefix" {
  description = "A name for the workspaces to be suffixed with environment."
  type        = string
}

variable "capacity_name" {
  description = "The name of the capacity to use."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to create or use."
  type        = string
}

variable "subscription_id" {
  description = "The id of the Azure Subscription"
  type        = string
}

variable "capacity_administrators" {
  description = "Array list of capacity admin emails"
  type        = list(string)
}

variable "workspace_admins" {
  description = "Array of emails to be workspace admins"
  type        = list(string)
  default     = []
}


variable "tenant_id" {
  description = "Tenant ID for Entra"
  type        = string
}

variable "fabric_tier" {
  description = "The tier of Fabric Capacity, i.e. F2, F4"
  default     = "F2"
  type        = string
}

variable "location" {
  description = "Azure region for the Fabric capacity (no spaces, e.g. uksouth, westus3)."
  default     = "uksouth"
  type        = string
}

variable "client_id" {
  description = "Service principal client ID. Required when use_sp = true."
  type        = string
  default     = null
  sensitive   = true
}

variable "enterprise_object_id" {
  description = "Service principal Enterprise Application Object ID. Required when use_sp = true."
  type        = string
  default     = null
  sensitive   = true
}

variable "client_secret" {
  description = "Service principal client secret. Required when use_sp = true."
  type        = string
  default     = null
  sensitive   = true
}
