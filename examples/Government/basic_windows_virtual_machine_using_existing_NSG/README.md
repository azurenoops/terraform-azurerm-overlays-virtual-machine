# Azure Windows virtual Machine Overlay Terraform Module

This terraform overlay module is intended for the deployment of Azure virtual machines(Windows) with Public IP, proximity placement group, Availability Set, boot diagnostics, data disks, and Network Security Group support. It allows you to use current SSH keys or generate new ones if necessary.

This module requires you to use an existing NSG group. To enable this functionality, replace the input 'existing_network_security_group_name' with the current NSG group's valid resource name and you can use NSG inbound rules from the module.

## Module Usage to create Windows Virtual machine with optional resources

```terraform
# Azurerm provider configuration
provider "azurerm" {
  features {}
}

data "azurerm_log_analytics_workspace" "example" {
  name                = "windows-log-analytics-workspace"
  resource_group_name = var.location
}

module "mod_virtual_machine" {
  source  = "azurenoops/overlays-virtual-machine/azurerm"
  version = "x.x.x"

  # Resource Group, location, VNet and Subnet details
  resource_group_name  = azurerm_resource_group.windows-rg.name
  location             = var.location
  environment          = var.environment
  org_name             = var.org_name
  workload_name        = var.workload_name
  virtual_network_name = azurerm_virtual_network.windows-vnet.name
  subnet_name          = azurerm_subnet.windows-snet.name

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

  # Proxymity placement group, Availability Set and adding Public IP to VM's are optional.
  # remove these argument from module if you dont want to use it.  
  enable_proximity_placement_group = true
  enable_vm_availability_set       = true
  enable_public_ip_address         = true

  # Network Seurity group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.
  # When 'existing_network_security_group_name' is supplied, the module will use the existing NSG.
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

  # Boot diagnostics to troubleshoot virtual machines, by default uses managed 
  # To use custom storage account, specify `storage_account_name` with a valid name
  # Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics
  enable_boot_diagnostics = true

  # Attach a managed data disk to a Windows/windows VM's. Possible Storage account type are: 
  # `Standard_LRS`, `StandardSSD_ZRS`, `Premium_LRS`, `Premium_ZRS`, `StandardSSD_LRS`
  # or `UltraSSD_LRS` (UltraSSD_LRS only available in a region that support availability zones)
  # Initialize a new data disk - you need to connect to the VM and run diskmanagemnet or fdisk
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

  # (Optional) To enable Azure Monitoring and install log analytics agents
  # (Optional) Specify `storage_account_name` to save monitoring logs to storage.   
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.example.id

  # Deploy log analytics agents to virtual machine. 
  # Log analytics workspace customer id and primary shared key required.
  deploy_log_analytics_agent                 = true
  log_analytics_customer_id                  = data.azurerm_log_analytics_workspace.example.workspace_id
  log_analytics_workspace_primary_shared_key = data.azurerm_log_analytics_workspace.example.primary_shared_key

  # Adding additional TAG's to your Azure resources
  add_tags = {
    Exmaple = "basic_windows_virtual_machine_using_existing_RG"
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
