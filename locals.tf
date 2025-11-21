##-----------------------------------------------------------------------------
## Locals
##-----------------------------------------------------------------------------
locals {
  label_order                    = var.label_order
  name                           = var.custom_name != null ? var.custom_name : module.labels.id
  managed_rule_set_configuration = var.managed_rule_set_configuration
}