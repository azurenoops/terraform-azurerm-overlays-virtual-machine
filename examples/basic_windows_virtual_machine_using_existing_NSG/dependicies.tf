# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_resource_group" "windows-rg" {
  name     = "windows-vm-rg"
  location = var.location
  tags = {
    environment = "test"
  }
}

resource "azurerm_virtual_network" "windows-vnet" {
  depends_on = [
    azurerm_resource_group.windows-rg
  ]
  name                = "vm-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.windows-rg.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "test"
  }
}

resource "azurerm_subnet" "windows-snet" {
  depends_on = [
    azurerm_resource_group.windows-rg,
    azurerm_virtual_network.windows-vnet
  ]
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.windows-rg.name
  virtual_network_name = azurerm_virtual_network.windows-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "windows-nsg" {
  depends_on = [
    azurerm_resource_group.windows-rg,
  ]
  name                = "vm-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.windows-rg.name
  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "test"
  }
}

resource "azurerm_log_analytics_workspace" "windows-log" {
  depends_on = [
    azurerm_resource_group.windows-rg
  ]
  name                = "vm-log"
  location            = var.location
  resource_group_name = azurerm_resource_group.windows-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    environment = "test"
  }
}
