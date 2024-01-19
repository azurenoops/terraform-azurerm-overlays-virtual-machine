# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#------------------------------------------------------------
# Azure NoOps Naming - This should be used on all resource naming
#------------------------------------------------------------
data "azurenoopsutils_resource_name" "vm_linux" {
  name          = var.workload_name
  resource_type = "azurerm_linux_virtual_machine"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azregions.location_short : module.mod_azregions.location_cli]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "vm"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "vm_windows" {
  name          = var.workload_name
  resource_type = "azurerm_windows_virtual_machine"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azregions.location_short : module.mod_azregions.location_cli]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "vm"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "computer_windows" {
  name          = random_id.uniqueString.hex
  resource_type = "azurerm_windows_virtual_machine"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azregions.location_short : module.mod_azregions.location_cli]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "vm"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "pub_ip" {
  name          = var.workload_name
  resource_type = "azurerm_public_ip"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azregions.location_short : module.mod_azregions.location_cli]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "pip"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "nic" {
  name          = var.workload_name
  resource_type = "azurerm_network_interface"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azregions.location_short : module.mod_azregions.location_cli]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "nic"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "secnic" {
  name          = var.workload_name
  resource_type = "azurerm_network_interface"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azregions.location_short : module.mod_azregions.location_cli]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, "sec", var.use_naming ? "" : "sec-nic"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "nsg" {
  name          = var.workload_name
  resource_type = "azurerm_network_security_group"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azregions.location_short : module.mod_azregions.location_cli]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "nsg"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "disk" {
  name          = var.workload_name
  resource_type = "azurerm_managed_disk"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azregions.location_short : module.mod_azregions.location_cli]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "disk"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "avset" {
  name          = var.workload_name
  resource_type = "azurerm_availability_set"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azregions.location_short : module.mod_azregions.location_cli]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "avail"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "azurenoopsutils_resource_name" "ppg" {
  name          = var.workload_name
  resource_type = "azurerm_proximity_placement_group"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azregions.location_short : module.mod_azregions.location_cli]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "proxigrp"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}
