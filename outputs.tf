##-----------------------------------------------------------------------------
## Outputs
##-----------------------------------------------------------------------------
output "label_order" {
  value       = local.label_order
  description = "Label order."
}

output "waf_policy_id" {
  description = "The ID of the Azure WAF policy."
  value       = azurerm_web_application_firewall_policy.waf.id
}

output "waf_policy_name" {
  description = "The name of the WAF policy."
  value       = azurerm_web_application_firewall_policy.waf.name
}

output "waf_policy_mode" {
  description = "The mode of the WAF policy."
  value       = azurerm_web_application_firewall_policy.waf.policy_settings[0].mode
}

output "waf_policy_enabled" {
  description = "Whether the WAF policy is enabled."
  value       = azurerm_web_application_firewall_policy.waf.policy_settings[0].enabled
}

output "waf_managed_rule_sets" {
  description = "Managed rule set configuration used in this WAF policy."
  value       = var.managed_rule_set_configuration
}

output "waf_exclusion_rules" {
  description = "Exclusion configuration applied to the WAF policy."
  value       = var.exclusion_configuration
}

output "waf_custom_rules" {
  description = "Custom rules configured inside the WAF policy."
  value       = var.custom_rules_configuration
}

output "waf_tags" {
  description = "Tags applied to the WAF policy."
  value       = azurerm_web_application_firewall_policy.waf.tags
}