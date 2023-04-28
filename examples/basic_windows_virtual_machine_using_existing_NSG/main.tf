# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Terraform module for deploying a basic windows Virtual Machine in Azure. 

module "mod_virtual_machine" {
  #source  = "azurenoops/overlays-virtual-machine/azurerm"
  #version = "x.x.x"
  source = "../../"

  depends_on = [
    azurerm_log_analytics_workspace.windows-log,
  ]

  # Resource Group, location, VNet and Subnet details
  existing_resource_group_name = azurerm_resource_group.windows-rg.name
  location                     = var.location
  deploy_environment           = var.deploy_environment
  org_name                     = var.org_name
  workload_name                = var.workload_name
  virtual_network_name         = azurerm_virtual_network.windows-vnet.name
  subnet_name                  = azurerm_subnet.windows-snet.name

  # This module support multiple Pre-Defined windows and Windows Distributions.
  # Check the README.md file for more pre-defined images for Ubuntu, Centos, RedHat.
  # Please make sure to use gen2 images supported VM sizes if you use gen2 distributions
  # Specify `disable_password_authentication = false` to create random admin password
  # Specify a valid password with `admin_password` argument to use your own password .  
  os_type                   = "windows"
  windows_distribution_name = "windows2019dc"
  virtual_machine_size      = "Standard_B2s"
  admin_username            = "azureadmin"
  admin_password            = "P@$$w0rd1234!"
  instances_count           = 2 # Number of VM's to be deployed

  # The proximity placement group, Availability Set, and assigning a public IP address to VMs are all optional.
  # If you don't wish to utilize these arguments, delete them from the module. 
  enable_proximity_placement_group = true
  enable_vm_availability_set       = true
  enable_public_ip_address         = true

  # Network Seurity group port definitions for each Virtual Machine 
  # NSG association for all network interfaces to be added automatically.
  # Using 'existing_network_security_group_name' is supplied then the module will use the existing NSG.
  existing_network_security_group_name = azurerm_network_security_group.windows-nsg.name
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

  # Attach a managed data disk to a Windows/windows virtual machine. 
  # Storage account types include: #'Standard_LRS', #'StandardSSD_ZRS', #'Premium_LRS', #'Premium_ZRS', #'StandardSSD_LRS', #'UltraSSD_LRS' (UltraSSD_LRS is only accessible in regions that support availability zones).
  # Create a new data drive - connect to the VM and execute diskmanagemnet or fdisk.
  data_disks = [
    {
      name                 = "disk1"
      disk_size_gb         = 100
      storage_account_type = "StandardSSD_LRS"
    },
    {
      name                 = "disk2"
      disk_size_gb         = 200
      storage_account_type = "Standard_LRS"
    }
  ]

  # AAD Login is used to login to the VM using Azure Active Directory credentials.
/*   aad_login_enabled = true
  aad_login_user_objects_ids = [
    data.azuread_group.vm_users_group.object_id
  ]

  aad_login_admin_objects_ids = [
    data.azuread_group.vm_admins_group.object_id
  ] */

  # (Optional) To activate Azure Monitoring and install log analytics agents 
  # (Optional) To save monitoring logs to storage, specify'storage_account_name'.    
  log_analytics_workspace_id = azurerm_log_analytics_workspace.windows-log.id
  
  # Deploy log analytics agents on a virtual machine. 
  # Customer id and primary shared key for Log Analytics workspace are required.
  deploy_log_analytics_agent                 = true
  log_analytics_customer_id                  = azurerm_log_analytics_workspace.windows-log.workspace_id
  log_analytics_workspace_primary_shared_key = azurerm_log_analytics_workspace.windows-log.primary_shared_key

  # Adding additional TAG's to your Azure resources
  add_tags = {
    Exmaple = "basic_windows_virtual_machine_using_existing_RG"
  }
}
