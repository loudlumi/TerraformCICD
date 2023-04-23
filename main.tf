provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

variable "prefix" {
  default = "az-vm-t0"
}

variable "vm_count" {
  default = 3
}

variable "vm_size" {
  default = "Standard_B2s"
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

resource "azurerm_resource_group" "vm-rg" {
  name     = "RG-TerraformVM-T"
  location = "West US"
}

resource "azurerm_virtual_network" "vm-vnet" {
  name                = "VNET-VM-Spoke"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vm-rg.location
  resource_group_name = azurerm_resource_group.vm-rg.name
}

resource "azurerm_subnet" "vm-subnet" {
  name                 = "internalvmSubnet"
  resource_group_name  = azurerm_resource_group.vm-rg.name
  virtual_network_name = azurerm_virtual_network.vm-subnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "vm-nic" {
  count               = var.vm_count
  name                = "${var.prefix}${format("%02d", count.index + 1)}-nic"
  location            = azurerm_resource_group.vm-rg.location
  resource_group_name = azurerm_resource_group.vm-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm-linux" {
  count                 = var.vm_count
  name                  = "${var.prefix}${format("%02d", count.index + 1)}"
  location              = azurerm_resource_group.vm-rg.location
  resource_group_name   = azurerm_resource_group.vm-rg.name
  size                  = var.vm_size
  network_interface_ids = [azurerm_network_interface.vm-nic[count.index].id]

  admin_username = "adminuser"
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

output "public_key" {
  value = azurerm_linux_virtual_machine.admin_ssh_key.public_key
  sensitive = true
}



# resource "azurerm_sentinel_workspace" "sentinel_lumi" {
#   name                = "Sentinel-Lumi"
#   log_analytics_workspace_id = azurerm_log_analytics_workspace.law_lumi.id
# }
