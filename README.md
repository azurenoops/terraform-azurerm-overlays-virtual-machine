# Azure Virtual Machines Overlay Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/azurenoops/overlays-virtual-machine/azurerm/)

This Overlay Terraform module can deploy Azure Windows or Linux virtual machines based on a custom VHD image that is retrieved from a Storage Account,  The resulting VM has support for Public IP, proximity placement group, Availability Set, boot diagnostics, data disks, and Network Security Group. It supports existing ssh keys and produces ssh key pairs for Linux VMs as needed. If you do not provide a special password for Windows VMs it generates random passwords. This module can be utilized in a [SCCA compliant network](https://registry.terraform.io/modules/azurenoops/overlays-hubspoke/azurerm/latest).

This module requires you to use an existing NSG group. To enable this functionality, replace the input 'existing_network_security_group_name' with the current NSG group's valid resource name and you can use NSG inbound rules from the module.

## Important Notes

- The current version (v0.9) has an issue that appears when the VHD has already been configured with an SSH key.  The module creates the VM from the VHD, but the existing SSH key no longer works. The examples deploy the VM with a VM Admin Password and that works to access the VM. If you need SSH Key access then you will need to go into the Virtual Machine's settings in the Azure Portal to reset the SSH key using the _Reset Password_ option in the _Help_ section.

- This Overlay is based on the _deprecated_ `azurerm_virtual_machine` module because the newer `azurerm_linux_virtual_machine` and `azurerm_windows_virtual_machine` modules do not currently support custom boot images.  When the newer `azurerm` modules support custom boot images, the [`overlays-virtual-machine`](https://registry.terraform.io/modules/azurenoops/overlays-virtual-machine/azurerm/latest) Azure NoOps Overlay module will be updated to handle custom boot images and this Overlay module will be deprecated. 

## Pre-Defined Windows and Linux VM Images

This module should not be used to deploy pre-defined Windows or Linux images. Please use the Azure NoOps [`overlays-virtual-machine`](https://registry.terraform.io/modules/azurenoops/overlays-virtual-machine/azurerm/latest) module instead.

## Marketplace Virtual Machine images

This module should not be used to deploy images from the Azure Marketplace. Please use the Azure NoOps [`overlays-virtual-machine`](https://registry.terraform.io/modules/azurenoops/overlays-virtual-machine/azurerm/latest) module instead.


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
* [Managed OS & Data Disks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk)
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

# Terraform module for deploying a Custom VHD-based Virtual Machine in Azure. 

module "mod_virtual_machine" {
  source  = "azurenoops/overlays-custom-virtual-machine/azurerm"
  version = "~>0.9"

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
```

## Custom Boot Image  

This module will create a new Managed Disk in the target Resource Group. The Managed Disk will be based on the custom VHD image provided. The Managed Disk will be used to create the Virtual Machine.  

> Note: The VHD file must have a `.vhd` extension in the Storage Account.

The `custom_boot_image` input is used to specify the custom boot image to use for the virtual machine. The `custom_boot_image` input is a map with the following keys:  

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vm_generation | The generation of the virtual machine. Possible values are `V1` and `V2`. This value must match the generation of the Custom VHD. | `string` | V1 | no |
| storage_uri | The URI of the custom boot image. The filename must have a `.vhd` extension. | `string` | n/a | yes |
| storage_acct_id | The Resource ID of the storage account where the custom boot image is stored. | `string` | n/a | yes |
| storage_acct_type | The type of the storage account to create when the Managed Disk is created from the custom boot image VHD. Possible values are `Standard_LRS`, `StandardSSD_ZRS`, `Premium_LRS`, `PremiumV2_LRS`, `Premium_ZRS`, `StandardSSD_LRS` or `UltraSSD_LRS`.| `string` | StandardSSD_LRS | yes |
| os_type | The OS type of the custom boot image. Possible values are `Linux` and `Windows`. | `string` | n/a | yes |
| disk_size_gb | The size of the Managed Disk to create in GB. This must be at least as large as the custom VHD image. | `number` | 1024 | yes |
| availability_zone | The Availability Zone where the Managed Disk will be created. | `string` | n/a | no |

   

## Network Security Groups

By default, network security groups are attached to Network Interface and allow just necessary traffic while blocking all others (deny-all rule). In this Terraform module, use `nsg_inbound_rules` to construct a Network Security Group (NSG) for a network interface and allow it to add additional rules for inbound flows.

`VirtualNetwork,` `AzureLoadBalancer,` and `Internet` are service tags rather than IP addresses in the Source and Destination columns. Any in the protocol column includes `TCP`, `UDP`, and `ICMP`. You can choose `TCP`, `UDP`, `ICMP`, or `*` when establishing a rule. In the Source and Destination columns, `0.0.0.0/0` represents all addresses.

*You cannot remove the default rules, but you can override them by creating rules with higher priorities.*

```terraform
module "virtual-machine" {
  source  = "azurenoops/overlays-virtual-machine/azurerm"
  version = "x.x.x"

# .... omitted
  
  custom_boot_image = {
    storage_uri       = "https://sandboxtakfiles.blob.core.windows.net/takvhd/takboot.vhd"
    storage_acct_id   = data.azurerm_storage_account.custom_image_storage_acct.id
    storage_acct_type = "StandardSSD_LRS"
    os_type           = "Linux"
    disk_size_gb      = 1024
    availability_zone = 1
  }

  virtual_machine_size            = "Standard_B2s"
  disable_password_authentication = false
  admin_username                  = "azureadmin"
  admin_password                  = "P@$$w0rd1234!"
  instances_count                 = 1 # Number of VM's to be deployed

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

# .... omitted 
 
  custom_boot_image = {
    storage_uri       = "https://sandboxtakfiles.blob.core.windows.net/takvhd/takboot.vhd"
    storage_acct_id   = data.azurerm_storage_account.custom_image_storage_acct.id
    storage_acct_type = "StandardSSD_LRS"
    os_type           = "Linux"
    disk_size_gb      = 1024
    availability_zone = 1
  }

  virtual_machine_size            = "Standard_B2s"
  disable_password_authentication = false
  admin_username                  = "azureadmin"
  admin_password                  = "P@$$w0rd1234!"
  instances_count                 = 1 # Number of VM's to be deployed

  # Network Security group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.  
  existing_virtual_network_resource_group_name = data.azurerm_virtual_network.example.resource_group_name
  existing_network_security_group_name         = data.azurerm_network_security_group.example.name

# .... omitted 

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

# .... omitted 

  custom_boot_image = {
    storage_uri       = "https://sandboxtakfiles.blob.core.windows.net/takvhd/takboot.vhd"
    storage_acct_id   = data.azurerm_storage_account.custom_image_storage_acct.id
    storage_acct_type = "StandardSSD_LRS"
    os_type           = "Linux"
    disk_size_gb      = 1024
    availability_zone = 1
  }

  virtual_machine_size            = "Standard_B2s"
  disable_password_authentication = false
  admin_username                  = "azureadmin"
  admin_password                  = "P@$$w0rd1234!"
  instances_count                 = 1 # Number of VM's to be deployed

  # Network Security group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.  
  existing_network_security_group_name = data.azurerm_network_security_group.example.name

# .... omitted 

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
| [azurerm_virtual_machine.custom_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
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
| [azurerm_virtual_machine.custom_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
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
| <a name="input_custom_boot_image"></a> [custom\_boot\_image](#input\_custom\_boot\_image) | Provide the custom VHD information to this module.  | <pre>object({<br/>  os_type = string<br/>  vm_generation = optional(string, "V1")<br/>  storage_uri = string<br/>  storage_acct_id = string<br/>  storage_acct_type = optional(string, "StandardSSD_LRS")<br/>  disk_size_gb = optional(number, 1024)<br/>  availability_zone = optional(string, null)<br/>})</pre> | `null` | no |
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
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name of the hub storage account to store logs | `any` | `null` | no |
| <a name="input_storage_account_uri"></a> [storage\_account\_uri](#input\_storage\_account\_uri) | The Primary/Secondary Endpoint for the Azure Storage Account which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor. Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics. | `any` | `null` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The name of the subnet to use in VM scale set | `any` | `null` | no |
| <a name="input_use_location_short_name"></a> [use\_location\_short\_name](#input\_use\_location\_short\_name) | Use short location name for resources naming (ie eastus -> eus). Default is true. If set to false, the full cli location name will be used. if custom naming is set, this variable will be ignored. | `bool` | `true` | no |
| <a name="input_use_naming"></a> [use\_naming](#input\_use\_naming) | Use the Azure NoOps naming provider to generate default resource name. `storage_account_custom_name` override this if set. Legacy default name is used if this is set to `false`. | `bool` | `true` | no |
| <a name="input_virtual_machine_size"></a> [virtual\_machine\_size](#input\_virtual\_machine\_size) | The Virtual Machine SKU for the Virtual Machine, Default is Standard\_A2\_V2 | `string` | `"Standard_A2_v2"` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network | `any` | `null` | no |
| <a name="input_vm_availability_zone"></a> [vm\_availability\_zone](#input\_vm\_availability\_zone) | The Zone in which this Virtual Machine should be created. Conflicts with availability set and shouldn't use both | `any` | `null` | no |
| <a name="input_vm_time_zone"></a> [vm\_time\_zone](#input\_vm\_time\_zone) | Specifies the Time Zone which should be used by the Virtual Machine | `any` | `null` | no |
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
