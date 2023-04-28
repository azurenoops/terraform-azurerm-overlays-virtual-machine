# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------
# Virtual machine backup
#---------------------------------------
resource "azurerm_backup_protected_vm" "backup" {
  count = var.backup_policy_id != null ? 1 : 0

  resource_group_name = local.backup_resource_group_name
  recovery_vault_name = local.backup_recovery_vault_name
  source_vm_id        = var.os_type == "linux" ? azurerm_linux_virtual_machine.linux_vm.*.id : azurerm_windows_virtual_machine.win_vm.*.id
  backup_policy_id    = var.backup_policy_id
}