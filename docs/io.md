## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| assign\_contributor\_role | Whether to assign Contributor role to WAF (optional) | `bool` | `false` | no |
| custom\_name | Override default naming convention | `string` | `null` | no |
| custom\_rules\_configuration | Custom rules configuration object with following attributes:<pre>- name:                           Gets name of the resource that is unique within a policy. This name can be used to access the resource.<br>      - priority:                       Describes priority of the rule. Rules with a lower value will be evaluated before rules with a higher value.<br>      - rule_type:                      Describes the type of rule. Possible values are `MatchRule` and `Invalid`.<br>      - action:                         Type of action. Possible values are `Allow`, `Block` and `Log`.<br>      - match_conditions_configuration: One or more `match_conditions` blocks as defined below.<br>      - match_variable_configuration:   One or more match_variables blocks as defined below.<br>      - variable_name:                  The name of the Match Variable. Possible values are RemoteAddr, RequestMethod, QueryString, PostArgs, RequestUri, RequestHeaders, RequestBody and RequestCookies.<br>      - selector:                       Describes field of the matchVariable collection<br>      - match_values:                   A list of match values.<br>      - operator:                       Describes operator to be matched. Possible values are IPMatch, GeoMatch, Equal, Contains, LessThan, GreaterThan, LessThanOrEqual, GreaterThanOrEqual, BeginsWith, EndsWith and Regex.<br>      - negation_condition:             Describes if this is negate condition or not<br>      - transforms:                     A list of transformations to do before the match is attempted. Possible values are HtmlEntityDecode, Lowercase, RemoveNulls, Trim, UrlDecode and UrlEncode.</pre> | <pre>list(object({<br>    name      = optional(string)<br>    priority  = optional(number)<br>    rule_type = optional(string)<br>    action    = optional(string)<br>    match_conditions_configuration = optional(list(object({<br>      match_variable_configuration = optional(list(object({<br>        variable_name = optional(string)<br>        selector      = optional(string, null)<br>      })))<br>      match_values       = optional(list(string))<br>      operator           = optional(string)<br>      negation_condition = optional(bool, false)<br>      transforms         = optional(list(string), null)<br>    })))<br>  }))</pre> | `[]` | no |
| deployment\_mode | Specifies how the infrastructure/resource is deployed | `string` | `"terraform"` | no |
| enabled | Set to false to prevent the module from creating any resources. | `bool` | `true` | no |
| environment | Environment (e.g. `prod`, `dev`, `staging`). | `string` | `""` | no |
| exclusion\_configuration | Exclusion rules configuration object with following attributes:<pre>- match_variable:          The name of the Match Variable. Accepted values can be found [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy#match_variable).<br>      - selector:                Describes field of the matchVariable collection.<br>      - selector_match_operator: Describes operator to be matched. Possible values: `Contains`, `EndsWith`, `Equals`, `EqualsAny`, `StartsWith`.<br>      - excluded_rule_set:       One or more `excluded_rule_set` block defined below.<br>        - type:                  The rule set type. The only possible value is `OWASP`. Defaults to `OWASP`.<br>        - version:               The rule set version. The only possible value is `3.2`. Defaults to `3.2`.<br>        - rule_group:            One or more `rule_group` block defined below.<br>          - rule_group_name:     The name of rule group for exclusion. Accepted values can be found [here](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_application_firewall_policy#rule_group_name).<br>          - excluded_rules:      One or more Rule IDs for exclusion.</pre> | <pre>list(object({<br>    match_variable          = optional(string)<br>    selector                = optional(string)<br>    selector_match_operator = optional(string)<br>    excluded_rule_set = optional(list(object({<br>      type    = optional(string, "OWASP")<br>      version = optional(string, "3.2")<br>      rule_group = optional(list(object({<br>        rule_group_name = string<br>        excluded_rules  = optional(list(string), [])<br>      })), [])<br>    })), [])<br>  }))</pre> | `[]` | no |
| extra\_tags | Variable to pass extra tags. | `map(string)` | `null` | no |
| label\_order | Label order, e.g. `name`,`application`,`centralus`. | `list(any)` | <pre>[<br>  "name",<br>  "environment",<br>  "location"<br>]</pre> | no |
| location | Azure region where the WAF policy will be deployed | `string` | n/a | yes |
| managed\_rule\_set\_configuration | List of managed rule sets for the WAF policy.<br>      Example:<br>      [<br>        {<br>          type    = "OWASP"<br>          version = "3.2"<br>          rule\_group\_override\_configuration = [<br>            {<br>              rule\_group\_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"<br>              rule = [<br>                { id = "942100", enabled = false, action = "AnomalyScoring" }<br>              ]<br>            }<br>          ]<br>        }<br>      ] | <pre>list(object({<br>    type    = string<br>    version = string<br>    rule_group_override_configuration = optional(list(object({<br>      rule_group_name = string<br>      rule = list(object({<br>        id      = string<br>        enabled = bool<br>        action  = string<br>      }))<br>    })))<br>  }))</pre> | `[]` | no |
| managedby | ManagedBy, eg 'terraform-az-modules'. | `string` | `"terraform-az-modules"` | no |
| name | Name of the WAF policy | `string` | n/a | yes |
| policy\_enabled | Describes if the policy is in `enabled` state or `disabled` state. Defaults to `true`. | `bool` | `true` | no |
| policy\_file\_limit | Policy regarding the size limit of uploaded files. Value is in MB. Accepted values are in the range `1` to `4000`. Defaults to `100`. | `number` | `100` | no |
| policy\_max\_body\_size | Policy regarding the maximum request body size. Value is in KB. Accepted values are in the range `8` to `2000`. Defaults to `128`. | `number` | `128` | no |
| policy\_mode | Describes if it is in detection mode or prevention mode at the policy level. Valid values are `Detection` and `Prevention`. Defaults to `Prevention`. | `string` | `"Prevention"` | no |
| policy\_request\_body\_check\_enabled | Describes if the Request Body Inspection is enabled. Defaults to `true`. | `bool` | `true` | no |
| principal\_ids | List of principal IDs to assign role to (optional) | `list(string)` | `[]` | no |
| repository | Terraform current module repo | `string` | `"https://github.com/terraform-az-modules/terraform-azurerm-waf"` | no |
| resource\_group\_name | Resource Group name where the WAF policy will be created | `string` | n/a | yes |
| resource\_position\_prefix | Controls the placement of the resource type keyword (e.g., "vnet", "ddospp") in the resource name.<br><br>  - If true, the keyword is prepended: "vnet-core-dev".<br>  - If false, the keyword is appended: "core-dev-vnet".<br><br>  This helps maintain naming consistency based on organizational preferences. | `bool` | `true` | no |
| role\_assignment\_scope | Scope for role assignment (subscription or resource group) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| label\_order | Label order. |
| waf\_custom\_rules | Custom rules configured inside the WAF policy. |
| waf\_exclusion\_rules | Exclusion configuration applied to the WAF policy. |
| waf\_managed\_rule\_sets | Managed rule set configuration used in this WAF policy. |
| waf\_policy\_enabled | Whether the WAF policy is enabled. |
| waf\_policy\_id | The ID of the Azure WAF policy. |
| waf\_policy\_mode | The mode of the WAF policy. |
| waf\_policy\_name | The name of the WAF policy. |
| waf\_tags | Tags applied to the WAF policy. |

