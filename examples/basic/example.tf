provider "azurerm" {
  features {}
}

module "waf" {
  source = "../../"
}
