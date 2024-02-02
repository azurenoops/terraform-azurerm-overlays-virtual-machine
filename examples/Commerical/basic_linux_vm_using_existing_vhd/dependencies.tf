# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

/* data "azuread_group" "vm_admins_group" {
  display_name = "Virtual Machines Admins"
}

data "azuread_group" "vm_users_group" {
  display_name = "Virtual Machines Users"
}
 */
resource "azurerm_resource_group" "linux-network-rg" {
  name     = "linux-network-rg"
  location = var.location
  tags = {
    environment = "test"
  }
}

resource "azurerm_resource_group" "custom-vm-rg" {
  name     = "custom-vm-rg"
  location = var.location
  tags = {
    environment = "test"
  }
}

resource "azurerm_storage_account" "boot_diagnostics_storage_acct" {
  name                     = "bootdiagstorage"
  resource_group_name      = azurerm_resource_group.custom-vm-rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "test"
  }
}

resource "azurerm_virtual_network" "linux-vnet" {
  depends_on = [
    azurerm_resource_group.linux-network-rg
  ]
  name                = "vm-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.linux-network-rg.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "test"
  }
}

resource "azurerm_subnet" "linux-snet" {
  depends_on = [
    azurerm_resource_group.linux-network-rg,
    azurerm_virtual_network.linux-vnet
  ]
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.linux-network-rg.name
  virtual_network_name = azurerm_virtual_network.linux-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "bastion-snet" {
  depends_on = [
    azurerm_resource_group.linux-network-rg,
    azurerm_virtual_network.linux-vnet
  ]
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.linux-network-rg.name
  virtual_network_name = azurerm_virtual_network.linux-vnet.name
  address_prefixes     = ["10.0.2.0/26"]
}

resource "azurerm_network_security_group" "linux-nsg" {
  depends_on = [
    azurerm_resource_group.linux-network-rg,
  ]
  name                = "vm-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.linux-network-rg.name
  tags = {
    environment = "test"
  }
}

resource "azurerm_log_analytics_workspace" "linux-log" {
  depends_on = [
    azurerm_resource_group.linux-network-rg
  ]
  name                = "vm-log"
  location            = var.location
  resource_group_name = azurerm_resource_group.linux-network-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    environment = "test"
  }
}

resource "azurerm_public_ip" "bastion-pip" {
  depends_on = [
    azurerm_resource_group.linux-network-rg
  ]
  name                = "vm-bastion-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.linux-network-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    environment = "test"
  }
}

resource "azurerm_bastion_host" "bastion" {
  depends_on = [
    azurerm_subnet.bastion-snet
  ]
  name                = "vm-bastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.linux-network-rg.name
  ip_configuration {
    name                 = "vm-bastion-ip"
    subnet_id            = azurerm_subnet.bastion-snet.id
    public_ip_address_id = azurerm_public_ip.bastion-pip.id
  }
  tags = {
    environment = "test"
  }

}

resource "azurerm_network_interface" "jumpbox-nic" {
  depends_on = [
    azurerm_resource_group.custom-vm-rg,
    azurerm_virtual_network.linux-vnet,
    azurerm_subnet.linux-snet,
    azurerm_network_security_group.linux-nsg,
    azurerm_log_analytics_workspace.linux-log
  ]
  name                = "jumpbox-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.custom-vm-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.linux-snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "jumpbox" {
  depends_on = [
    azurerm_resource_group.custom-vm-rg,
    azurerm_virtual_network.linux-vnet,
    azurerm_subnet.linux-snet,
    azurerm_network_security_group.linux-nsg,
    azurerm_log_analytics_workspace.linux-log
  ]
  name                = "jumpbox"
  resource_group_name = azurerm_resource_group.custom-vm-rg.name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = "azureadmin"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [azurerm_network_interface.jumpbox-nic.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  tags = {
    environment = "test"
  }
}