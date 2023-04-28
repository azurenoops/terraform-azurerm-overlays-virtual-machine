# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#--------------------------------------
# Virtual Machine Patching
#--------------------------------------
resource "azurerm_maintenance_assignment_virtual_machine" "maintenance_configurations" {
  for_each                     = toset(var.maintenance_configuration_ids)
  location                     = local.location
  maintenance_configuration_id = each.value
  virtual_machine_id           = var.os_type == "linux" ? azurerm_linux_virtual_machine.linux_vm.*.id : azurerm_windows_virtual_machine.win_vm.*.id

  lifecycle {
    precondition {
      condition     = var.patch_mode == var.patch_mode
      error_message = "The variable patch_mode must be set to AutomaticByPlatform to use maintenance configurations."
    }
  }
}