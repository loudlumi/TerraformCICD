provider "azurerm" {
  features {}
  subscription_id = "<SUBSCRIPTION_ID>"
  client_id       = "<APP_ID>"
  client_secret   = "<APP_SECRET>"
  tenant_id       = "<TENANT_ID>"
}

resource "azurerm_log_analytics_workspace" "law_lumi" {
  name                = "LAW-Lumi"
  location            = "East US"
  resource_group_name = "<RESOURCE_GROUP_NAME>"
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_sentinel_workspace" "sentinel_lumi" {
  name                = "Sentinel-Lumi"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law_lumi.id
}
