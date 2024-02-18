terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 3.56.0, < 4.0.0"
      configuration_aliases = [azurerm.main]
    }
  }
  required_version = ">= 1.4.0"
}
