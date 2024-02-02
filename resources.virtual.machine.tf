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
# Custom Virutal machine
#---------------------------------------
resource "azurerm_virtual_machine" "custom_vm" {
  depends_on          = [azurerm_network_interface_security_group_association.nsgassoc]
  count               = var.instances_count
  name                = var.instances_count == 1 ? substr(local.linux_vm_name, 0, 64) : substr(format("%s%s", lower(replace(local.linux_vm_name, "/[[:^alnum:]]/", "")), count.index + 1), 0, 64)
  location            = local.location
  resource_group_name = local.resource_group_name
  vm_size             = var.virtual_machine_size
  network_interface_ids = compact([element(concat(azurerm_network_interface.nic.*.id, [""]), count.index),
  var.additional_nic_configuration != null ? element(concat(azurerm_network_interface.secondary_nic.*.id, [""]), count.index) : null])

  availability_set_id          = var.enable_vm_availability_set == true ? element(concat(azurerm_availability_set.aset.*.id, [""]), 0) : null
  proximity_placement_group_id = var.enable_proximity_placement_group ? azurerm_proximity_placement_group.appgrp.0.id : null
  tags                         = merge({ "ResourceName" = var.instances_count == 1 ? local.linux_vm_name : format("%s%s", lower(replace(local.linux_vm_name, "/[[:^alnum:]]/", "")), count.index + 1) }, var.add_tags, )

  /* os_profile {
    computer_name  = var.instances_count == 1 ? local.linux_vm_name : format("%s%s", lower(replace(local.linux_vm_name, "/[[:^alnum:]]/", "")), count.index + 1)
    admin_username = var.admin_username
    admin_password = var.disable_password_authentication == false && var.admin_password == null ? element(concat(random_password.passwd.*.result, [""]), 0) : var.admin_password
    custom_data    = var.custom_data != null ? var.custom_data : null
  } */

  ### OS Profile for Linux VMs with SSH
  dynamic "os_profile_linux_config" {
    for_each = var.custom_boot_image.os_type == "Linux" && var.disable_password_authentication ? [1] : []
    content {
      disable_password_authentication = var.disable_password_authentication
      ssh_keys {
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
        key_data = var.admin_ssh_key_data 
      }
    }
  }

  ### OS Profile for Linux VMs with admin password
  dynamic "os_profile_linux_config" {
    for_each = var.custom_boot_image.os_type == "Linux" && !var.disable_password_authentication ? [1] : []
    content {
      disable_password_authentication = var.disable_password_authentication
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

  storage_os_disk {
    create_option             = "Attach"
    os_type                   = var.custom_boot_image.os_type
    caching                   = var.os_disk_caching
    disk_size_gb              = var.disk_size_gb
    write_accelerator_enabled = var.enable_os_disk_write_accelerator
    name                      = local.vm_os_disk_name
    managed_disk_id           = azurerm_managed_disk.custom_boot_image[count.index].id
    managed_disk_type         = azurerm_managed_disk.custom_boot_image[count.index].storage_account_type
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
      enabled     = true
      storage_uri = data.azurerm_storage_account.storeacc.0.primary_blob_endpoint 
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

# Windows VM Shutdown Schedule : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_test_global_vm_shutdown_schedule
/* resource "azurerm_dev_test_global_vm_shutdown_schedule" "vm_schedule" {
  count                 = var.custom_boot_image.os_type == "windows" || var.custom_boot_image.os_type == "linux" ? var.instances_count : 0
  virtual_machine_id    = var.custom_boot_image.os_type == "windows" ? azurerm_virtual_machine.custom_vm.*.id : azurerm_virtual_machine.custom_vm.*.id
  location              = module.mod_azure_region_lookup.location_cli
  enabled               = var.enable_shutdown_schedule
  daily_recurrence_time = var.shutdown_time
  timezone              = "SA Eastern Standard Time"
  notification_settings {
    enabled = var.enable_shutdown_schedule_notification
  }
} */
