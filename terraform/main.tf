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
  name     = "demo-resource-group"
  location = "West Europe"
}

# App Service
resource "azurerm_app_service_plan" "demo_plan" {
  name                = "demo-app-service-plan"
  location            = azurerm_resource_group.demo_rg.location
  resource_group_name = azurerm_resource_group.demo_rg.name
  sku {
    tier = "Free" # "Standard" or higher for scaling...
    size = "F1"
  }
}

resource "azurerm_app_service" "demo_app" {
  name                = format("demo-web-app-%s", "test-hirsch-demo")
  location            = azurerm_resource_group.demo_rg.location
  resource_group_name = azurerm_resource_group.demo_rg.name
  app_service_plan_id = azurerm_app_service_plan.demo_plan.id

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}

# Create a Storage Account
resource "azurerm_storage_account" "frontend_storage" {
  name                     = "demowebfrontendstorage"
  resource_group_name      = azurerm_resource_group.demo_rg.name
  location                 = azurerm_resource_group.demo_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  https_traffic_only_enabled = true
}

resource "azurerm_storage_account_static_website" "frontend_static" {
  storage_account_id = azurerm_storage_account.frontend_storage.id
  error_404_document = "index.html"
  index_document     = "index.html"
}

# Out
output "app_service_url" {
  value = azurerm_app_service.demo_app.default_site_hostname
}

output "app_service_name" {
  value = azurerm_app_service.demo_app.name
}

output "frontend_static_site_url" {
  value = azurerm_storage_account.frontend_storage.primary_web_endpoint
}