# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#######################
# VM Configuration   ##
#######################

variable "random_password_length" {
  description = "The desired length of random password created by this module"
  default     = 24
}

variable "instances_count" {
  description = "The number of Virtual Machines required. Default is 1."
  default     = 1
}

variable "os_type" {
  description = "Specify the type of the operating system image to deploy Virtual Machine. Valid values are `windows` and `linux` Default vaule is `windows`"
  default     = "windows"
}

variable "virtual_machine_size" {
  description = "The Virtual Machine SKU for the Virtual Machine, Default is Standard_A2_V2"
  default     = "Standard_A2_v2"
}

variable "disable_password_authentication" {
  description = "Should Password Authentication be disabled on this Linux Virtual Machine? Defaults to true."
  default     = true
}

variable "admin_username" {
  description = "The username of the local administrator used for the Virtual Machine."
  default     = "azureadmin"
}

variable "admin_password" {
  description = "The Password which should be used for the local-administrator on this Virtual Machine"
  default     = null
}

variable "source_image_id" {
  description = "The ID of an Image which each Virtual Machine should be based on"
  default     = null
}

variable "dedicated_host_id" {
  description = "The ID of a Dedicated Host where this machine should be run on."
  default     = null
}

variable "custom_data" {
  description = "Base64 encoded file of a bash script that gets run once by cloud-init upon VM creation"
  default     = null
}

variable "enable_automatic_updates" {
  description = "Specifies if Automatic Updates are Enabled for the Windows Virtual Machine."
  default     = false
}

variable "enable_encryption_at_host" {
  description = " Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?"
  default     = false
}

variable "license_type" {
  description = "Specifies the type of on-premise license which should be used for this Virtual Machine. Possible values are None, Windows_Client and Windows_Server."
  default     = "None"
}

variable "vm_time_zone" {
  description = "Specifies the Time Zone which should be used by the Virtual Machine"
  default     = null
}

variable "generate_admin_ssh_key" {
  description = "Generates a secure private key and encodes it as PEM."
  default     = false
}

variable "admin_ssh_key_data" {
  description = "specify the path to the existing SSH key to authenticate Linux virtual machine"
  default     = null
}

variable "use_spot_instances" {
  description = "Should spot instances be used insted of regular VM. Default is false."
  default     = false
  type        = bool
}

variable "vm_eviction_policy" {
  description = "Specifies what should happen when the Virtual Machine is evicted. Only relevant if use_spot_instances is set to true. Default is Delete."
  type        = string
  default     = "Delete"
  validation {
    condition     = contains(["delete", "deallocates"], lower(var.vm_eviction_policy))
    error_message = "Allowed values for virtual_machine_eviction_policy are \"delete\" or \"deallocates\"."
  }
}

variable "max_bid_price" {
  type        = number
  description = "Specifies the maximum price that should be paid for this VM, in US Dollars. Only relevant if use_spot_instances is set to true. Default is -1, which means that the Virtual Machine should not be evicted for price reasons."
  default     = -1
}

##############################
# VM Network Configuration  ##
##############################

variable "existing_virtual_network_resource_group_name" {
  description = "The name of the virtual network resource group to attach Subnet and NSG to VMs. It can be different from the VM resource group."
  default     = null
}

variable "existing_virtual_network_name" {
  description = "The name of the virtual network to attach Subnet and NSG to VMs. It can be different from the VM resource group."
  default     = null
}

variable "existing_subnet_name" {
  description = "The name of the subnet to attach Subnet and NSG to VMs. It can be different from the VM resource group."
  default     = null
}

variable "additional_nic_configuration" {
  description = "Additional configurations for a second network interface.  Secondary NIC always has a private IP address."
  type = object({
    subnet_id                     = string
    private_ip_address            = string
  })
  default = null
}

###########################
# VM Dns Configuration   ##
###########################

variable "domain_name_label" {
  description = "Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
  default     = null
}

variable "dns_servers" {
  description = "List of dns servers to use for network interface"
  default     = []
}

variable "enable_accelerated_networking" {
  description = "Should Accelerated Networking be enabled? Defaults to false."
  default     = false
}

variable "internal_dns_name_label" {
  description = "The (relative) DNS Name used for internal communications between Virtual Machines in the same Virtual Network."
  default     = null
}

###########################
# VM PIP Configuration   ##
###########################

variable "enable_public_ip_address" {
  description = "Reference to a Public IP Address to associate with the NIC"
  default     = null
}

variable "public_ip_allocation_method" {
  description = "Defines the allocation method for this IP address. Possible values are `Static` or `Dynamic`"
  default     = "Static"
}

variable "public_ip_sku" {
  description = "The SKU of the Public IP. Accepted values are `Basic` and `Standard`"
  default     = "Standard"
}

variable "public_ip_availability_zone" {
  description = "The availability zone to allocate the Public IP in. Possible values are `1`,`2`,`3`"
  default     = ["1", "2", "3"]
}

variable "public_ip_sku_tier" {
  description = "The SKU Tier that should be used for the Public IP. Possible values are `Regional` and `Global`"
  default     = "Regional"
}

variable "private_ip_address_allocation_type" {
  description = "The allocation method used for the Private IP Address. Possible values are Dynamic and Static."
  default     = "Dynamic"
}

variable "private_ip_address" {
  description = "The Static IP Address which should be used. This is valid only when `private_ip_address_allocation` is set to `Static` "
  default     = null
}

variable "enable_ip_forwarding" {
  description = "Should IP Forwarding be enabled? Defaults to false"
  default     = false
}

#####################################
# VM Load Balancer Configuration   ##
#####################################

variable "attach_load_balancer" {
  description = "True to attach this VM to a Load Balancer"
  type        = bool
  default     = false
}

variable "load_balancer_backend_pool_id" {
  description = "Id of the Load Balancer Backend Pool to attach the VM."
  type        = string
  default     = null
}

###########################################
# VM Application Gateway Configuration   ##
###########################################

variable "attach_application_gateway" {
  description = "True to attach this VM to an Application Gateway"
  type        = bool
  default     = false
}

variable "application_gateway_backend_pool_id" {
  description = "Id of the Application Gateway Backend Pool to attach the VM."
  type        = string
  default     = null
}

####################################
# VM Availability Configuration   ##
####################################

variable "enable_vm_availability_set" {
  description = "Manages an Availability Set for Virtual Machines."
  default     = false
}

variable "vm_availability_zone" {
  description = "The Zone in which this Virtual Machine should be created. Conflicts with availability set and shouldn't use both"
  default     = null
}

variable "platform_fault_domain_count" {
  description = "Specifies the number of fault domains that are used"
  default     = 3
}
variable "platform_update_domain_count" {
  description = "Specifies the number of update domains that are used"
  default     = 5
}

variable "enable_proximity_placement_group" {
  description = "Manages a proximity placement group for virtual machines, virtual machine scale sets and availability sets."
  default     = false
}

###########################
# VM NSG Configuration   ##
###########################

variable "existing_network_security_group_name" {
  description = "The resource name of existing network security group"
  default     = null
}

variable "nsg_inbound_rules" {
  description = "List of network rules to apply to network interface."
  default     = []
}

#############################
# VM Image Configuration   ##
#############################

variable "custom_image" {
  description = "Provide the custom image to this module if the defaults provided in the linux_distribution_list or windows_distribution_list variables are not sufficient. You must also set the custom_image_plan variable."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = null
}

variable "custom_image_plan" {
  description = "Virtual Machine custom image plan information. See https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine#plan. This variable has to be used for BYOS image. Before using BYOS image, you need to accept legal plan terms. See https://docs.microsoft.com/en-us/cli/azure/vm/image?view=azure-cli-latest#az_vm_image_accept_terms."
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  default = null
}

variable "linux_distribution_list" {
  description = "Pre-defined Azure Linux VM images list"
  type = map(object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  }))

  default = {
    ubuntu1604 = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "16.04-LTS"
      version   = "latest"
    },

    ubuntu1804 = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      version   = "latest"
    },

    ubuntu1904 = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "19.04"
      version   = "latest"
    },

    ubuntu2004 = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-focal-daily"
      sku       = "20_04-daily-lts"
      version   = "latest"
    },

    ubuntu2004-gen2 = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-focal-daily"
      sku       = "20_04-daily-lts-gen2"
      version   = "latest"
    },

    centos77 = {
      publisher = "OpenLogic"
      offer     = "CentOS"
      sku       = "7.7"
      version   = "latest"
    },

    centos78-gen2 = {
      publisher = "OpenLogic"
      offer     = "CentOS"
      sku       = "7_8-gen2"
      version   = "latest"
    },

    centos79-gen2 = {
      publisher = "OpenLogic"
      offer     = "CentOS"
      sku       = "7_9-gen2"
      version   = "latest"
    },

    centos81 = {
      publisher = "OpenLogic"
      offer     = "CentOS"
      sku       = "8_1"
      version   = "latest"
    },

    centos81-gen2 = {
      publisher = "OpenLogic"
      offer     = "CentOS"
      sku       = "8_1-gen2"
      version   = "latest"
    },

    centos82-gen2 = {
      publisher = "OpenLogic"
      offer     = "CentOS"
      sku       = "8_2-gen2"
      version   = "latest"
    },

    centos83-gen2 = {
      publisher = "OpenLogic"
      offer     = "CentOS"
      sku       = "8_3-gen2"
      version   = "latest"
    },

    centos84-gen2 = {
      publisher = "OpenLogic"
      offer     = "CentOS"
      sku       = "8_4-gen2"
      version   = "latest"
    },

    coreos = {
      publisher = "CoreOS"
      offer     = "CoreOS"
      sku       = "Stable"
      version   = "latest"
    },

    rhel78 = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "7.8"
      version   = "latest"
    },

    rhel78-gen2 = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "78-gen2"
      version   = "latest"
    },

    rhel79 = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "7.9"
      version   = "latest"
    },

    rhel79-gen2 = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "79-gen2"
      version   = "latest"
    },

    rhel81 = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "8.1"
      version   = "latest"
    },

    rhel81-gen2 = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "81gen2"
      version   = "latest"
    },

    rhel82 = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "8.2"
      version   = "latest"
    },

    rhel82-gen2 = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "82gen2"
      version   = "latest"
    },

    rhel83 = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "8.3"
      version   = "latest"
    },

    rhel83-gen2 = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "83gen2"
      version   = "latest"
    },

    rhel84 = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "8.4"
      version   = "latest"
    },

    rhel84-gen2 = {
      publisher = "RedHat"
      offer     = "RHEL"
      sku       = "84gen2"
      version   = "latest"
    },

    rhel84-byos = {
      publisher = "RedHat"
      offer     = "rhel-byos"
      sku       = "rhel-lvm84"
      version   = "latest"
    },

    rhel84-byos-gen2 = {
      publisher = "RedHat"
      offer     = "rhel-byos"
      sku       = "rhel-lvm84-gen2"
      version   = "latest"
    },

    mssql2019ent-rhel8 = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-rhel8"
      sku       = "enterprise"
      version   = "latest"
    },

    mssql2019std-rhel8 = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-rhel8"
      sku       = "standard"
      version   = "latest"
    },

    mssql2019dev-rhel8 = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-rhel8"
      sku       = "sqldev"
      version   = "latest"
    },

    mssql2019ent-ubuntu1804 = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ubuntu1804"
      sku       = "enterprise"
      version   = "latest"
    },

    mssql2019std-ubuntu1804 = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ubuntu1804"
      sku       = "standard"
      version   = "latest"
    },

    mssql2019dev-ubuntu1804 = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ubuntu1804"
      sku       = "sqldev"
      version   = "latest"
    },

    mssql2019ent-ubuntu2004 = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ubuntu2004"
      sku       = "enterprise"
      version   = "latest"
    },

    mssql2019std-ubuntu2004 = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ubuntu2004"
      sku       = "standard"
      version   = "latest"
    },

    mssql2019dev-ubuntu2004 = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ubuntu2004"
      sku       = "sqldev"
      version   = "latest"
    },
  }
}

variable "linux_distribution_name" {
  default     = "ubuntu1804"
  description = "Variable to pick an OS flavor for Linux based VM. Possible values include: centos8, ubuntu1804"
}

variable "windows_distribution_list" {
  description = "Pre-defined Azure Windows VM images list"
  type = map(object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  }))

  default = {
    windows2012r2dc = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2012-R2-Datacenter"
      version   = "latest"
    },

    windows2016dc = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2016-Datacenter"
      version   = "latest"
    },

    windows2019dc = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter"
      version   = "latest"
    },

    windows2019dc-gensecond = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-datacenter-gensecond"
      version   = "latest"
    },

    windows2019dc-gs = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-datacenter-gs"
      version   = "latest"
    },

    windows2019dc-containers = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter-with-Containers"
      version   = "latest"
    },

    windows2019dc-containers-g2 = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-datacenter-with-containers-g2"
      version   = "latest"
    },

    windows2019dccore = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-Datacenter-Core"
      version   = "latest"
    },

    windows2019dccore-g2 = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2019-datacenter-core-g2"
      version   = "latest"
    },

    windows2016dccore = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2016-Datacenter-Server-Core"
      version   = "latest"
    },

    mssql2017exp = {
      publisher = "MicrosoftSQLServer"
      offer     = "SQL2017-WS2019"
      sku       = "express"
      version   = "latest"
    },

    mssql2017dev = {
      publisher = "MicrosoftSQLServer"
      offer     = "SQL2017-WS2019"
      sku       = "sqldev"
      version   = "latest"
    },

    mssql2017std = {
      publisher = "MicrosoftSQLServer"
      offer     = "SQL2017-WS2019"
      sku       = "standard"
      version   = "latest"
    },

    mssql2017ent = {
      publisher = "MicrosoftSQLServer"
      offer     = "SQL2017-WS2019"
      sku       = "enterprise"
      version   = "latest"
    },

    mssql2019std = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019"
      sku       = "standard"
      version   = "latest"
    },

    mssql2019dev = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019"
      sku       = "sqldev"
      version   = "latest"
    },

    mssql2019ent = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019"
      sku       = "enterprise"
      version   = "latest"
    },

    mssql2019ent-byol = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019-byol"
      sku       = "enterprise"
      version   = "latest"
    },

    mssql2019std-byol = {
      publisher = "MicrosoftSQLServer"
      offer     = "sql2019-ws2019-byol"
      sku       = "standard"
      version   = "latest"
    }
  }
}

variable "windows_distribution_name" {
  default     = "windows2019dc"
  description = "Variable to pick an OS flavor for Windows based VM. Possible values include: winserver, wincore, winsql"
}

#################################
# VM Identity Configuration    ##
#################################

variable "managed_identity_type" {
  description = "The type of Managed Identity which should be assigned to the Linux Virtual Machine. Possible values are `SystemAssigned`, `UserAssigned` and `SystemAssigned, UserAssigned`"
  default     = null
}

variable "managed_identity_ids" {
  description = "A list of User Managed Identity ID's which should be assigned to the Linux Virtual Machine."
  default     = null
}

variable "winrm_protocol" {
  description = "Specifies the protocol of winrm listener. Possible values are `Http` or `Https`"
  default     = null
}

variable "key_vault_certificate_secret_url" {
  description = "The Secret URL of a Key Vault Certificate, which must be specified when `protocol` is set to `Https`"
  default     = null
}

variable "additional_unattend_content" {
  description = "The XML formatted content that is added to the unattend.xml file for the specified path and component."
  default     = null
}

variable "additional_unattend_content_setting" {
  description = "The name of the setting to which the content applies. Possible values are `AutoLogon` and `FirstLogonCommands`"
  default     = null
}

#####################################
# VM Data Storage Configuration    ##
#####################################

variable "enable_boot_diagnostics" {
  description = "Should the boot diagnostics enabled?"
  default     = false
}

variable "storage_account_uri" {
  description = "The Primary/Secondary Endpoint for the Azure Storage Account which should be used to store Boot Diagnostics, including Console Output and Screenshots from the Hypervisor. Passing a `null` value will utilize a Managed Storage Account to store Boot Diagnostics."
  default     = null
}

variable "data_disks" {
  description = "Managed Data Disks for azure virtual machines"
  type = list(object({
    name                 = string
    storage_account_type = string
    disk_size_gb         = number
  }))
  default = []
}

variable "os_disk_storage_account_type" {
  description = "The Type of Storage Account which should back this the Internal OS Disk. Possible values include Standard_LRS, StandardSSD_LRS and Premium_LRS."
  default     = "StandardSSD_LRS"
}

variable "os_disk_caching" {
  description = "The Type of Caching which should be used for the Internal OS Disk. Possible values are `None`, `ReadOnly` and `ReadWrite`"
  default     = "ReadWrite"
}

variable "disk_encryption_set_id" {
  description = "The ID of the Disk Encryption Set which should be used to Encrypt this OS Disk. The Disk Encryption Set must have the `Reader` Role Assignment scoped on the Key Vault - in addition to an Access Policy to the Key Vault"
  default     = null
}

variable "disk_size_gb" {
  description = "The Size of the Internal OS Disk in GB, if you wish to vary from the size used in the image this Virtual Machine is sourced from."
  default     = null
}

variable "enable_os_disk_write_accelerator" {
  description = "Should Write Accelerator be Enabled for this OS Disk? This requires that the `storage_account_type` is set to `Premium_LRS` and that `caching` is set to `None`."
  default     = false
}

variable "os_disk_name" {
  description = "The name which should be used for the Internal OS Disk"
  default     = null
}

variable "enable_ultra_ssd_data_disk_storage_support" {
  description = "Should the capacity to enable Data Disks of the UltraSSD_LRS storage account type be supported on this Virtual Machine"
  default     = false
}

#####################################
# VM log analytics Configuration   ##
#####################################

variable "nsg_diag_logs" {
  description = "NSG Monitoring Category details for Azure Diagnostic setting"
  default     = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]
}

variable "log_analytics_workspace_id" {
  description = "The name of log analytics workspace resource id"
  default     = null
}

variable "log_analytics_customer_id" {
  description = "The Workspace (or Customer) ID for the Log Analytics Workspace."
  default     = null
}

variable "log_analytics_workspace_primary_shared_key" {
  description = "The Primary shared key for the Log Analytics Workspace"
  default     = null
}

variable "storage_account_name" {
  description = "The name of the hub storage account to store logs"
  default     = null
}

variable "deploy_log_analytics_agent" {
  description = "Install log analytics agent to windows or linux VM"
  default     = false
}

##############################
# VM Backup Configuration   ##
##############################

variable "backup_policy_id" {
  description = "Backup policy ID from the Recovery Vault to attach the Virtual Machine to (value to `null` to disable backup)"
  type        = string
  default     = null
}

variable "patch_mode" {
  description = "Specifies the mode of in-guest patching to Linux or Windows Virtual Machine. Possible values are `Manual`, `AutomaticByOS` and `AutomaticByPlatform`"
  default     = "AutomaticByPlatform"
}

##################################
# VM Mintenance Configurations  ##
##################################

variable "maintenance_configuration_ids" {
  description = "List of maintenance configurations to attach to this VM."
  type        = list(string)
  default     = []
}
