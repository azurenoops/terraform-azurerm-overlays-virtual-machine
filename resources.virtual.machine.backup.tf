# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------
# Virtual machine backup
#---------------------------------------
resource "azurerm_backup_protected_vm" "backup" {
  count = var.backup_policy_id != null ? 1 : 0

  resource_group_name = local.backup_resource_group_name
  recovery_vault_name = local.backup_recovery_vault_name
  source_vm_id        = azurerm_virtual_machine.custom_vm.*.id
  backup_policy_id    = var.backup_policy_id
}