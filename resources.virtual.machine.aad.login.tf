# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------
# Virtual machine AAD Login
#---------------------------------------
resource "azurerm_virtual_machine_extension" "linux_aad_ssh_login" {
  count                      = var.aad_login_enabled && var.custom_boot_image.os_type == "linux" ? var.instances_count : 0
  name                       = "${local.linux_vm_name}-AADLoginForLinux"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForLinux"
  type_handler_version       = var.aad_login_extension_version
  virtual_machine_id         = azurerm_virtual_machine.custom_vm[count.index].id
  auto_upgrade_minor_version = false
  automatic_upgrade_enabled  = false
}

resource "azurerm_virtual_machine_extension" "win_aad_login" {
  count                      = var.aad_login_enabled && var.custom_boot_image.os_type == "windows" ? var.instances_count : 0
  name                       = "${local.windows_vm_name}-AADLoginForWindows"
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = var.aad_login_extension_version
  virtual_machine_id         = azurerm_virtual_machine.custom_vm[count.index].id
  auto_upgrade_minor_version = false
  automatic_upgrade_enabled  = false
}

resource "azurerm_role_assignment" "rbac_user_login" {
  for_each             = toset(var.aad_login_enabled ? var.aad_login_user_objects_ids : [])
  principal_id         = each.value
  scope                = azurerm_virtual_machine.custom_vm.*.id 
  role_definition_name = "Virtual Machine User Login"
}

resource "azurerm_role_assignment" "rbac_admin_login" {
  for_each             = toset(var.aad_login_enabled ? var.aad_login_admin_objects_ids : [])
  principal_id         = each.value
  scope                = azurerm_virtual_machine.custom_vm.*.id 
  role_definition_name = "Virtual Machine Administrator Login"
}