# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Terraform module for deploying a Custom VHD-based Virtual Machine in Azure. 

module "mod_virtual_machine" {
  #source  = "azurenoops/overlays-custom-virtual-machine/azurerm"
  #version = "~>0.9"
  source = "../../.."

  depends_on = [
    azurerm_log_analytics_workspace.linux-log,
  ]

  # Resource Group, location, VNet and Subnet details
  existing_resource_group_name = azurerm_resource_group.custom-vm-rg.name
  location                     = var.location
  deploy_environment           = var.deploy_environment
  org_name                     = var.org_name
  workload_name                = var.workload_name

  # Lookup Network Information for VM deployment
  existing_virtual_network_resource_group_name = azurerm_virtual_network.linux-vnet.resource_group_name
  existing_virtual_network_name                = azurerm_virtual_network.linux-vnet.name
  existing_subnet_name                         = azurerm_subnet.linux-snet.name
  existing_network_security_group_name         = azurerm_network_security_group.linux-nsg.name

  custom_boot_image = {
    storage_uri       = "https://sandboxtakfiles.blob.core.windows.net/takvhd/takboot.vhd"
    storage_acct_id   = data.azurerm_storage_account.custom_image_storage_acct.id
    storage_acct_type = "StandardSSD_LRS"
    os_type           = "Linux"
    disk_size_gb      = 1024
    availability_zone = 1
  }
  #linux_distribution_name         = "ubuntu2004"
  virtual_machine_size            = "Standard_B2s"
  disable_password_authentication = false
  admin_username                  = "azureadmin"
  admin_password                  = "P@$$w0rd1234!"
  instances_count                 = 1 # Number of VM's to be deployed

  # The proximity placement group, Availability Set, and assigning a public IP address to VMs are all optional.
  # If you don't wish to utilize these arguments, delete them from the module. 
  enable_proximity_placement_group   = false
  enable_vm_availability_set         = false
  private_ip_address_allocation_type = "Static" # Static or Dynamic
  private_ip_address                 = ["10.0.1.36"]

  # Network Security group port definitions for each Virtual Machine 
  # NSG association for all network interfaces to be added automatically.
  # If 'existing_network_security_group_name' is supplied, the module will use the existing NSG.
  nsg_inbound_rules = [
    {
      name                   = "ssh"
      destination_port_range = "22"
      source_address_prefix  = "*"
    },
    {
      name                   = "http"
      destination_port_range = "80"
      source_address_prefix  = "*"
    },
  ]

  # Boot diagnostics are used to troubleshoot virtual machines by default. 
  # To use a custom storage account, supply a valid name for'storage_account_name'. 
  # Passing a 'null' value will use a Managed Storage Account to store Boot Diagnostics.
  enable_boot_diagnostics = true
  storage_account_name = azurerm_storage_account.boot_diagnostics_storage_acct.name

  # AAD Login is used to login to the VM using Azure Active Directory credentials.
  /* aad_login_enabled = true
  aad_login_user_objects_ids = [
    data.azuread_group.vm_users_group.object_id
  ]

  aad_login_admin_objects_ids = [
    data.azuread_group.vm_admins_group.object_id
  ] */

  # (Optional) To activate Azure Monitoring and install log analytics agents 
  # (Optional) To save monitoring logs to storage, specify'storage_account_name'.    
  log_analytics_workspace_id = azurerm_log_analytics_workspace.linux-log.id

  # Deploy log analytics agents on a virtual machine. 
  # Customer id and primary shared key for Log Analytics workspace are required.
  deploy_log_analytics_agent                 = true
  log_analytics_customer_id                  = azurerm_log_analytics_workspace.linux-log.workspace_id
  log_analytics_workspace_primary_shared_key = azurerm_log_analytics_workspace.linux-log.primary_shared_key

  # Adding additional TAG's to your Azure resources
  add_tags = {
    Example = "basic_linux_virtual_machine_using_existing_vhd"
  }
}
