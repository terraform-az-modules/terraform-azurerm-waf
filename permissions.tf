##-----------------------------------------------------------------------------
## Permissions, Roles, and Policies
##-----------------------------------------------------------------------------
# resource "azurerm_role_assignment" "waf_contributor" {
#   count = var.assign_contributor_role && var.role_assignment_scope != null ? length(var.principal_ids) : 0

#   scope                = var.role_assignment_scope
#   role_definition_name = "Contributor"
#   principal_id         = var.principal_ids[count.index]
# }
resource "azurerm_role_assignment" "waf_contributor" {
  for_each = var.assign_contributor_role && var.role_assignment_scope != null ? toset(var.principal_ids) : []

  scope                = var.role_assignment_scope
  role_definition_name = "Contributor"
  principal_id         = each.value
}