terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "demo_rg" {
  name     = "rg-showcase-eu"
  location = "West Europe"
}

# App Service
resource "azurerm_app_service_plan" "demo_app_plan" {
  name                = "showcase-web-app-service-plan"
  location            = azurerm_resource_group.demo_rg.location
  resource_group_name = azurerm_resource_group.demo_rg.name
  sku {
    tier = "Free"     # Standard, Free
    size = "F1"       # S1, F1
  }
}

resource "azurerm_app_service" "demo_app" {
  name                = format("showcase-web-app-%s", "hirsch")
  location            = azurerm_resource_group.demo_rg.location
  resource_group_name = azurerm_resource_group.demo_rg.name
  app_service_plan_id = azurerm_app_service_plan.demo_app_plan.id

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}

output "app_service_url" {
  value = azurerm_app_service.demo_app.default_site_hostname
}