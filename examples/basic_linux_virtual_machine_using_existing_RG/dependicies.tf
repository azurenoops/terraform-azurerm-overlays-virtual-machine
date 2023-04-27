# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_resource_group" "linux-rg" {
  name     = "linux-vm-rg"
  location = var.location
  tags = {
    environment = "test"
  }
}

resource "azurerm_virtual_network" "linux-vnet" {
  depends_on = [
    azurerm_resource_group.linux-rg
  ]
  name                = "vm-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.linux-rg.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "test"
  }
}

resource "azurerm_subnet" "linux-snet" {
  depends_on = [
    azurerm_resource_group.linux-rg,
    azurerm_virtual_network.linux-vnet
  ]
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.linux-rg.name
  virtual_network_name = azurerm_virtual_network.linux-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_log_analytics_workspace" "linux-log" {
  depends_on = [
    azurerm_resource_group.linux-rg
  ]
  name                = "vm-log"
  location            = var.location
  resource_group_name = azurerm_resource_group.linux-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    environment = "test"
  }
}
