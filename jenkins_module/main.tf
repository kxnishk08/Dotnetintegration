provider "azurerm" {
  features {}
  subscription_id = "65204ca9-fc1b-418e-9981-39b5249fe02c"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-jenkins"
  location = "East US"
}

resource "azurerm_app_service_plan" "asp" {
  name                = "app-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "app" {
  name                = "webapijenkins2808"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  site_config {
    linux_fx_version = "DOTNET|8.0"
  }
}