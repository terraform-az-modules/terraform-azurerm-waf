provider "azurerm" {
  features {}
}

##-----------------------------------------------------------------------------
## Resource Group module call
## Resource group in which all resources will be deployed.
##-----------------------------------------------------------------------------
module "resource_group" {
  source      = "terraform-az-modules/resource-group/azurerm"
  version     = "1.0.3"
  name        = "waf"
  environment = "test"
  label_order = ["environment", "name", ]
  location    = "Canada Central"
}

##-----------------------------------------------------------------------------
## Virtual Network module call.
##-----------------------------------------------------------------------------
module "vnet" {
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.3"
  name                = "app"
  environment         = "test"
  label_order         = ["name", "environment"]
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_spaces      = ["10.0.0.0/16"]
}

##------------------------------------------------------------------------------
## Subnet Module Call
##------------------------------------------------------------------------------
module "subnet" {
  source               = "terraform-az-modules/subnet/azurerm"
  version              = "1.0.1"
  environment          = "test"
  label_order          = ["name", "environment", ]
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name
  subnets = [
    {
      name            = "subnet1"
      subnet_prefixes = ["10.0.1.0/24"]
    }
  ]
}

##------------------------------------------------------------------------------
## Module WAF
##------------------------------------------------------------------------------
module "waf" {
  source              = "../.."
  name                = "my-waf"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  policy_enabled      = true
  policy_mode         = "Detection"
  managed_rule_set_configuration = [
    {
      type    = "OWASP"
      version = "3.2"
      rule_group_override_configuration = [
        {
          rule_group_name = "REQUEST-931-APPLICATION-ATTACK-RFI"
          rule = [
            {
              id      = "931130"
              enabled = false
              action  = "AnomalyScoring"
            }
          ]
        },
        {
          rule_group_name = "REQUEST-942-APPLICATION-ATTACK-SQLI"
          rule = [
            {
              id      = "942340"
              enabled = false
              action  = "AnomalyScoring"
            }
          ]
        },
        {
          rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
          rule = [
            {
              id      = "920470"
              enabled = false
              action  = "AnomalyScoring"
            }
          ]
        },
        {
          rule_group_name = "REQUEST-930-APPLICATION-ATTACK-LFI"
          rule = [
            {
              id      = "930130"
              enabled = false
              action  = "AnomalyScoring"
            }
          ]
        },
        {
          rule_group_name = "REQUEST-913-SCANNER-DETECTION"
          rule = [
            {
              id      = "913101"
              enabled = false
              action  = "AnomalyScoring"
            }
          ]
        },
        {
          rule_group_name = "REQUEST-932-APPLICATION-ATTACK-RCE"
          rule = [
            {
              id      = "932150"
              enabled = false
              action  = "AnomalyScoring"
            }
          ]
        },
        {
          rule_group_name = "REQUEST-941-APPLICATION-ATTACK-XSS"
          rule = [
            {
              id      = "941130"
              enabled = false
              action  = "AnomalyScoring"
            }
          ]
        },
        {
          rule_group_name = "REQUEST-921-PROTOCOL-ATTACK"
          rule = [
            {
              id      = "921150"
              enabled = false
              action  = "AnomalyScoring"
            }
          ]
        },
        {
          rule_group_name = "REQUEST-933-APPLICATION-ATTACK-PHP"
          rule = [
            {
              id      = "933180"
              enabled = false
              action  = "AnomalyScoring"
            }
          ]
        },
        {
          rule_group_name = "REQUEST-944-APPLICATION-ATTACK-JAVA"
          rule = [
            {
              id      = "944130"
              enabled = false
              action  = "AnomalyScoring"
            }
          ]
        }
      ]
    },
    {
      type    = "Microsoft_BotManagerRuleSet"
      version = "1.0"
      rule_group_override_configuration = [
        {
          rule_group_name = "UnknownBots"
          rule = [
            {
              id      = "300700"
              enabled = false
              action  = "Log"
            }
          ]
        },
        {
          rule_group_name = "BadBots"
          rule = [
            {
              id      = "100200"
              enabled = false
              action  = "Block"
            },
            {
              id      = "100100"
              enabled = false
              action  = "Block"
            },
          ]
        },
        {
          rule_group_name = "GoodBots"
          rule = [
            {
              id      = "200100"
              enabled = false
              action  = "Allow"
            },
            {
              id      = "200200"
              enabled = false
              action  = "Log"
            }
          ]
        }
      ]
    }
  ]
  exclusion_configuration = []
  custom_rules_configuration = [

    {
      name      = "DenyAll"
      priority  = 1
      rule_type = "MatchRule"
      action    = "Block"

      match_conditions_configuration = [
        {
          match_variable_configuration = [
            {
              variable_name = "RemoteAddr"
              selector      = null
            }
          ]

          match_values = [
            "10.0.0.1"
          ]

          operator           = "IPMatch"
          negation_condition = true
          transforms         = null
        },
        {
          match_variable_configuration = [
            {
              variable_name = "RequestUri"
              selector      = null
            },
          ]

          match_values = [
            "Azure",
            "Cloud"
          ]

          operator           = "Contains"
          negation_condition = true
          transforms         = null
        }
      ]
    }
  ]
}

##------------------------------------------------------------------------------
## Application Gateway Module Call
##------------------------------------------------------------------------------
module "application_gateway" {
  source              = "terraform-az-modules/application-gateway/azurerm"
  name                = "appgw-demo"
  version             = "1.0.0"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name

  sku = {
    name     = "Basic"
    tier     = "Basic"
    capacity = 1
  }

  # Gateway IP configuration
  gateway_ip_configuration_name = "appgw-gwipc"
  subnet_id                     = module.subnet.subnet_ids["subnet1"]

  # Frontend IP configuration
  frontend_ip_configuration_name = "sappgw-feip"

  # Frontend Ports
  frontend_port_settings = [
    {
      name = "sappgw-feport-80"
      port = 80
    },
    {
      name = "sappgw-feport-443"
      port = 443
    }
  ]

  # Backend pool
  backend_address_pools = [
    {
      name         = "appgw-testgateway-01pool-vm"
      ip_addresses = [] # Put VM IPs here (array), example ["10.0.1.4"]
    }
  ]

  # Backend HTTP settings
  backend_http_settings = [
    {
      name                  = "appgw-testgateway-http-set1"
      cookie_based_affinity = "Disabled"
      enable_https          = false
      path                  = "/"
      port                  = 80
      protocol              = "Http"
      request_timeout       = 30

      connection_draining = {
        enable_connection_draining = true
        drain_timeout_sec          = 300
      }
    },
    {
      name                  = "appgw-testgateway-http-set2"
      cookie_based_affinity = "Enabled"
      enable_https          = false
      path                  = "/"
      port                  = 80
      protocol              = "Http"
      request_timeout       = 30
    }
  ]

  # Listener
  http_listeners = [
    {
      name                           = "appgw-testgatewayhtln"
      frontend_ip_configuration_name = "sappgw-feip"
      frontend_port_name             = "sappgw-feport-80"
      protocol                       = "Http"
      ssl_certificate_name           = null
      host_name                      = null
    }
  ]

  # Routing Rule
  request_routing_rules = [
    {
      name                       = "appgw-testgateway-rqrt"
      rule_type                  = "Basic"
      http_listener_name         = "appgw-testgatewayhtln"
      backend_address_pool_name  = "appgw-testgateway-01pool-vm"
      backend_http_settings_name = "appgw-testgateway-http-set1"
      priority                   = 100
    }
  ]
}