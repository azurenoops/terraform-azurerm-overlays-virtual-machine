# Azure Virtual Machines Overlay Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/azurenoops/overlays-virtual-machine/azurerm/)

This Overlay Terraform module can deploy Azure Windows or Linux virtual machines with support for Public IP, proximity placement group, Availability Set, boot diagnostics, data disks, and Network Security Group. It supports existing ssh keys and produces ssh key pairs for Linux VMs as needed. If you do not provide a special password for Windows VMs it generates random passwords. This module can be utilized in a [SCCA compliant network](https://registry.terraform.io/modules/azurenoops/overlays-hubspoke/azurerm/latest).

This module requires you to use an existing NSG group. To enable this functionality, replace the input 'existing_network_security_group_name' with the current NSG group's valid resource name and you can use NSG inbound rules from the module.

## SCCA Compliance

This module can be SCCA compliant and can be used in a SCCA compliant Network. Enable private endpoints and SCCA compliant network rules to make it SCCA compliant.

For more information, please read the [SCCA documentation]("https://www.cisa.gov/secure-cloud-computing-architecture").

## Contributing

If you want to contribute to this repository, feel free to to contribute to our Terraform module.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Resources Supported

* [Linux Virtual Machine](https://www.terraform.io/docs/providers/azurerm/r/linux_virtual_machine.html)
* [Windows Virtual Machine](https://www.terraform.io/docs/providers/azurerm/r/windows_virtual_machine.html)
* [Linux VM with SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/linux/sql-vm-create-portal-quickstart)
* [Windows VM with SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-vm-create-portal-quickstart)
* [Managed Data Disks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk)
* [Boot Diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine#boot_diagnostics)
* [Proximity Placement Group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/proximity_placement_group)
* [Availability Set](https://www.terraform.io/docs/providers/azurerm/r/availability_set.html)
* [Public IP](https://www.terraform.io/docs/providers/azurerm/r/public_ip.html)
* [Network Security Group](https://www.terraform.io/docs/providers/azurerm/r/network_security_group.html)
* [Managed Identities](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine#identity)
* [Custom Data](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine#custom_data)
* [Additional_Unattend_Content](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine#additional_unattend_content)
* [SSH2 Key generation for Dev Environments](https://www.terraform.io/docs/providers/tls/r/private_key.html)
* [Azure Monitoring Diagnostics](https://www.terraform.io/docs/providers/azurerm/r/monitor_diagnostic_setting.html)
* [Log Analytics Agent Installation](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/log-analytics-agent)

## Module Usage

```terraform
# Azurerm provider configuration
provider "azurerm" {
  features {}
}

module "mod_virtual_machine" {
  source  = "azurenoops/overlays-virtual-machine/azurerm"
  version = "x.x.x"

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
  instances_count                 = 2 # Number of VM's to be deployed

  # The proximity placement group, Availability Set, and assigning a public IP address to VMs are all optional.
  # If you don't wish to utilize these arguments, delete them from the module. 
  enable_proximity_placement_group   = true
  enable_vm_availability_set         = true
  private_ip_address_allocation_type = "Static" # Static or Dynamic
  private_ip_address                 = ["10.0.1.36", "10.0.1.37"]

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
    Example = "basic_linux_virtual_machine_using_existing_RG"
  }
}
```

## Pre-Defined Windows and Linux VM Images

By using the `linux_distribution_name` or `windows_distribution_name` arguments with this module, you can deploy pre-defined Windows or Linux images.

OS type |Available Pre-defined Images|
--------|----------------------------|
Linux |`ubuntu2004`, `ubuntu2004-gen2`, `ubuntu1904`, `ubuntu1804`, `ubuntu1604`, `centos75`, `centos77`, `centos78-gen2`, `centos79-gen2`, `centos81`, `centos81-gen2`, `centos82-gen2`, `centos83-gen2`, `centos84-gen2` `coreos`, `rhel78`, `rhel78-gen2`, `rhel79`, `rhel79-gen2`, `rhel81`, `rhel81-gen2`, `rhel82`, `rhel82-gen2`, `rhel83`, `rhel83-gen2`, `rhel84`, `rhel84-gen2`, `rhel84-byos`, `rhel84-byos-gen2`
Windows|`windows2012r2dc`, `windows2016dc`, `windows2016dccore`, `windows2019dc`, `windows2019dccore`, `windows2019dccore-g2`, `windows2019dc-gensecond`, `windows2019dc-gs`, `windows2019dc-containers`, `windows2019dc-containers-g2`
MS SQL 2017|`mssql2017exp`, `mssql2017dev`, `mssql2017std`, `mssql2017ent`
MS SQL 2019|`mssql2019dev`, `mssql2019std`, `mssql2019ent`
MS SQL 2019 Linux (RHEL8)|`mssql2019ent-rhel8`, `mssql2019std-rhel8`, `mssql2019dev-rhel8`
MS SQL 2019 Linux (Ubuntu)|`mssql2019ent-ubuntu1804`, `mssql2019std-ubuntu1804`, `mssql2019dev-ubuntu1804`, `mssql2019ent-ubuntu2004`, `mssql2019std-ubuntu2004`, `mssql2019dev-ubuntu2004`
MS SQL 2019 Bring your own License (BOYL)|`mssql2019ent-byol`, `mssql2019std-byol`

## Custom Virtual Machine images

If the pre-defined Windows or Linux variations are insufficient, you can supply a custom image by configuring the 'custom_image' option with appropriate values. Bootstrapping configurations such as preloading apps, application setups, and other OS customizations can all be done with custom images. More information can be found here.(<https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-custom-images>)

#### Licensed Marketplace Images
For some Marketplace images you will need to provide a 'custom_image_plan' object and accept the license terms. For more information on the please see the `plan` block documentation at https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine#plan.  

Before using licensed Marketplace image, you may need to accept legal plan terms using the Powershell command found at https://learn.microsoft.com/en-us/cli/azure/vm/image/terms?view=azure-cli-latest#az-vm-image-terms-accept.  The response from this command will provide the values needed for the `custom_image_plan` object.

```terraform
module "virtual-machine" {
  source  = "azurenoops/overlays-virtual-machine/azurerm"
  version = "x.x.x"

# .... omitted
  
  os_flavor               = "linux"
  linux_distribution_name = "ubuntu2004"
  virtual_machine_size    = "Standard_B2s"
  generate_admin_ssh_key  = true
  instances_count         = 2

 os_type = "linux"
  custom_image = {
    publisher = "paloaltonetworks"
    offer     = "panorama"
    sku       = "byol"
    version   = "latest"
  }

  custom_image_plan = {
    publisher = "paloaltonetworks"
    product   = "panorama"
    name      = "byol"
  }

# .... omitted 

}
```

## Network Security Groups

By default, network security groups are attached to Network Interface and allow just necessary traffic while blocking all others (deny-all rule). In this Terraform module, use `nsg_inbound_rules` to construct a Network Security Group (NSG) for a network interface and allow it to add additional rules for inbound flows.

`VirtualNetwork,` `AzureLoadBalancer,` and `Internet` are service tags rather than IP addresses in the Source and Destination columns. Any in the protocol column includes `TCP`, `UDP`, and `ICMP`. You can choose `TCP`, `UDP`, `ICMP`, or `*` when establishing a rule. In the Source and Destination columns, `0.0.0.0/0` represents all addresses.

*You cannot remove the default rules, but you can override them by creating rules with higher priorities.*

```terraform
module "virtual-machine" {
  source  = "azurenoops/overlays-virtual-machine/azurerm"
  version = "x.x.x"

# .... omitted
  
  os_flavor               = "linux"
  linux_distribution_name = "ubuntu2004"
  virtual_machine_size    = "Standard_B2s"
  generate_admin_ssh_key  = true
  instances_count         = 2
  
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

# .... omitted

}
```

## Using existing Network Resource Groups

On occasion, you may need to deploy resources to diffent resource group but use the existing network resource group. This module allows you to use an existing network resource group by setting the input `existing_virtual_network_resource_group_name` to the name of the network resource group.

```terraform

```terraform
data "azurerm_virtual_network" "example" {
  name                = "nsg_mgnt_vnet_in"
  resource_group_name = "vnet-shared-hub-westeurope-001"
}

data "azurerm_network_security_group" "example" {
  name                = "nsg_mgnt_subnet_in"
  resource_group_name = "vnet-shared-hub-westeurope-001"
}

module "virtual-machine" {
   source  = "azurenoops/overlays-virtual-machine/azurerm"
  version = "x.x.x"

# .... omitted for bravity
  
  os_flavor               = "linux"
  linux_distribution_name = "ubuntu2004"
  virtual_machine_size    = "Standard_B2s"
  generate_admin_ssh_key  = true
  instances_count         = 2

  # Network Security group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.  
  existing_virtual_network_resource_group_name = data.azurerm_virtual_network.example.resource_group_name
  existing_network_security_group_name         = data.azurerm_network_security_group.example.name

# .... omitted for bravity

}
```

## Using existing Network Security Groups

To maintain capabilities, enterprise environments require the utilization of pre-existing NSG groups. This module facilitates the use of existing network security groups. Set the input `existing_network_security_group_name` to use a valid NSG resource name.

```terraform
data "azurerm_network_security_group" "example" {
  name                = "nsg_mgnt_subnet_in"
  resource_group_name = "vnet-shared-hub-westeurope-001"
}

module "virtual-machine" {
   source  = "azurenoops/overlays-virtual-machine/azurerm"
  version = "x.x.x"

# .... omitted for bravity
  
  os_flavor               = "linux"
  linux_distribution_name = "ubuntu2004"
  virtual_machine_size    = "Standard_B2s"
  generate_admin_ssh_key  = true
  instances_count         = 2

  # Network Security group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.  
  existing_network_security_group_name = data.azurerm_network_security_group.example.name

# .... omitted for bravity

}
```

## Recommended naming and tagging conventions

Using tags to properly organize your Azure resources, resource groups, and subscriptions into a taxonomy. Each tag is made up of a name and a value pair. For example, you can apply the term `Environment` and the value `Production` to all production resources.
See Resource name and tagging choice guide for advice on how to apply a tagging strategy.

>__Important__ :
For operations, tag names are case-insensitive. A tag with a tag name is updated or retrieved, independent of casing. The resource provider, on the other hand, may preserve the casing you supply for the tag name. Cost reports will show that casing. __The case of tag values is important.__

An effective naming convention creates resource names by incorporating vital resource information into the name. A public IP resource for a production SharePoint workload, for example, is named `pip-sharepoint-prod-westus-001` using these [recommended naming conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging#example-names).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azurenoopsutils"></a> [azurenoopsutils](#requirement\_azurenoopsutils) | ~> 1.0.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.22 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.1.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurenoopsutils"></a> [azurenoopsutils](#provider\_azurenoopsutils) | ~> 1.0.4 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.22 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_mod_azregions"></a> [mod\_azregions](#module\_mod\_azregions) | azurenoops/overlays-azregions-lookup/azurerm | ~> 1.0.0 |
| <a name="module_mod_scaffold_rg"></a> [mod\_scaffold\_rg](#module\_mod\_scaffold\_rg) | azurenoops/overlays-resource-group/azurerm | ~> 1.0.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_availability_set.aset](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/availability_set) | resource |
| [azurerm_backup_protected_vm.backup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_vm) | resource |
| [azurerm_linux_virtual_machine.linux_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_managed_disk.data_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.nsgassoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.nsg_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_proximity_placement_group.appgrp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/proximity_placement_group) | resource |
| [azurerm_public_ip.pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_virtual_machine_data_disk_attachment.data_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.omsagentlinux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.omsagentwin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_windows_virtual_machine.win_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [random_password.passwd](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [tls_private_key.rsa](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [azurenoopsutils_resource_name.avset](https://registry.terraform.io/providers/azurenoops/azurenoopsutils/latest/docs/data-sources/resource_name) | data source |
| [azurenoopsutils_resource_name.computer_windows](https://registry.terraform.io/providers/azurenoops/azurenoopsutils/latest/docs/data-sources/resource_name) | data source |
| [azurenoopsutils_resource_name.disk](https://registry.terraform.io/providers/azurenoops/azurenoopsutils/latest/docs/data-sources/resource_name) | data source |
| [azurenoopsutils_resource_name.nic](https://registry.terraform.io/providers/azurenoops/azurenoopsutils/latest/docs/data-sources/resource_name) | data source |
| [azurenoopsutils_resource_name.nsg](https://registry.terraform.io/providers/azurenoops/azurenoopsutils/latest/docs/data-sources/resource_name) | data source |
| [azurenoopsutils_resource_name.ppg](https://registry.terraform.io/providers/azurenoops/azurenoopsutils/latest/docs/data-sources/resource_name) | data source |
| [azurenoopsutils_resource_name.pub_ip](https://registry.terraform.io/providers/azurenoops/azurenoopsutils/latest/docs/data-sources/resource_name) | data source |
| [azurenoopsutils_resource_name.vm_linux](https://registry.terraform.io/providers/azurenoops/azurenoopsutils/latest/docs/data-sources/resource_name) | data source |
| [azurenoopsutils_resource_name.vm_windows](https://registry.terraform.io/providers/azurenoops/azurenoopsutils/latest/docs/data-sources/resource_name) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.rgrp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_storage_account.storeacc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) | data source |
| [azurerm_subnet.snet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_nic_configuration"></a> [additional\_nic_configuration](#input\_additional\_nic\_configuration) | The configuration information used when a second NIC needs to be added to the VM. | <pre>object({<br>  subnet_id = string<br>  private_ip_address = string<br>})</pre> | `null` | no |
| <a name="input_add_tags"></a> [add\_tags](#input\_add\_tags) | Extra tags to set on each created resource. | `map(string)` | `{}` | no |
| <a name="input_additional_unattend_content"></a> [additional\_unattend\_content](#input\_additional\_unattend\_content) | The XML formatted content that is added to the unattend.xml file for the specified path and component. | `any` | `null` | no |
| <a name="input_additional_unattend_content_setting"></a> [additional\_unattend\_content\_setting](#input\_additional\_unattend\_content\_setting) | The name of the setting to which the content applies. Possible values are `AutoLogon` and `FirstLogonCommands` | `any` | `null` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | The Password which should be used for the local-administrator on this Virtual Machine | `any` | `null` | no |
| <a name="input_admin_ssh_key_data"></a> [admin\_ssh\_key\_data](#input\_admin\_ssh\_key\_data) | specify the path to the existing SSH key to authenticate Linux virtual machine | `any` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The username of the local administrator used for the Virtual Machine. | `string` | `"azureadmin"` | no |
| <a name="input_application_gateway_backend_pool_id"></a> [application\_gateway\_backend\_pool\_id](#input\_application\_gateway\_backend\_pool\_id) | Id of the Application Gateway Backend Pool to attach the VM. | `string` | `null` | no |
| <a name="input_attach_application_gateway"></a> [attach\_application\_gateway](#input\_attach\_application\_gateway) | True to attach this VM to an Application Gateway | `bool` | `false` | no |
| <a name="input_attach_load_balancer"></a> [attach\_load\_balancer](#input\_attach\_load\_balancer) | True to attach this VM to a Load Balancer | `bool` | `false` | no |
| <a name="input_backup_policy_id"></a> [backup\_policy\_id](#input\_backup\_policy\_id) | Backup policy ID from the Recovery Vault to attach the Virtual Machine to (value to `null` to disable backup) | `string` | `null` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Controls if the resource group should be created. If set to false, the resource group name must be provided. Default is false. | `bool` | `false` | no |
| <a name="input_custom_computer_name"></a> [custom\_computer\_name](#input\_custom\_computer\_name) | Custom name for the Windows Virtual Machine Hostname. `vm_name` if not set. | `string` | `""` | no |
| <a name="input_custom_data"></a> [custom\_data](#input\_custom\_data) | Base64 encoded file of a bash script that gets run once by cloud-init upon VM creation | `any` | `null` | no |
| <a name="input_custom_dcr_name"></a> [custom\_dcr\_name](#input\_custom\_dcr\_name) | Custom name for Data collection rule association | `string` | `null` | no |
| <a name="input_custom_image"></a> [custom\_image](#input\_custom\_image) | Provide the custom image to this module if the default variants are not sufficient | <pre>map(object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  }))</pre> | `null` | no |
| <a name="input_custom_image_plan"></a> [custom\_image\_plan](#input\_custom\_image\_plan) | Provide the custom image plan to this module if the custom image selected is a licensed Marketplace image | <pre>object({<br>  name = string<br>  product = string<br>  publisher = string<br>})</pre> | `null` | no |
| <a name="input_custom_ipconfig_name"></a> [custom\_ipconfig\_name](#input\_custom\_ipconfig\_name) | Custom name for the IP config of the NIC. Generated if not set. | `string` | `null` | no |
| <a name="input_custom_linux_vm_name"></a> [custom\_linux\_vm\_name](#input\_custom\_linux\_vm\_name) | Custom name for the Linux Virtual Machine. Generated if not set. | `string` | `""` | no |
| <a name="input_custom_nic_name"></a> [custom\_nic\_name](#input\_custom\_nic\_name) | Custom name for the NIC interface. Generated if not set. | `string` | `null` | no |
| <a name="input_custom_public_ip_name"></a> [custom\_public\_ip\_name](#input\_custom\_public\_ip\_name) | Custom name for public IP. Generated if not set. | `string` | `null` | no |
| <a name="input_custom_resource_group_name"></a> [custom\_resource\_group\_name](#input\_custom\_resource\_group\_name) | The name of the resource group in which the resources will be created in. If not provided, a new resource group will be created with the name '<org\_name>-<environment>-<workload\_name>-rg' | `string` | `null` | no |
| <a name="input_custom_windows_vm_name"></a> [custom\_windows\_vm\_name](#input\_custom\_windows\_vm\_name) | Custom name for the Windows Virtual Machine. Generated if not set. | `string` | `""` | no |
| <a name="input_data_disks"></a> [data\_disks](#input\_data\_disks) | Managed Data Disks for azure virtual machines | <pre>list(object({<br>    name                 = string<br>    storage_account_type = string<br>    disk_size_gb         = number<br>  }))</pre> | `[]` | no |
| <a name="input_dedicated_host_id"></a> [dedicated\_host\_id](#input\_dedicated\_host\_id) | The ID of a Dedicated Host where this machine should be run on. | `any` | `null` | no |
| <a name="input_default_tags_enabled"></a> [default\_tags\_enabled](#input\_default\_tags\_enabled) | Option to enable or disable default tags. | `bool` | `true` | no |
| <a name="input_deploy_environment"></a> [deploy\_environment](#input\_deploy\_environment) | Name of the workload's environnement | `string` | n/a | yes |
| <a name="input_deploy_log_analytics_agent"></a> [deploy\_log\_analytics\_agent](#input\_deploy\_log\_analytics\_agent) | Install log analytics agent to windows or linux VM | `bool` | `false` | no |
| <a name="input_disable_password_authentication"></a> [disable\_password\_authentication](#input\_disable\_password\_authentication) | Should Password Authentication be disabled on this Linux Virtual Machine? Defaults to true. | `bool` | `true` | no |
| <a name="input_disk_encryption_set_id"></a> [disk\_encryption\_set\_id](#input\_disk\_encryption\_set\_id) | The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk. The Disk Encryption Set must have the `Reader` Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault | `any` | `null` | no |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from. | `any` | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of dns servers to use for network interface | `list` | `[]` | no |
| <a name="input_domain_name_label"></a> [domain\_name\_label](#input\_domain\_name\_label) | Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system. | `any` | `null` | no |
| <a name="input_enable_accelerated_networking"></a> [enable\_accelerated\_networking](#input\_enable\_accelerated\_networking) | Should Accelerated Networking be enabled? Defaults to false. | `bool` | `false` | no |
| <a name="input_enable_automatic_updates"></a> [enable\_automatic\_updates](#input\_enable\_automatic\_updates) | Specifies if Automatic Updates are Enabled for the Windows Virtual Machine. | `bool` | `false` | no |
| <a name="input_enable_boot_diagnostics"></a> [enable\_boot\_diagnostics](#input\_enable\_boot\_diagnostics) | Should the boot diagnostics enabled? | `bool` | `false` | no |
| <a name="input_enable_encryption_at_host"></a> [enable\_encryption\_at\_host](#input\_enable\_encryption\_at\_host) | Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host? | `bool` | `false` | no |
| <a name="input_enable_ip_forwarding"></a> [enable\_ip\_forwarding](#input\_enable\_ip\_forwarding) | Should IP Forwarding be enabled? Defaults to false | `bool` | `false` | no |
| <a name="input_enable_os_disk_write_accelerator"></a> [enable\_os\_disk\_write\_accelerator](#input\_enable\_os\_disk\_write\_accelerator) | Should Write Accelerator be Enabled for this OS Disk? This requires that the `storage_account_type` is set to `Premium_LRS` and that `caching` is set to `None`. | `bool` | `false` | no |
| <a name="input_enable_proximity_placement_group"></a> [enable\_proximity\_placement\_group](#input\_enable\_proximity\_placement\_group) | Manages a proximity placement group for virtual machines, virtual machine scale sets and availability sets. | `bool` | `false` | no |
| <a name="input_enable_public_ip_address"></a> [enable\_public\_ip\_address](#input\_enable\_public\_ip\_address) | Reference to a Public IP Address to associate with the NIC | `any` | `null` | no |
| <a name="input_enable_ultra_ssd_data_disk_storage_support"></a> [enable\_ultra\_ssd\_data\_disk\_storage\_support](#input\_enable\_ultra\_ssd\_data\_disk\_storage\_support) | Should the capacity to enable Data Disks of the UltraSSD\_LRS storage account type be supported on this Virtual Machine | `bool` | `false` | no |
| <a name="input_enable_vm_availability_set"></a> [enable\_vm\_availability\_set](#input\_enable\_vm\_availability\_set) | Manages an Availability Set for Virtual Machines. | `bool` | `false` | no |
| <a name="input_existing_network_security_group_name"></a> [existing\_network\_security\_group\_id](#input\_existing\_network\_security\_group\_id) | The resource name of existing network security group | `any` | `null` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | The name of the existing resource group to use. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables. | `string` | `null` | no |
| <a name="input_extensions_add_tags"></a> [extensions\_add\_tags](#input\_extensions\_add\_tags) | Extra tags to set on the VM extensions. | `map(string)` | `{}` | no |
| <a name="input_generate_admin_ssh_key"></a> [generate\_admin\_ssh\_key](#input\_generate\_admin\_ssh\_key) | Generates a secure private key and encodes it as PEM. | `bool` | `false` | no |
| <a name="input_instances_count"></a> [instances\_count](#input\_instances\_count) | The number of Virtual Machines required. Default is 1. | `number` | `1` | no |
| <a name="input_internal_dns_name_label"></a> [internal\_dns\_name\_label](#input\_internal\_dns\_name\_label) | The (relative) DNS Name used for internal communications between Virtual Machines in the same Virtual Network. | `any` | `null` | no |
| <a name="input_key_vault_certificate_secret_url"></a> [key\_vault\_certificate\_secret\_url](#input\_key\_vault\_certificate\_secret\_url) | The Secret URL of a Key Vault Certificate, which must be specified when `protocol` is set to `Https` | `any` | `null` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | Specifies the type of on-premise license which should be used for this Virtual Machine. Possible values are None, Windows\_Client and Windows\_Server. | `string` | `"None"` | no |
| <a name="input_linux_distribution_list"></a> [linux\_distribution\_list](#input\_linux\_distribution\_list) | Pre-defined Azure Linux VM images list | <pre>map(object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  }))</pre> | <pre>{<br>  "centos77": {<br>    "offer": "CentOS",<br>    "publisher": "OpenLogic",<br>    "sku": "7.7",<br>    "version": "latest"<br>  },<br>  "centos78-gen2": {<br>    "offer": "CentOS",<br>    "publisher": "OpenLogic",<br>    "sku": "7_8-gen2",<br>    "version": "latest"<br>  },<br>  "centos79-gen2": {<br>    "offer": "CentOS",<br>    "publisher": "OpenLogic",<br>    "sku": "7_9-gen2",<br>    "version": "latest"<br>  },<br>  "centos81": {<br>    "offer": "CentOS",<br>    "publisher": "OpenLogic",<br>    "sku": "8_1",<br>    "version": "latest"<br>  },<br>  "centos81-gen2": {<br>    "offer": "CentOS",<br>    "publisher": "OpenLogic",<br>    "sku": "8_1-gen2",<br>    "version": "latest"<br>  },<br>  "centos82-gen2": {<br>    "offer": "CentOS",<br>    "publisher": "OpenLogic",<br>    "sku": "8_2-gen2",<br>    "version": "latest"<br>  },<br>  "centos83-gen2": {<br>    "offer": "CentOS",<br>    "publisher": "OpenLogic",<br>    "sku": "8_3-gen2",<br>    "version": "latest"<br>  },<br>  "centos84-gen2": {<br>    "offer": "CentOS",<br>    "publisher": "OpenLogic",<br>    "sku": "8_4-gen2",<br>    "version": "latest"<br>  },<br>  "coreos": {<br>    "offer": "CoreOS",<br>    "publisher": "CoreOS",<br>    "sku": "Stable",<br>    "version": "latest"<br>  },<br>  "mssql2019dev-rhel8": {<br>    "offer": "sql2019-rhel8",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "sqldev",<br>    "version": "latest"<br>  },<br>  "mssql2019dev-ubuntu1804": {<br>    "offer": "sql2019-ubuntu1804",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "sqldev",<br>    "version": "latest"<br>  },<br>  "mssql2019dev-ubuntu2004": {<br>    "offer": "sql2019-ubuntu2004",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "sqldev",<br>    "version": "latest"<br>  },<br>  "mssql2019ent-rhel8": {<br>    "offer": "sql2019-rhel8",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "enterprise",<br>    "version": "latest"<br>  },<br>  "mssql2019ent-ubuntu1804": {<br>    "offer": "sql2019-ubuntu1804",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "enterprise",<br>    "version": "latest"<br>  },<br>  "mssql2019ent-ubuntu2004": {<br>    "offer": "sql2019-ubuntu2004",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "enterprise",<br>    "version": "latest"<br>  },<br>  "mssql2019std-rhel8": {<br>    "offer": "sql2019-rhel8",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "standard",<br>    "version": "latest"<br>  },<br>  "mssql2019std-ubuntu1804": {<br>    "offer": "sql2019-ubuntu1804",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "standard",<br>    "version": "latest"<br>  },<br>  "mssql2019std-ubuntu2004": {<br>    "offer": "sql2019-ubuntu2004",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "standard",<br>    "version": "latest"<br>  },<br>  "rhel78": {<br>    "offer": "RHEL",<br>    "publisher": "RedHat",<br>    "sku": "7.8",<br>    "version": "latest"<br>  },<br>  "rhel78-gen2": {<br>    "offer": "RHEL",<br>    "publisher": "RedHat",<br>    "sku": "78-gen2",<br>    "version": "latest"<br>  },<br>  "rhel79": {<br>    "offer": "RHEL",<br>    "publisher": "RedHat",<br>    "sku": "7.9",<br>    "version": "latest"<br>  },<br>  "rhel79-gen2": {<br>    "offer": "RHEL",<br>    "publisher": "RedHat",<br>    "sku": "79-gen2",<br>    "version": "latest"<br>  },<br>  "rhel81": {<br>    "offer": "RHEL",<br>    "publisher": "RedHat",<br>    "sku": "8.1",<br>    "version": "latest"<br>  },<br>  "rhel81-gen2": {<br>    "offer": "RHEL",<br>    "publisher": "RedHat",<br>    "sku": "81gen2",<br>    "version": "latest"<br>  },<br>  "rhel82": {<br>    "offer": "RHEL",<br>    "publisher": "RedHat",<br>    "sku": "8.2",<br>    "version": "latest"<br>  },<br>  "rhel82-gen2": {<br>    "offer": "RHEL",<br>    "publisher": "RedHat",<br>    "sku": "82gen2",<br>    "version": "latest"<br>  },<br>  "rhel83": {<br>    "offer": "RHEL",<br>    "publisher": "RedHat",<br>    "sku": "8.3",<br>    "version": "latest"<br>  },<br>  "rhel83-gen2": {<br>    "offer": "RHEL",<br>    "publisher": "RedHat",<br>    "sku": "83gen2",<br>    "version": "latest"<br>  },<br>  "rhel84": {<br>    "offer": "RHEL",<br>    "publisher": "RedHat",<br>    "sku": "8.4",<br>    "version": "latest"<br>  },<br>  "rhel84-byos": {<br>    "offer": "rhel-byos",<br>    "publisher": "RedHat",<br>    "sku": "rhel-lvm84",<br>    "version": "latest"<br>  },<br>  "rhel84-byos-gen2": {<br>    "offer": "rhel-byos",<br>    "publisher": "RedHat",<br>    "sku": "rhel-lvm84-gen2",<br>    "version": "latest"<br>  },<br>  "rhel84-gen2": {<br>    "offer": "RHEL",<br>    "publisher": "RedHat",<br>    "sku": "84gen2",<br>    "version": "latest"<br>  },<br>  "ubuntu1604": {<br>    "offer": "UbuntuServer",<br>    "publisher": "Canonical",<br>    "sku": "16.04-LTS",<br>    "version": "latest"<br>  },<br>  "ubuntu1804": {<br>    "offer": "UbuntuServer",<br>    "publisher": "Canonical",<br>    "sku": "18.04-LTS",<br>    "version": "latest"<br>  },<br>  "ubuntu1904": {<br>    "offer": "UbuntuServer",<br>    "publisher": "Canonical",<br>    "sku": "19.04",<br>    "version": "latest"<br>  },<br>  "ubuntu2004": {<br>    "offer": "0001-com-ubuntu-server-focal-daily",<br>    "publisher": "Canonical",<br>    "sku": "20_04-daily-lts",<br>    "version": "latest"<br>  },<br>  "ubuntu2004-gen2": {<br>    "offer": "0001-com-ubuntu-server-focal-daily",<br>    "publisher": "Canonical",<br>    "sku": "20_04-daily-lts-gen2",<br>    "version": "latest"<br>  }<br>}</pre> | no |
| <a name="input_linux_distribution_name"></a> [linux\_distribution\_name](#input\_linux\_distribution\_name) | Variable to pick an OS flavor for Linux based VM. Possible values include: centos8, ubuntu1804 | `string` | `"ubuntu1804"` | no |
| <a name="input_load_balancer_backend_pool_id"></a> [load\_balancer\_backend\_pool\_id](#input\_load\_balancer\_backend\_pool\_id) | Id of the Load Balancer Backend Pool to attach the VM. | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region in which instance will be hosted | `string` | n/a | yes |
| <a name="input_log_analytics_customer_id"></a> [log\_analytics\_customer\_id](#input\_log\_analytics\_customer\_id) | The Workspace (or Customer) ID for the Log Analytics Workspace. | `any` | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The name of log analytics workspace resource id | `any` | `null` | no |
| <a name="input_log_analytics_workspace_primary_shared_key"></a> [log\_analytics\_workspace\_primary\_shared\_key](#input\_log\_analytics\_workspace\_primary\_shared\_key) | The Primary shared key for the Log Analytics Workspace | `any` | `null` | no |
| <a name="input_managed_identity_ids"></a> [managed\_identity\_ids](#input\_managed\_identity\_ids) | A list of User Managed Identity ID's which should be assigned to the Linux Virtual Machine. | `any` | `null` | no |
| <a name="input_managed_identity_type"></a> [managed\_identity\_type](#input\_managed\_identity\_type) | The type of Managed Identity which should be assigned to the Linux Virtual Machine. Possible values are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned` | `any` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Optional prefix for the generated name | `string` | `""` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Optional suffix for the generated name | `string` | `""` | no |
| <a name="input_nic_add_tags"></a> [nic\_add\_tags](#input\_nic\_add\_tags) | Extra tags to set on the network interface. | `map(string)` | `{}` | no |
| <a name="input_nsg_diag_logs"></a> [nsg\_diag\_logs](#input\_nsg\_diag\_logs) | NSG Monitoring Category details for Azure Diagnostic setting | `list` | <pre>[<br>  "NetworkSecurityGroupEvent",<br>  "NetworkSecurityGroupRuleCounter"<br>]</pre> | no |
| <a name="input_nsg_inbound_rules"></a> [nsg\_inbound\_rules](#input\_nsg\_inbound\_rules) | List of network rules to apply to network interface. | `list` | `[]` | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Name of the organization | `string` | n/a | yes |
| <a name="input_os_disk_add_tags"></a> [os\_disk\_add\_tags](#input\_os\_disk\_add\_tags) | Extra tags to set on the OS disk. | `map(string)` | `{}` | no |
| <a name="input_os_disk_caching"></a> [os\_disk\_caching](#input\_os\_disk\_caching) | The Type of Caching which should be used for the Internal OS Disk. Possible values are `None`, `ReadOnly` and `ReadWrite` | `string` | `"ReadWrite"` | no |
| <a name="input_os_disk_custom_name"></a> [os\_disk\_custom\_name](#input\_os\_disk\_custom\_name) | Custom name for OS disk. Generated if not set. | `string` | `null` | no |
| <a name="input_os_disk_name"></a> [os\_disk\_name](#input\_os\_disk\_name) | The name which should be used for the Internal OS Disk | `any` | `null` | no |
| <a name="input_os_disk_overwrite_tags"></a> [os\_disk\_overwrite\_tags](#input\_os\_disk\_overwrite\_tags) | True to overwrite existing OS disk tags instead of merging. | `bool` | `false` | no |
| <a name="input_os_disk_storage_account_type"></a> [os\_disk\_storage\_account\_type](#input\_os\_disk\_storage\_account\_type) | The Type of Storage Account which should back this the Internal OS Disk. Possible values include Standard\_LRS, StandardSSD\_LRS and Premium\_LRS. | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_os_disk_tagging_enabled"></a> [os\_disk\_tagging\_enabled](#input\_os\_disk\_tagging\_enabled) | Should OS disk tagging be enabled? Defaults to `true`. | `bool` | `true` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | Specify the type of the operating system image to deploy Virtual Machine. Valid values are `windows` and `linux` Default vaule is `windows` | `string` | `"windows"` | no |
| <a name="input_patch_mode"></a> [patch\_mode](#input\_patch\_mode) | Specifies the mode of in-guest patching to Linux or Windows Virtual Machine. Possible values are `Manual`, `AutomaticByOS` and `AutomaticByPlatform` | `string` | `"AutomaticByOS"` | no |
| <a name="input_platform_fault_domain_count"></a> [platform\_fault\_domain\_count](#input\_platform\_fault\_domain\_count) | Specifies the number of fault domains that are used | `number` | `3` | no |
| <a name="input_platform_update_domain_count"></a> [platform\_update\_domain\_count](#input\_platform\_update\_domain\_count) | Specifies the number of update domains that are used | `number` | `5` | no |
| <a name="input_private_ip_address"></a> [private\_ip\_address](#input\_private\_ip\_address) | The Static IP Address which should be used. This is valid only when `private_ip_address_allocation` is set to `Static` | `any` | `null` | no |
| <a name="input_private_ip_address_allocation_type"></a> [private\_ip\_address\_allocation\_type](#input\_private\_ip\_address\_allocation\_type) | The allocation method used for the Private IP Address. Possible values are Dynamic and Static. | `string` | `"Dynamic"` | no |
| <a name="input_public_ip_add_tags"></a> [public\_ip\_add\_tags](#input\_public\_ip\_add\_tags) | Extra tags to set on the public IP resource. | `map(string)` | `{}` | no |
| <a name="input_public_ip_allocation_method"></a> [public\_ip\_allocation\_method](#input\_public\_ip\_allocation\_method) | Defines the allocation method for this IP address. Possible values are `Static` or `Dynamic` | `string` | `"Static"` | no |
| <a name="input_public_ip_availability_zone"></a> [public\_ip\_availability\_zone](#input\_public\_ip\_availability\_zone) | The availability zone to allocate the Public IP in. Possible values are `1`,`2`,`3` | `list` | <pre>[<br>  "1",<br>  "2",<br>  "3"<br>]</pre> | no |
| <a name="input_public_ip_sku"></a> [public\_ip\_sku](#input\_public\_ip\_sku) | The SKU of the Public IP. Accepted values are `Basic` and `Standard` | `string` | `"Standard"` | no |
| <a name="input_public_ip_sku_tier"></a> [public\_ip\_sku\_tier](#input\_public\_ip\_sku\_tier) | The SKU Tier that should be used for the Public IP. Possible values are `Regional` and `Global` | `string` | `"Regional"` | no |
| <a name="input_random_password_length"></a> [random\_password\_length](#input\_random\_password\_length) | The desired length of random password created by this module | `number` | `24` | no |
| <a name="input_source_image_id"></a> [source\_image\_id](#input\_source\_image\_id) | The ID of an Image which each Virtual Machine should be based on | `any` | `null` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the hub storage account to store logs | `any` | `null` | no |
| <a name="input_storage_account_uri"></a> [storage\_account\_uri](#input\_storage\_account\_uri) | The Primary/Secondary Endpoint for the Azure Storage Account which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor. Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics. | `any` | `null` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The name of the subnet to use in VM scale set | `any` | `null` | no |
| <a name="input_use_location_short_name"></a> [use\_location\_short\_name](#input\_use\_location\_short\_name) | Use short location name for resources naming (ie eastus -> eus). Default is true. If set to false, the full cli location name will be used. if custom naming is set, this variable will be ignored. | `bool` | `true` | no |
| <a name="input_use_naming"></a> [use\_naming](#input\_use\_naming) | Use the Azure NoOps naming provider to generate default resource name. `storage_account_custom_name` override this if set. Legacy default name is used if this is set to `false`. | `bool` | `true` | no |
| <a name="input_virtual_machine_size"></a> [virtual\_machine\_size](#input\_virtual\_machine\_size) | The Virtual Machine SKU for the Virtual Machine, Default is Standard\_A2\_V2 | `string` | `"Standard_A2_v2"` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network | `any` | `null` | no |
| <a name="input_vm_availability_zone"></a> [vm\_availability\_zone](#input\_vm\_availability\_zone) | The Zone in which this Virtual Machine should be created. Conflicts with availability set and shouldn't use both | `any` | `null` | no |
| <a name="input_vm_time_zone"></a> [vm\_time\_zone](#input\_vm\_time\_zone) | Specifies the Time Zone which should be used by the Virtual Machine | `any` | `null` | no |
| <a name="input_windows_distribution_list"></a> [windows\_distribution\_list](#input\_windows\_distribution\_list) | Pre-defined Azure Windows VM images list | <pre>map(object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  }))</pre> | <pre>{<br>  "mssql2017dev": {<br>    "offer": "SQL2017-WS2019",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "sqldev",<br>    "version": "latest"<br>  },<br>  "mssql2017ent": {<br>    "offer": "SQL2017-WS2019",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "enterprise",<br>    "version": "latest"<br>  },<br>  "mssql2017exp": {<br>    "offer": "SQL2017-WS2019",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "express",<br>    "version": "latest"<br>  },<br>  "mssql2017std": {<br>    "offer": "SQL2017-WS2019",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "standard",<br>    "version": "latest"<br>  },<br>  "mssql2019dev": {<br>    "offer": "sql2019-ws2019",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "sqldev",<br>    "version": "latest"<br>  },<br>  "mssql2019ent": {<br>    "offer": "sql2019-ws2019",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "enterprise",<br>    "version": "latest"<br>  },<br>  "mssql2019ent-byol": {<br>    "offer": "sql2019-ws2019-byol",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "enterprise",<br>    "version": "latest"<br>  },<br>  "mssql2019std": {<br>    "offer": "sql2019-ws2019",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "standard",<br>    "version": "latest"<br>  },<br>  "mssql2019std-byol": {<br>    "offer": "sql2019-ws2019-byol",<br>    "publisher": "MicrosoftSQLServer",<br>    "sku": "standard",<br>    "version": "latest"<br>  },<br>  "windows2012r2dc": {<br>    "offer": "WindowsServer",<br>    "publisher": "MicrosoftWindowsServer",<br>    "sku": "2012-R2-Datacenter",<br>    "version": "latest"<br>  },<br>  "windows2016dc": {<br>    "offer": "WindowsServer",<br>    "publisher": "MicrosoftWindowsServer",<br>    "sku": "2016-Datacenter",<br>    "version": "latest"<br>  },<br>  "windows2016dccore": {<br>    "offer": "WindowsServer",<br>    "publisher": "MicrosoftWindowsServer",<br>    "sku": "2016-Datacenter-Server-Core",<br>    "version": "latest"<br>  },<br>  "windows2019dc": {<br>    "offer": "WindowsServer",<br>    "publisher": "MicrosoftWindowsServer",<br>    "sku": "2019-Datacenter",<br>    "version": "latest"<br>  },<br>  "windows2019dc-containers": {<br>    "offer": "WindowsServer",<br>    "publisher": "MicrosoftWindowsServer",<br>    "sku": "2019-Datacenter-with-Containers",<br>    "version": "latest"<br>  },<br>  "windows2019dc-containers-g2": {<br>    "offer": "WindowsServer",<br>    "publisher": "MicrosoftWindowsServer",<br>    "sku": "2019-datacenter-with-containers-g2",<br>    "version": "latest"<br>  },<br>  "windows2019dc-gensecond": {<br>    "offer": "WindowsServer",<br>    "publisher": "MicrosoftWindowsServer",<br>    "sku": "2019-datacenter-gensecond",<br>    "version": "latest"<br>  },<br>  "windows2019dc-gs": {<br>    "offer": "WindowsServer",<br>    "publisher": "MicrosoftWindowsServer",<br>    "sku": "2019-datacenter-gs",<br>    "version": "latest"<br>  },<br>  "windows2019dccore": {<br>    "offer": "WindowsServer",<br>    "publisher": "MicrosoftWindowsServer",<br>    "sku": "2019-Datacenter-Core",<br>    "version": "latest"<br>  },<br>  "windows2019dccore-g2": {<br>    "offer": "WindowsServer",<br>    "publisher": "MicrosoftWindowsServer",<br>    "sku": "2019-datacenter-core-g2",<br>    "version": "latest"<br>  }<br>}</pre> | no |
| <a name="input_windows_distribution_name"></a> [windows\_distribution\_name](#input\_windows\_distribution\_name) | Variable to pick an OS flavor for Windows based VM. Possible values include: winserver, wincore, winsql | `string` | `"windows2019dc"` | no |
| <a name="input_winrm_protocol"></a> [winrm\_protocol](#input\_winrm\_protocol) | Specifies the protocol of winrm listener. Possible values are `Http` or `Https` | `any` | `null` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Name of the workload\_name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_ssh_key_private"></a> [admin\_ssh\_key\_private](#output\_admin\_ssh\_key\_private) | The generated private key data in PEM format |
| <a name="output_admin_ssh_key_public"></a> [admin\_ssh\_key\_public](#output\_admin\_ssh\_key\_public) | The generated public key data in PEM format |
| <a name="output_linux_virtual_machine_ids"></a> [linux\_virtual\_machine\_ids](#output\_linux\_virtual\_machine\_ids) | The resource id's of all Linux Virtual Machine. |
| <a name="output_linux_vm_password"></a> [linux\_vm\_password](#output\_linux\_vm\_password) | Password for the Linux VM |
| <a name="output_linux_vm_private_ips"></a> [linux\_vm\_private\_ips](#output\_linux\_vm\_private\_ips) | Public IP's map for the all windows Virtual Machines |
| <a name="output_linux_vm_public_ips"></a> [linux\_vm\_public\_ips](#output\_linux\_vm\_public\_ips) | Public IP's map for the all windows Virtual Machines |
| <a name="output_network_security_group_ids"></a> [network\_security\_group\_ids](#output\_network\_security\_group\_ids) | List of Network security groups and ids |
| <a name="output_vm_availability_set_id"></a> [vm\_availability\_set\_id](#output\_vm\_availability\_set\_id) | The resource ID of Virtual Machine availability set |
| <a name="output_windows_virtual_machine_ids"></a> [windows\_virtual\_machine\_ids](#output\_windows\_virtual\_machine\_ids) | The resource id's of all Windows Virtual Machine. |
| <a name="output_windows_vm_password"></a> [windows\_vm\_password](#output\_windows\_vm\_password) | Password for the windows VM |
| <a name="output_windows_vm_private_ips"></a> [windows\_vm\_private\_ips](#output\_windows\_vm\_private\_ips) | Public IP's map for the all windows Virtual Machines |
| <a name="output_windows_vm_public_ips"></a> [windows\_vm\_public\_ips](#output\_windows\_vm\_public\_ips) | Public IP's map for the all windows Virtual Machines |
<!-- END_TF_DOCS -->

## Other resources

* [Windows Virtual Machine](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/)
* [Linux Virtual Machine](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/)
* [Linux VM running SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/linux/sql-vm-create-portal-quickstart)
* [Windows VM running SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-vm-create-portal-quickstart)
* [Terraform AzureRM Provider Documentation](https://www.terraform.io/docs/providers/azurerm/index.html)
