provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

resource "azurerm_log_analytics_workspace" "law_lumi" {
  name                = "LAW-Lumi"
  location            = "Canada Central"
  resource_group_name = "RG-TERRAFORMCICD-T"
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_sentinel_workspace" "sentinel_lumi" {
  name                = "Sentinel-Lumi"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law_lumi.id
}
