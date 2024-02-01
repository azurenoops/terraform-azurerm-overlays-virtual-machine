variable "location" {
  description = "Azure region in which instance will be hosted"
  type        = string
  default     = "eastus"
}

variable "deploy_environment" {
  description = "Name of the workload's environnement"
  type        = string
  default     = "dev"
}

variable "workload_name" {
  description = "Name of the workload_name"
  type        = string
  default     = "vm-linux-vhd"
}

variable "org_name" {
  description = "Name of the organization"
  type        = string
  default     = "anoa"
}

#####################################
#  Custom VHD Image Configuration   #
#####################################

variable "custom_boot_image_storage_acct_name" {
  description = "The name of the storage account to use for the custom VHD image."
  type        = string
  default     = null
}

variable "custom_boot_image_storage_acct_resource_group_name" {
  description = "The name of the resource group containing the storage account to use for the custom VHD image."
  type        = string
  default     = null
}
