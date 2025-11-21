##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------
output "label_order" {
  value       = local.label_order
  description = "Label order."
}

output "waf_policy_id" {
  value       = azurerm_web_application_firewall_policy.waf[0].id
  description = "The ID of the Azure WAF policy."
}

output "waf_policy_name" {
  value       = azurerm_web_application_firewall_policy.waf[0].name
  description = "The name of the WAF policy."
}

output "waf_policy_mode" {
  value       = azurerm_web_application_firewall_policy.waf[0].policy_settings[0].mode
  description = "The mode of the WAF policy."
}

output "waf_policy_enabled" {
  value       = azurerm_web_application_firewall_policy.waf[0].policy_settings[0].enabled
  description = "Whether the WAF policy is enabled."
}

output "waf_tags" {
  value       = azurerm_web_application_firewall_policy.waf[0].tags
  description = "Tags applied to the WAF policy."
}

output "waf_managed_rule_sets" {
  value       = var.managed_rule_set_configuration
  description = "Managed rule set configuration used in this WAF policy."
}

output "waf_exclusion_rules" {
  value       = var.exclusion_configuration
  description = "Exclusion configuration applied to the WAF policy."
}

output "waf_custom_rules" {
  value       = var.custom_rules_configuration
  description = "Custom rules configured inside the WAF policy."
}