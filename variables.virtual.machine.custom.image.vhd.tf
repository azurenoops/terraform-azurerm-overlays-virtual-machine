#####################################
#  Custom VHD Image Configuration   #
#####################################

variable "custom_boot_image" {
  description = "The URI of the custom VHD image to use for the Virtual Machine. This can be a Shared Access Signature (SAS) URI if the VHD is in a different subscription or account."
  type = object({
    os_type = string
    vm_generation = optional(string, "V1")
    storage_uri = string
    storage_acct_id = string
    storage_acct_type = optional(string, "StandardSSD_LRS")
    disk_size_gb = optional(number, 1024)
    availability_zone = optional(string, null)
  })
  default     = null
}

