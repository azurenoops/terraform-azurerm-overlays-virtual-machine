# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

####################################
# Generic naming Configuration    ##
####################################
variable "name_prefix" {
  description = "Optional prefix for the generated name"
  type        = string
  default     = ""
}

variable "name_suffix" {
  description = "Optional suffix for the generated name"
  type        = string
  default     = ""
}

variable "use_naming" {
  description = "Use the Azure NoOps naming provider to generate default resource name. `storage_account_custom_name` override this if set. Legacy default name is used if this is set to `false`."
  type        = bool
  default     = true
}

# Custom naming override
variable "custom_resource_group_name" {
  description = "The name of the resource group in which the resources will be created in. If not provided, a new resource group will be created with the name '<org_name>-<environment>-<workload_name>-rg'"
  type        = string
  default     = null
}

variable "custom_linux_vm_name" {
  description = "Custom name for the Linux Virtual Machine. Generated if not set."
  type        = string
  default     = ""
}

variable "custom_windows_vm_name" {
  description = "Custom name for the Windows Virtual Machine. Generated if not set."
  type        = string
  default     = ""
}

variable "custom_computer_name" {
  description = "Custom name for the Windows Virtual Machine Hostname. `vm_name` if not set."
  type        = string
  default     = ""
}

variable "custom_public_ip_name" {
  description = "Custom name for public IP. Generated if not set."
  type        = string
  default     = null
}

variable "custom_nic_name" {
  description = "Custom name for the NIC interface. Generated if not set."
  type        = string
  default     = null
}

variable "custom_ipconfig_name" {
  description = "Custom name for the IP config of the NIC. Generated if not set."
  type        = string
  default     = null
}

variable "os_disk_custom_name" {
  description = "Custom name for OS disk. Generated if not set."
  type        = string
  default     = null
}

variable "custom_dcr_name" {
  description = "Custom name for Data collection rule association"
  type        = string
  default     = null
}