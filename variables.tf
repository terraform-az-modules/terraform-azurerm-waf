##-----------------------------------------------------------------------------
## Variables
##-----------------------------------------------------------------------------
variable "label_order" {
  type        = list(any)
  default     = ["name", "environment", "location"]
  description = "Label order, e.g. `name`,`application`,`centralus`."
}
variable "custom_name" {
  type        = string
  default     = null
  description = "Override default naming convention"
}

variable "name" {
  type        = string
  description = "Name of the WAF policy"
}

variable "location" {
  type        = string
  description = "Azure region where the WAF policy will be deployed"
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
}

variable "managedby" {
  type        = string
  default     = "terraform-az-modules"
  description = "ManagedBy, eg 'terraform-az-modules'."
}

variable "repository" {
  type        = string
  default     = "https://github.com/terraform-az-modules/terraform-azure-key-vault"
  description = "Terraform current module repo"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^https://", var.repository))
    error_message = "The module-repo value must be a valid Git repo link."
  }
}

variable "deployment_mode" {
  type        = string
  default     = "terraform"
  description = "Specifies how the infrastructure/resource is deployed"
}

variable "extra_tags" {
  type        = map(string)
  default     = null
  description = "Variable to pass extra tags."
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name where the WAF policy will be created"
}

variable "assign_contributor_role" {
  type        = bool
  default     = false
  description = "Whether to assign Contributor role to WAF (optional)"
}

variable "role_assignment_scope" {
  type        = string
  default     = null
  description = "Scope for role assignment (subscription or resource group)"
}

variable "principal_ids" {
  type        = list(string)
  default     = []
  description = "List of principal IDs to assign role to (optional)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the WAF policy"
}

variable "policy_enabled" {
  type        = bool
  default     = true
  description = "Describes if the policy is in `enabled` state or `disabled` state. Defaults to `true`."
}

variable "policy_mode" {
  type        = string
  default     = "Prevention"
  description = "Describes if it is in detection mode or prevention mode at the policy level. Valid values are `Detection` and `Prevention`. Defaults to `Prevention`."
}

variable "policy_file_limit" {
  type        = number
  nullable    = false
  default     = 100
  description = "Policy regarding the size limit of uploaded files. Value is in MB. Accepted values are in the range `1` to `4000`. Defaults to `100`."

  validation {
    condition     = var.policy_file_limit >= 1 && var.policy_file_limit <= 4000
    error_message = "The policy_file_limit parameter can only have a value comprised between 1 and 4000."
  }
}

variable "policy_request_body_check_enabled" {
  type        = bool
  default     = true
  description = "Describes if the Request Body Inspection is enabled. Defaults to `true`."
}

variable "policy_max_body_size" {
  type        = number
  default     = 128
  description = "Policy regarding the maximum request body size. Value is in KB. Accepted values are in the range `8` to `2000`. Defaults to `128`."

  validation {
    condition     = var.policy_max_body_size >= 8 && var.policy_max_body_size <= 2000
    error_message = "The policy_max_body_size parameter can only have a value comprised between 8(Kb) and 2000(Kb)."
  }
}

# variable "managed_rule_set_configuration" {
#   type = list(object({
#     type        = string
#     version     = string
#     description = <<EOF
#     List of managed rule sets for the WAF policy.
#     Example:
#     [
#       {
#         type    = "OWASP"
#         version = "3.2"
#         rule_group_overrides = [
#           {
#             rule_group_name = "SQLI"
#             rules = [
#               { rule_id = "942100", action = "Disabled" }
#             ]
#           }
#         ]
#       }
#     ]
#     EOF

#     rule_group_overrides = optional(list(object({
#       rule_group_name = string
#       rules = list(object({
#         rule_id = string
#         action  = string
#       }))
#     })))
#   }))

#   default = []
# }
variable "managed_rule_set_configuration" {
  type = list(object({
    type    = string
    version = string
    rule_group_override_configuration = optional(list(object({
      rule_group_name = string
      rule = list(object({
        id      = string
        enabled = bool
        action  = string
      }))
    })))
  }))
  description = <<EOF
      List of managed rule sets for the WAF policy.
      Example:
      [
        {
          type    = "OWASP"
          version = "3.2"
          rule_group_override_configuration = [
            {
              rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
              rule = [
                { id = "942100", enabled = false, action = "AnomalyScoring" }
              ]
            }
          ]
        }
      ]
      EOF

  default = []
}

variable "custom_rules_configuration" {
  type = list(object({
    name      = optional(string)
    priority  = optional(number)
    rule_type = optional(string)
    action    = optional(string)
    match_conditions_configuration = optional(list(object({
      match_variable_configuration = optional(list(object({
        variable_name = optional(string)
        selector      = optional(string, null)
      })))
      match_values       = optional(list(string))
      operator           = optional(string)
      negation_condition = optional(bool, false)
      transforms         = optional(list(string), null)
    })))
  }))
  description = <<EOD
      Custom rules configuration object with following attributes:
      ```
      - name:                           Gets name of the resource that is unique within a policy. This name can be used to access the resource.
      - priority:                       Describes priority of the rule. Rules with a lower value will be evaluated before rules with a higher value.
      - rule_type:                      Describes the type of rule. Possible values are `MatchRule` and `Invalid`.
      - action:                         Type of action. Possible values are `Allow`, `Block` and `Log`.
      - match_conditions_configuration: One or more `match_conditions` blocks as defined below.
      - match_variable_configuration:   One or more match_variables blocks as defined below.
      - variable_name:                  The name of the Match Variable. Possible values are RemoteAddr, RequestMethod, QueryString, PostArgs, RequestUri, RequestHeaders, RequestBody and RequestCookies.
      - selector:                       Describes field of the matchVariable collection
      - match_values:                   A list of match values.
      - operator:                       Describes operator to be matched. Possible values are IPMatch, GeoMatch, Equal, Contains, LessThan, GreaterThan, LessThanOrEqual, GreaterThanOrEqual, BeginsWith, EndsWith and Regex.
      - negation_condition:             Describes if this is negate condition or not
      - transforms:                     A list of transformations to do before the match is attempted. Possible values are HtmlEntityDecode, Lowercase, RemoveNulls, Trim, UrlDecode and UrlEncode.
      ```
      EOD
  default     = []
}

variable "exclusion_configuration" {
  type = list(object({
    match_variable          = optional(string)
    selector                = optional(string)
    selector_match_operator = optional(string)
    excluded_rule_set = optional(list(object({
      type    = optional(string, "OWASP")
      version = optional(string, "3.2")
      rule_group = optional(list(object({
        rule_group_name = string
        excluded_rules  = optional(list(string), [])
      })), [])
    })), [])
  }))
  description = <<EOD
      Exclusion rules configuration object with following attributes:
      ```
      - match_variable:          The name of the Match Variable. Accepted values can be found [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy#match_variable).
      - selector:                Describes field of the matchVariable collection.
      - selector_match_operator: Describes operator to be matched. Possible values: `Contains`, `EndsWith`, `Equals`, `EqualsAny`, `StartsWith`.
      - excluded_rule_set:       One or more `excluded_rule_set` block defined below.
        - type:                  The rule set type. The only possible value is `OWASP`. Defaults to `OWASP`.
        - version:               The rule set version. The only possible value is `3.2`. Defaults to `3.2`.
        - rule_group:            One or more `rule_group` block defined below.
          - rule_group_name:     The name of rule group for exclusion. Accepted values can be found [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy#rule_group_name).
          - excluded_rules:      One or more Rule IDs for exclusion.
      ```
      EOD
  default     = []
}