variable "workspace_display_name" {
  description = "A name for the getting started workspace."
  type        = string
}

variable "capacity_name" {
  description = "The name of the capacity to use."
  type = string
}

variable "subscription_id" {
  description = "The id of the Azure Subscription"
  type = string
}

variable "administrators" {
  description = "Array list of capacity admin emails"
  type = list(string) 
}

variable "workspace_members" {
  description = "Array of users emails to be workspace members"
  type = list(string)
}

variable "tenant_id" {
  description = "Tenant ID for Entra"
  type = string
}

variable "fabric_tier" {
  description = "The tier of Fabric Capacity, i.e. F2, F4"
  default = "F2"
  type = string
}

variable "location" {
  description = "Azure region"
  default = "uk south"
  type = string
}

variable "enabled" {
  description = "Pause or resume capacity"
  default = false
  type = bool
}
