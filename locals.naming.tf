locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  resource_group_name             = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, module.mod_scaffold_rg.*.resource_group_name, [""]), 0)
  location                        = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, module.mod_scaffold_rg.*.resource_group_location, [""]), 0)
  linux_vm_name                   = coalesce(var.custom_linux_vm_name, data.azurenoopsutils_resource_name.vm_linux.result)
  windows_vm_name                 = coalesce(var.custom_windows_vm_name, data.azurenoopsutils_resource_name.vm_windows.result)
  windows_computer_name           = coalesce(var.custom_computer_name, data.azurenoopsutils_resource_name.computer_windows.result)
  vm_os_disk_name                 = coalesce(var.os_disk_custom_name, data.azurenoopsutils_resource_name.disk.result)
  vm_pub_ip_name                  = coalesce(var.custom_public_ip_name, data.azurenoopsutils_resource_name.pub_ip.result)
  vm_nic_name                     = coalesce(var.custom_nic_name, data.azurenoopsutils_resource_name.nic.result)
  vm_secondary_nic_name           = data.azurenoopsutils_resource_name.secnic.result
  vm_nsg_name                     = coalesce(var.custom_nic_name, data.azurenoopsutils_resource_name.nsg.result)
  ip_configuration_name           = coalesce(var.custom_ipconfig_name, "vm-nic-ipconfig")
  secondary_ip_configuration_name = "vm-secondary-nic-ipconfig"
  vm_avset_name                   = data.azurenoopsutils_resource_name.avset.result
  vm_ppg_name                     = data.azurenoopsutils_resource_name.ppg.result
}
