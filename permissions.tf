##-----------------------------------------------------------------------------
## Permissions, Roles, and Policies
##-----------------------------------------------------------------------------
variable "assign_contributor_role" {
  description = "Whether to assign Contributor role to WAF (optional)"
  type        = bool
  default     = false
}

variable "role_assignment_scope" {
  description = "Scope for role assignment (subscription or resource group)"
  type        = string
  default     = null
}

variable "principal_ids" {
  description = "List of principal IDs to assign role to (optional)"
  type        = list(string)
  default     = []
}

resource "azurerm_role_assignment" "waf_contributor" {
  count = var.assign_contributor_role && var.role_assignment_scope != null ? length(var.principal_ids) : 0

  scope                = var.role_assignment_scope
  role_definition_name = "Contributor"
  principal_id         = var.principal_ids[count.index]
}
