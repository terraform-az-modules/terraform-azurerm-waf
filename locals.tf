##-----------------------------------------------------------------------------
## Locals
##-----------------------------------------------------------------------------
locals {
  label_order = var.label_order
}
#########################################
# Local Values for Azure WAF Module
#########################################

locals {
  # Merge user-provided tags with default module tag
  tags                           = var.tags
  managed_rule_set_configuration = var.managed_rule_set_configuration
}