provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

terraform {
      backend "remote" {
        # The name of your Terraform Cloud organization.
        organization = "Lumitek"

        # The name of the Terraform Cloud workspace to store Terraform state files in.
        workspaces {
          name = "TerraformCICD"
        }
      }
    }

resource "azurerm_log_analytics_workspace" "law_lumi" {
  name                = "LAW-Lumi"
  location            = "Canada Central"
  resource_group_name = "RG-TERRAFORMCICD-T"
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel_law_lumi" {
  resource_group_name          = "RG-TERRAFORMCICD-T"
  workspace_name               = azurerm_log_analytics_workspace.law_lumi.name
  customer_managed_key_enabled = false
}

# resource "azurerm_sentinel_workspace" "sentinel_lumi" {
#   name                = "Sentinel-Lumi"
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.law_lumi.id
# }
