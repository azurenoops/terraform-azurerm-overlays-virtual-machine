# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# remove file if not needed
data "azurerm_client_config" "current" {}

#----------------------------------------------------------
# VNet, Subnet selection & Random Resources
#----------------------------------------------------------
data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = var.existing_resource_group_name
}

data "azurerm_subnet" "snet" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = var.existing_resource_group_name
}

data "azurerm_network_security_group" "nsg" {
  name                = var.existing_network_security_group_name
  resource_group_name = var.existing_resource_group_name
}

data "azurerm_storage_account" "storeacc" {
  count               = var.storage_account_name != null ? 1 : 0
  name                = var.storage_account_name
  resource_group_name = var.existing_resource_group_name
}

resource "random_password" "passwd" {
  count       = (var.os_type == "linux" && var.disable_password_authentication == false && var.admin_password == null ? 1 : (var.os_type == "windows" && var.admin_password == null ? 1 : 0))
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false

  keepers = {
    admin_password = (var.os_type == "linux" ? local.linux_vm_name : (var.os_type == "windows" ? local.windows_vm_name : null))
  }
}