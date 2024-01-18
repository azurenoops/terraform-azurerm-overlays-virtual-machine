# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Terraform module for deploying a basic Linux Virtual Machine in Azure. 

module "mod_virtual_machine" {
  #source  = "azurenoops/overlays-virtual-machine/azurerm"
  #version = "x.x.x"
  source = "../../.."

  depends_on = [
    azurerm_log_analytics_workspace.linux-log,
  ]

  # Resource Group, location, VNet and Subnet details
  existing_resource_group_name = azurerm_resource_group.linux-vm-rg.name
  location                     = var.location
  deploy_environment           = var.deploy_environment
  org_name                     = var.org_name
  workload_name                = var.workload_name

  # Lookup Network Information for VM deployment
  existing_virtual_network_resource_group_name = azurerm_virtual_network.linux-vnet.resource_group_name
  existing_virtual_network_name                = azurerm_virtual_network.linux-vnet.name
  existing_subnet_name                         = azurerm_subnet.linux-snet.name
  existing_network_security_group_name         = azurerm_network_security_group.linux-nsg.name

  # This module supports a variety of pre-configured Linux and Windows distributions.
  # See the README.md file for more pre-defined Ubuntu, Centos, and RedHat images.
  # If you use gen2 distributions, please use gen2 images with supported VM sizes.
  # To generate a random admin password, specify 'disable_password_authentication = false' 
  # To use your own password, specify a valid password with the 'admin_password' parameter 
  # To produce an SSH key pair, specify 'generate_admin_ssh_key = true'
  # To use an existing key pair, set 'admin_ssh_key_data' to the path of a valid SSH public key.  
  os_type                         = "linux"
  linux_distribution_name         = "ubuntu2004"
  virtual_machine_size            = "Standard_B2s"
  disable_password_authentication = false
  admin_username                  = "azureadmin"
  admin_password                  = "P@$$w0rd1234!"
  instances_count                 = 1 # Number of VM's to be deployed


  private_ip_address_allocation_type = "Static" # Static or Dynamic
  private_ip_address                 = ["10.0.1.36"]

  additional_nic_configuration = {
    subnet_id          = azurerm_subnet.temp-snet.id
    private_ip_address = "192.168.1.10"
  }

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

  # Adding additional TAG's to your Azure resources
  add_tags = {
    Example = "basic_linux_virtual_machine_using_marketplace_image"
  }
}
