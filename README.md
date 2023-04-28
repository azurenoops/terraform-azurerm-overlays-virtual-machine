# Azure Virtual Machines Overlay Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/azurenoops/overlays-virutal-machine/azurerm/)

This Overlay Terraform module can deploy Azure Windows or Linux virtual machines with support for Public IP, proximity placement group, Availability Set, boot diagnostics, data disks, and Network Security Group. It supports existing ssh keys and produces ssh key pairs for Linux VMs as needed. If you do not provide a special password for Windows VMs it generates random passwords. This module can  be utilized in a [SCCA compliant network](https://registry.terraform.io/modules/azurenoops/overlays-hubspoke/azurerm/latest).

This module allows you to use an existing NSG group. To enable this functionality, replace the input 'existing_network_security_group_id' with the current NSG group's valid resource id and remove all NSG inbound rules from the module.

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

  # Network Seurity group port definitions for each Virtual Machine 
  # NSG association for all network interfaces to be added automatically.
  # If 'existing_network_security_group_id' is supplied, remove this NSG rules block.
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
    Exmaple  = "basic_linux_virtual_machine_using_existing_RG"   
  }
}
```

## Default Local Administrator and the Password

This module employs __'azureadmin'__ as a local administrator. If you want to use a custom username, define it by replacing the input 'admin_username' with a valid user string.

This module creates a strong password by default for all virtual machines. You can vary the length of the random password (currently 24) by using the 'random_password_length = 32' variable. If you wish to set a custom password, use the 'admin_password' option with a valid string.

By default, this module generates an SSH2 key pair for Linux servers; however, it is only suggested for use in a development environment. Please produce your own SSH2 key with a passphrase for production systems and enter the key by specifying the path to the argument `admin_ssh_key_data`..

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

  custom_image = {
      publisher = "myPublisher"
      offer     = "myOffer"
      sku       = "mySKU"
      version   = "latest"
    }

# .... omitted 

}
```

## Custom DNS servers

This optional feature is only applicable if you are using your own DNS servers instead of Azure's default DNS services. To activate this option, use the input 'dns_servers = ["4.4.4.4"]'. Set the input 'dns_servers = ["4.4.4.4", "8.8.8.8"]' for multiple DNS servers.

## Advanced Usage of the Module

### `disable_password_authentication` - enable or disable VM password authentication

It is recommended that ssh2 keys be used rather than passwords while building Linux servers. This module generates the ssh2 key pair for Linux VMs by default. Set the input `disable_password_authentication= false`  if you want the password to login to the Linux VM. This informs the module to generate a random password.

### `enable_ip_forwarding` - enable or disable IP forwarding

Every network interface connected to the virtual machine that receives traffic that the virtual machine must forward must have this setting enabled. A virtual machine can forward traffic whether it is connected to numerous network interfaces or a single network interface. While IP forwarding is an Azure configuration, the virtual machine must also run a traffic-forwarding application, such as a firewall, WAN optimization, or load balancing service. User-defined routes are generally used with IP forwarding.

By default, this not enabled and set to disable. To enable the IP forwarding using this module, set the argument `enable_ip_forwarding = true`.

### `enable_accelerated_networking` for Virtual Machines

Accelerated networking allows a VM to use single root I/O virtualization (SR-IOV), which dramatically improves its networking speed. This high-performance channel avoids the host in the data pipeline, lowering latency, jitter, and CPU utilization for the most demanding network applications on supported VM types.

Most general-purpose and compute-optimized instance sizes with two or more virtual CPUs (vCPUs) support accelerated networking. Dv2/DSv2 and F/Fs are the supported series.

Accelerated networking is supported on instances that enable hyperthreading and have four or more vCPUs. The following series are supported: D/Dsv3, D/Dsv4, E/Esv3, Ea/Easv4, Fsv2, Lsv2, Ms/Mms, and Ms/Mmsv2.

This is not enabled by default and is set to disable. Set the option `enable_accelerated_networking = true` to enable accelerated networking with this module.

### `private_ip_address_allocation_type` - Static IP Assignment

By default, the Azure DHCP servers assign the private IPv4 address for the Azure network interface's principal IP configuration to the network interface within the virtual machine operating system. You should never manually set the IP address of a network interface within the virtual machine's operating system unless absolutely essential.

This is not enabled by default and is set to disable. To use this parameter, specify the argument `private_ip_address_allocation_type = "Static"` and set the parameter `private_ip_address` with a valid static private IP address.

### `dedicated_host_id` - Adding Azure Dedicated Hosts

Azure Dedicated Host is a service that provides physical servers - able to host one or more virtual machines - dedicated to one Azure subscription. Dedicated hosts are the same physical servers used in our data centers, provided as a resource. You can provision dedicated hosts within a region, availability zone, and fault domain. Virtual machine scale sets are not currently supported on dedicated hosts.

By default, this not enabled and set to disable. To add a dedicated host to Virtual machine using this module, set the argument `dedicated_host_id` with valid dedicated host resource ID. It is possible to add Dedicated Host resource outside this module.

### `enable_proximity_placement_group` -  Achieving the lowest possible latency

Placing virtual machines in a single region minimizes the physical distance between them. Placing them in the same availability zone will also bring them closer together physically. However, as the Azure footprint expands, a single availability zone may cover numerous physical data centers, thereby influencing your application's network latency.

You should deploy VMs within a proximity placement group to get them as close as possible while maintaining the lowest possible latency.

A proximity placement group is a logical grouping that ensures Azure compute resources are physically adjacent to one another. Proximity placement groups are effective for applications that demand minimal latency.

This is not enabled by default and is set to disable. To make the Proximity placement group available with this module, set the argument `enable_proximity_placement_group = true`.

### `enable_vm_availability_set` - Create highly available virtual machines

An Availability Set is a logical grouping feature used to isolate VM resources when they are deployed. Azure ensures that the VMs in an Availability Set are distributed over many physical servers, compute racks, storage units, and network switches. If a piece of hardware or software fails, just a subset of your VMs are affected, and your overall solution remains functioning. Availability Sets are critical for developing dependable cloud solutions.

This is not enabled by default and is set to disable. Set the option `enable_vm_availability_set = true` to enable the Availability Set using this module.

### `source_image_id` - Create a VM from a managed image

An Azure managed VM image can be used to generate many virtual machines. A managed VM image provides all of the information required to construct a VM, including the operating system and data drives. The image's virtual hard drives (VHDs), which include both the OS disks and any data disks, are kept as managed disks. A single managed image can support up to 20 concurrent deployments.

When using the managed VM image, custom image, or any other source image reference, the reference is invalid. This is disabled by default and set to utilize predefined or custom images. To use Azure managed VM Image, set the argument `source_image_id` to a valid manage image resource id.

### `license_type` - Bring your own License to your Windows server

With the Azure Hybrid Benefit for Windows Server, you may use your on-premises Windows Server licenses to run Windows virtual machines on Azure at a lower cost. You can utilize Azure Hybrid Benefit for Windows Server to create new virtual machines with the Windows operating system.

This is set to `None` by default. Set the option `license_type` to valid values to leverage the Azure Hybrid Benefit for Windows server deployment via this module. `None,` `Windows_Client,` and `Windows_Server` are all possible values.

### `os_disk_storage_account_type` - Azure managed disks

Azure managed disks are block-level storage volumes managed by Azure that are utilized in conjunction with Azure Virtual Machines. Managed disks are virtualized versions of real disks on on-premises servers. All you have to do with managed disks is define the disk size, disk type, and provision the disk. Azure handles the rest after you provision the disk. Ultra disks, premium solid-state drives (SSD), standard SSDs, and normal hard disk drives (HDD) are all available.

This module by default employs a regular SSD with locally redundant storage (`StandardSSD_LRS`). Set the option `os_disk_storage_account_type` with appropriate values to use different types of disks. Standard_LRS, StandardSSD_LRS, and Premium_LRS are all possible options.

### `Identity` - Configure managed identities for Azure resources on a VM

Azure managed identities provide Azure services with an automatically managed identity in Azure Active Directory. This identity can be used to authenticate to any service that supports Azure AD authentication without requiring credentials in your code.

Managed identities are classified into two types:

* __System-assigned__: When this option is enabled, an identity in Azure AD is created that is related to the lifecycle of that service instance. When the resource is destroyed, Azure deletes the identity as well. Only that Azure resource can use this identity to request tokens from Azure AD by design.
* __User-assigned__: A managed identity that exists as a separate Azure resource. In the case of user-assigned managed IDs, the identity is managed independently of the resources that use it.

A managed identity, regardless of the type of identity chosen, is a particular sort of service principal that can only be utilized with Azure resources. When the managed identity is erased, the associated service principal is also removed.

```terraform
resource "azurerm_user_assigned_identity" "example" {
  for_each            = toset(["user-identity1", "user-identity2"])
  resource_group_name = "rg-shared-westeurope-01"
  location            = "westeurope"
  name                = each.key
}

module "virtual-machine" {
  source  = "azurenoops/overlays-virtual-machine/azurerm"
  version = "x.x.x"

  # .... omitted

  os_flavor               = "linux"
  linux_distribution_name = "ubuntu2004"
  virtual_machine_size    = "Standard_B2s"
  generate_admin_ssh_key  = true
  instances_count         = 2

  # Configure managed identities for Azure resources on a VM
  # Possible types are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`.
  managed_identity_type = "UserAssigned"
  managed_identity_ids  = [for k in azurerm_user_assigned_identity.example : k.id]

# .... omitted

}
```

### `enable_boot_diagnostics` - boot diagnostics to troubleshoot virtual machines

Boot diagnostics is an Azure virtual machine (VM) debugging capability that allows the diagnosis of VM boot issues. Boot diagnostics allow a user to see the state of their virtual machine while it boots up by collecting serial log data and images. This feature was enabled by setting `enable_boot_diagnostics = true`. The Azure Storage Account will be utilized to store Boot Diagnostics, such as Console Output and Hypervisor Screenshots. This module supports the existing storage account by passing a valid name to the`storage_account_name` argument. If no storage account is specified, it will use a Managed Storage Account to store Boot Diagnostics.

### `winrm_protocol` - Enable WinRM wiht HTTPS

Window remote management - in summary, `WinRM` is a built-in Windows protocol/service that connects from another source system using soap[simple object access protocol]. We can connect to the remote system and run any command as the native user.

WinRM is pre-installed on all new Windows operating systems. We must enable the WinRM service and set the ports for external communication. This module configures `winRM` by setting `winrm_protocol = "Https"` and `key_vault_certificate_secret_url` to a Key Vault Certificate's Secret URL.

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

## Using exisging Network Security Groups

To maintain capabilities, enterprise environments require the utilization of pre-existing NSG groups. This module facilitates the use of existing network security groups. Set the input `existing_network_security_group_id` to a valid NSG resource id and delete all NSG inbound rules blocks from the module to use this functionality.

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

  # Network Seurity group port allow definitions for each Virtual Machine
  # NSG association to be added automatically for all network interfaces.
  # Remove this NSG rules block, if `existing_network_security_group_id` is specified
  existing_network_security_group_id = data.azurerm_network_security_group.example.id

# .... omitted for bravity

}
```

## Recommended naming and tagging conventions

Using tags to properly organize your Azure resources, resource groups, and subscriptions into a taxonomy. Each tag is made up of a name and a value pair. For example, you can apply the term `Environment` and the value `Production` to all production resources.
See Resource name and tagging choice guide for advice on how to apply a tagging strategy.

>__Important__ :
For operations, tag names are case-insensitive. A tag with a tag name is updated or retrieved, independent of casing. The resource provider, on the other hand, may preserve the casing you supply for the tag name. Cost reports will show that casing. __The case of tag values is important.__

An effective naming convention creates resource names by incorporating vital resource information into the name. A public IP resource for a production SharePoint workload, for example, is named `pip-sharepoint-prod-westus-001` using these [recommended naming conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging#example-names).

## Other resources

* [Windows Virtual Machine](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/)
* [Linux Virtual Machine](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/)
* [Linux VM running SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/linux/sql-vm-create-portal-quickstart)
* [Windows VM running SQL Server](https://docs.microsoft.com/en-us/azure/azure-sql/virtual-machines/windows/sql-vm-create-portal-quickstart)
* [Terraform AzureRM Provider Documentation](https://www.terraform.io/docs/providers/azurerm/index.html)