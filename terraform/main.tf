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
resource "azurerm_service_plan" "demo_app_plan" {
  os_type             = "Windows"
  sku_name            = "F1" # Free = F1, Scalable = S1
  name                = "showcase-web-app-service-plan"
  location            = azurerm_resource_group.demo_rg.location
  resource_group_name = azurerm_resource_group.demo_rg.name
  #sku {
  #  tier = "Free"     # Standard, Free
  #  size = "F1"       # S1, F1
  #}

}

resource "azurerm_windows_web_app" "demo_app" {
  name                = format("showcase-web-app-%s", "hirsch")
  location            = azurerm_resource_group.demo_rg.location
  resource_group_name = azurerm_resource_group.demo_rg.name
  service_plan_id     = azurerm_service_plan.demo_app_plan.id

  site_config {
    always_on                               = false
    worker_count                            = 1
    container_registry_use_managed_identity = false
    http2_enabled                           = false

    virtual_application {
      physical_path = "site\\wwwroot"
      preload       = false
      virtual_path  = "/"
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"                        = "1"
    "APPINSIGHTS_INSTRUMENTATIONKEY"                  = "a85610bc-67e5-4d8b-acea-127e6a718a87"
    "APPINSIGHTS_PROFILERFEATURE_VERSION"             = "1.0.0"
    "APPINSIGHTS_SNAPSHOTFEATURE_VERSION"             = "1.0.0"
    "APPLICATIONINSIGHTS_CONNECTION_STRING"           = "InstrumentationKey=a85610bc-67e5-4d8b-acea-127e6a718a87;IngestionEndpoint=https://westeurope-5.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/;ApplicationId=9311c549-33f6-4ca5-ba42-338ba5595c5b"
    "ApplicationInsightsAgent_EXTENSION_VERSION"      = "~2"
    "DiagnosticServices_EXTENSION_VERSION"            = "~3"
    "InstrumentationEngine_EXTENSION_VERSION"         = "~1"
    "SnapshotDebugger_EXTENSION_VERSION"              = "~2"
    "XDT_MicrosoftApplicationInsights_BaseExtensions" = "disabled"
    "XDT_MicrosoftApplicationInsights_Java"           = "disabled"
    "XDT_MicrosoftApplicationInsights_Mode"           = "recommended"
    "XDT_MicrosoftApplicationInsights_NodeJS"         = "disabled"
    "XDT_MicrosoftApplicationInsights_PreemptSdk"     = "disabled"
  }
}

output "app_service_url" {
  value = azurerm_windows_web_app.demo_app.default_hostname
}