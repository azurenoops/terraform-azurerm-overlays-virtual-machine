# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#--------------------------------------------------------------
# Azure Log Analytics Workspace Agent Installation for windows
#--------------------------------------------------------------
resource "azurerm_virtual_machine_extension" "omsagentwin" {
  count                      = var.deploy_log_analytics_agent && var.custom_boot_image.os_type == "windows" ? var.instances_count : 0
  name                       = var.instances_count == 1 ? "OmsAgentForWindows" : format("%s%s", "OmsAgentForWindows", count.index + 1)
  virtual_machine_id         = azurerm_virtual_machine.custom_vm[count.index].id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId": "${var.log_analytics_customer_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
    "workspaceKey": "${var.log_analytics_workspace_primary_shared_key}"
    }
  PROTECTED_SETTINGS
}

#--------------------------------------------------------------
# Azure Log Analytics Workspace Agent Installation for Linux
#--------------------------------------------------------------
resource "azurerm_virtual_machine_extension" "omsagentlinux" {
  count                      = var.deploy_log_analytics_agent && var.custom_boot_image.os_type == "linux" ? var.instances_count : 0
  name                       = var.instances_count == 1 ? "OmsAgentForLinux" : format("%s%s", "OmsAgentForLinux", count.index + 1)
  virtual_machine_id         = azurerm_virtual_machine.custom_vm[count.index].id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = "1.13"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "workspaceId": "${var.log_analytics_customer_id}"
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
    "workspaceKey": "${var.log_analytics_workspace_primary_shared_key}"
    }
  PROTECTED_SETTINGS
}


#--------------------------------------
# azurerm monitoring diagnostics 
#--------------------------------------
/* resource "azurerm_monitor_diagnostic_setting" "nsg" {
  count                      = var.log_analytics_workspace_id == null ? 0 : 1
  name                       = var.custom_boot_image.os_type == "linux" ? lower("nsg-${local.linux_vm_name}-diag") : lower("nsg-${local.windows_vm_name}-diag")
  target_resource_id         = var.existing_network_security_group_id == null ? azurerm_network_security_group.nsg.0.id : var.existing_network_security_group_id
  storage_account_id         = var.storage_account_name != null ? data.azurerm_storage_account.storeacc.0.id : null
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "log" {
    for_each = var.nsg_diag_logs
    content {
      category = log.value
      enabled  = true

      retention_policy {
        enabled = false
        days    = 0
      }
    }
  }
} */
