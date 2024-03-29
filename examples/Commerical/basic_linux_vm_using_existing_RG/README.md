# Azure Linux virtual Machine Overlay Terraform Module

This terraform overlay module is intended for the deployment of Azure virtual machines(Linux) with Public IP, proximity placement group, Availability Set, boot diagnostics, data disks, and Network Security Group support. It allows you to use current SSH keys or generate new ones if necessary.

This module requires you to use an existing NSG group. To enable this functionality, replace the input 'existing_network_security_group_name' with the current NSG group's valid resource name and you can use NSG inbound rules from the module.

## Module Usage to create Linux Virtual machine with optional resources

```terraform
# Azurerm provider configuration
provider "azurerm" {
  features {}
}

module "mod_virtual_machine" {
  source  = "azurenoops/overlays-virtual-machine/azurerm"
  version = "x.x.x"

  # Resource Group, location, VNet and Subnet details
  resource_group_name  = azurerm_resource_group.linux-rg.name
  location             = var.location
  environment          = var.environment
  org_name             = var.org_name
  workload_name        = var.workload_name
  virtual_network_name = azurerm_virtual_network.linux-vnet.name
  subnet_name          = azurerm_subnet.linux-snet.name

  # This module supports a variety of pre-configured Linux and Windows distributions.
  # See the README.md file for more pre-defined Ubuntu, Centos, and RedHat images.
  # If you use gen2 distributions, please use gen2 images with supported VM sizes.
  # To generate a random admin password, specify 'disable_password_authentication = false' 
  # To use your own password, specify a valid password with the 'admin_password' parameter 
  # To produce an SSH key pair, specify 'generate_admin_ssh_key = true'
  # To use an existing key pair, set 'admin_ssh_key_data' to the path of a valid SSH public key.  
  os_type                 = "linux"
  linux_distribution_name = "ubuntu2004"
  virtual_machine_size    = "Standard_B2s"
  generate_admin_ssh_key  = true
  instances_count         = 2 # Number of VM's to be deployed

  # The proximity placement group, Availability Set, and assigning a public IP address to VMs are all optional.
  # If you don't wish to utilize these arguments, delete them from the module. 
  enable_proximity_placement_group = true
  enable_vm_availability_set       = true
  enable_public_ip_address         = true

  # Network Security group port definitions for each Virtual Machine 
  # NSG association for all network interfaces to be added automatically.
  # When 'existing_network_security_group_name' is supplied, the module will use the existing NSG.
  existing_network_security_group_name = azurerm_network_security_group.linux-nsg.name
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

  # Attach a managed data disk to a Windows/Linux virtual machine. 
  # Storage account types include: #'Standard_LRS', #'StandardSSD_ZRS', #'Premium_LRS', #'Premium_ZRS', #'StandardSSD_LRS', #'UltraSSD_LRS' (UltraSSD_LRS is only accessible in regions that support availability zones).
  # Create a new data drive - connect to the VM and execute diskmanagement or fdisk.
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
    Example  = "basic_linux_virtual_machine_using_existing_RG"   
  }
}
```

## Terraform Usage

To run this example you need to execute following Terraform commands

```hcl
terraform init
terraform plan
terraform apply
```

Run `terraform destroy` when you don't need these resources.
