# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------------------------------
# Generates SSH2 key Pair for Linux VM's (Dev Environment only)
#---------------------------------------------------------------
resource "tls_private_key" "rsa" {
  count     = var.generate_admin_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

#-----------------------------------
# Public IP for Virtual Machine
#-----------------------------------
resource "azurerm_public_ip" "pip" {
  count               = var.enable_public_ip_address == true ? var.instances_count : 0
  name                = lower("${local.vm_pub_ip_name}-0${count.index + 1}")
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  sku_tier            = var.public_ip_sku_tier
  domain_name_label   = var.domain_name_label
  zones               = var.public_ip_availability_zone
  tags                = merge({ "ResourceName" = lower("${local.vm_pub_ip_name}-0${count.index + 1}") }, var.add_tags, var.public_ip_add_tags, )

  lifecycle {
    ignore_changes = [
      tags,
      ip_tags,
    ]
  }
}

#----------------------------------------------------------------------------------------------------
# Proximity placement group for virtual machines, virtual machine scale sets and availability sets.
#----------------------------------------------------------------------------------------------------
resource "azurerm_proximity_placement_group" "appgrp" {
  count               = var.enable_proximity_placement_group ? 1 : 0
  name                = lower(local.vm_ppg_name)
  location            = local.location
  resource_group_name = local.resource_group_name
  tags                = merge({ "ResourceName" = lower(local.vm_ppg_name) }, var.add_tags, )

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#-----------------------------------------------------
# Manages an Availability Set for Virtual Machines.
#-----------------------------------------------------
resource "azurerm_availability_set" "aset" {
  count                        = var.enable_vm_availability_set ? 1 : 0
  name                         = lower(local.vm_avset_name)
  location                     = local.location
  resource_group_name          = local.resource_group_name
  platform_fault_domain_count  = var.platform_fault_domain_count
  platform_update_domain_count = var.platform_update_domain_count
  proximity_placement_group_id = var.enable_proximity_placement_group ? azurerm_proximity_placement_group.appgrp.0.id : null
  managed                      = true
  tags                         = merge({ "ResourceName" = lower(local.vm_avset_name) }, var.add_tags, )

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#---------------------------------------
# Linux Virutal machine
#---------------------------------------
resource "azurerm_linux_virtual_machine" "linux_vm" {
  depends_on                      = [azurerm_network_interface_security_group_association.nsgassoc]
  count                           = var.os_type == "linux" ? var.instances_count : 0
  name                            = var.instances_count == 1 ? substr(local.linux_vm_name, 0, 64) : substr(format("%s%s", lower(replace(local.linux_vm_name, "/[[:^alnum:]]/", "")), count.index + 1), 0, 64)
  location                        = local.location
  resource_group_name             = local.resource_group_name
  size                            = var.virtual_machine_size
  priority                        = var.use_spot_instances ? "Spot" : "Regular"
  eviction_policy                 = var.use_spot_instances ? var.vm_eviction_policy : null
  max_bid_price                   = var.use_spot_instances ? var.max_bid_price : null
  admin_username                  = var.admin_username
  admin_password                  = var.disable_password_authentication == false && var.admin_password == null ? element(concat(random_password.passwd.*.result, [""]), 0) : var.admin_password
  disable_password_authentication = var.disable_password_authentication
  network_interface_ids = compact([element(concat(azurerm_network_interface.nic.*.id, [""]), count.index),
                           var.additional_nic_configuration != null ? element(concat(azurerm_network_interface.secondary_nic.*.id, [""]), count.index) : null])
  source_image_id              = var.source_image_id != null ? var.source_image_id : null
  provision_vm_agent           = true
  allow_extension_operations   = true
  dedicated_host_id            = var.dedicated_host_id
  custom_data                  = var.custom_data != null ? var.custom_data : null
  availability_set_id          = var.enable_vm_availability_set == true ? element(concat(azurerm_availability_set.aset.*.id, [""]), 0) : null
  encryption_at_host_enabled   = var.enable_encryption_at_host
  proximity_placement_group_id = var.enable_proximity_placement_group ? azurerm_proximity_placement_group.appgrp.0.id : null
  zone                         = var.vm_availability_zone
  tags                         = merge({ "ResourceName" = var.instances_count == 1 ? local.linux_vm_name : format("%s%s", lower(replace(local.linux_vm_name, "/[[:^alnum:]]/", "")), count.index + 1) }, var.add_tags, )

  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.admin_ssh_key_data == null ? tls_private_key.rsa[0].public_key_openssh : var.admin_ssh_key_data
    }
  }

  dynamic "source_image_reference" {
    for_each = var.source_image_id != null ? [] : [1]
    content {
      publisher = var.custom_image != null ? lookup(var.custom_image, "publisher", null) : var.linux_distribution_list[lower(var.linux_distribution_name)]["publisher"]
      offer     = var.custom_image != null ? lookup(var.custom_image, "offer", null) : var.linux_distribution_list[lower(var.linux_distribution_name)]["offer"]
      sku       = var.custom_image != null ? lookup(var.custom_image, "sku", null) : var.linux_distribution_list[lower(var.linux_distribution_name)]["sku"]
      version   = var.custom_image != null ? lookup(var.custom_image, "version", null) : var.linux_distribution_list[lower(var.linux_distribution_name)]["version"]
    }
  }

  dynamic "plan" {
    for_each = toset(var.custom_image_plan != null ? ["fake"] : [])
    content {
      name      = var.custom_image_plan.name
      product   = var.custom_image_plan.product
      publisher = var.custom_image_plan.publisher
    }
  }

  os_disk {
    storage_account_type      = var.os_disk_storage_account_type
    caching                   = var.os_disk_caching
    disk_encryption_set_id    = var.disk_encryption_set_id
    disk_size_gb              = var.disk_size_gb
    write_accelerator_enabled = var.enable_os_disk_write_accelerator
    name                      = var.os_disk_name
  }

  additional_capabilities {
    ultra_ssd_enabled = var.enable_ultra_ssd_data_disk_storage_support
  }

  dynamic "identity" {
    for_each = var.managed_identity_type != null ? [1] : []
    content {
      type         = var.managed_identity_type
      identity_ids = var.managed_identity_type == "UserAssigned" || var.managed_identity_type == "SystemAssigned, UserAssigned" ? var.managed_identity_ids : null
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.storage_account_name != null ? data.azurerm_storage_account.storeacc.0.primary_blob_endpoint : var.storage_account_uri
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#---------------------------------------
# Windows Virutal machine
#---------------------------------------
resource "azurerm_windows_virtual_machine" "win_vm" {
  count                        = var.os_type == "windows" ? var.instances_count : 0
  name                         = var.instances_count == 1 ? substr(local.windows_vm_name, 0, 24) : substr(format("%s%s", lower(replace(local.windows_vm_name, "/[[:^alnum:]]/", "")), count.index + 1), 0, 24)
  computer_name                = var.instances_count == 1 ? substr(local.windows_computer_name, 0, 15) : substr(format("%s%s", lower(replace(local.windows_computer_name, "/[[:^alnum:]]/", "")), count.index + 1), 0, 15)
  location                     = local.location
  resource_group_name          = local.resource_group_name
  size                         = var.virtual_machine_size
  priority                     = var.use_spot_instances ? "Spot" : "Regular"
  eviction_policy              = var.use_spot_instances ? var.vm_eviction_policy : null
  max_bid_price                = var.use_spot_instances ? var.max_bid_price : null
  admin_username               = var.admin_username
  admin_password               = var.admin_password == null ? element(concat(random_password.passwd.*.result, [""]), 0) : var.admin_password
  network_interface_ids        = [element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)]
  source_image_id              = var.source_image_id != null ? var.source_image_id : null
  provision_vm_agent           = true
  allow_extension_operations   = true
  dedicated_host_id            = var.dedicated_host_id
  custom_data                  = var.custom_data != null ? var.custom_data : null
  enable_automatic_updates     = var.enable_automatic_updates
  license_type                 = var.license_type
  availability_set_id          = var.enable_vm_availability_set == true ? element(concat(azurerm_availability_set.aset.*.id, [""]), 0) : null
  encryption_at_host_enabled   = var.enable_encryption_at_host
  proximity_placement_group_id = var.enable_proximity_placement_group ? azurerm_proximity_placement_group.appgrp.0.id : null
  patch_mode                   = var.patch_mode
  zone                         = var.vm_availability_zone
  timezone                     = var.vm_time_zone
  tags                         = merge({ "ResourceName" = var.instances_count == 1 ? substr(local.windows_vm_name, 0, 15) : substr(format("%s%s", lower(replace(local.windows_vm_name, "/[[:^alnum:]]/", "")), count.index + 1), 0, 15) }, var.add_tags, )

  dynamic "source_image_reference" {
    for_each = var.source_image_id != null ? [] : [1]
    content {
      publisher = var.custom_image != null ? var.custom_image["publisher"] : var.windows_distribution_list[lower(var.windows_distribution_name)]["publisher"]
      offer     = var.custom_image != null ? var.custom_image["offer"] : var.windows_distribution_list[lower(var.windows_distribution_name)]["offer"]
      sku       = var.custom_image != null ? var.custom_image["sku"] : var.windows_distribution_list[lower(var.windows_distribution_name)]["sku"]
      version   = var.custom_image != null ? var.custom_image["version"] : var.windows_distribution_list[lower(var.windows_distribution_name)]["version"]
    }
  }

  os_disk {
    storage_account_type      = var.os_disk_storage_account_type
    caching                   = var.os_disk_caching
    disk_encryption_set_id    = var.disk_encryption_set_id
    disk_size_gb              = var.disk_size_gb
    write_accelerator_enabled = var.enable_os_disk_write_accelerator
    name                      = var.os_disk_name
  }

  additional_capabilities {
    ultra_ssd_enabled = var.enable_ultra_ssd_data_disk_storage_support
  }

  dynamic "identity" {
    for_each = var.managed_identity_type != null ? [1] : []
    content {
      type         = var.managed_identity_type
      identity_ids = var.managed_identity_type == "UserAssigned" || var.managed_identity_type == "SystemAssigned, UserAssigned" ? var.managed_identity_ids : null
    }
  }

  dynamic "winrm_listener" {
    for_each = var.winrm_protocol != null ? [1] : []
    content {
      protocol        = var.winrm_protocol
      certificate_url = var.winrm_protocol == "Https" ? var.key_vault_certificate_secret_url : null
    }
  }

  dynamic "additional_unattend_content" {
    for_each = var.additional_unattend_content != null ? [1] : []
    content {
      content = var.additional_unattend_content
      setting = var.additional_unattend_content_setting
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.storage_account_name != null ? data.azurerm_storage_account.storeacc.0.primary_blob_endpoint : var.storage_account_uri
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
      patch_mode,
    ]
  }
}

# Windows VM Shutdown Schedule : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_test_global_vm_shutdown_schedule
/* resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_schedule" {
  count                 = var.os_type == "windows" || var.os_type == "linux" ? var.instances_count : 0
  virtual_machine_id    = var.os_type == "windows" ? azurerm_windows_virtual_machine.win_vm.*.id : azurerm_linux_virtual_machine.linux_vm.*.id
  location              = module.mod_azure_region_lookup.location_cli
  enabled               = var.enable_shutdown_schedule
  daily_recurrence_time = var.shutdown_time
  timezone              = "SA Eastern Standard Time"
  notification_settings {
    enabled = var.enable_shutdown_schedule_notification
  }
} */
