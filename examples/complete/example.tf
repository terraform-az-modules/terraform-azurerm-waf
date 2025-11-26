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
  environment = "dev"
  label_order = ["environment", "name", "location"]
  location    = "canadacentral"
}

##-----------------------------------------------------------------------------
## Virtual Network module call.
##-----------------------------------------------------------------------------
module "vnet" {
  depends_on          = [module.resource_group]
  source              = "terraform-az-modules/vnet/azurerm"
  version             = "1.0.3"
  name                = "app"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
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
  environment          = "dev"
  label_order          = ["name", "environment", "location"]
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
  name                = "test"
  environment         = "dev"
  label_order         = ["name", "environment", "location"]
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  policy_enabled      = true
  policy_mode         = "Detection"
  managed_rule_set_configuration = [
    {
      type    = "OWASP"
      version = "3.2"
    }
  ]
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
  version             = "1.0.1"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  firewall_policy_id  = module.waf.waf_policy_id

  external_waf_enabled = true
  sku = {
    name     = "WAF_v2"
    tier     = "WAF_v2"
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