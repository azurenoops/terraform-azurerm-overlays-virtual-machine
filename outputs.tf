# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

###############
# Outputs    ##
###############

output "linux_vm_id" {
  description = "Id for the Linux VM, if multiple VM's are created then it will be a list of ids"
  sensitive   = true
  value       = var.custom_boot_image.os_type == "linux" ? azurerm_virtual_machine.custom_vm.*.id : null
}

output "windows_vm_id" {
  description = "Id for the Linux VM, if multiple VM's are created then it will be a list of ids"
  sensitive   = true
  value       = var.custom_boot_image.os_type == "windows" ? azurerm_virtual_machine.custom_vm.*.id : null
}

output "linux_vm_name" {
  description = "Name for the Linux VM, if multiple VM's are created then it will be a list of names"
  sensitive   = true
  value       = var.custom_boot_image.os_type == "linux" ? azurerm_virtual_machine.custom_vm.*.name : null
}

output "windows_vm_name" {
  description = "Name for the Linux VM, if multiple VM's are created then it will be a list of names"
  sensitive   = true
  value       = var.custom_boot_image.os_type == "windows" ? azurerm_virtual_machine.custom_vm.*.name : null
}

output "admin_ssh_key_public" {
  description = "The generated public key data in PEM format"
  value       = var.disable_password_authentication == true && var.generate_admin_ssh_key == true && var.custom_boot_image.os_type == "linux" ? tls_private_key.rsa[0].public_key_openssh : null
}

output "admin_ssh_key_private" {
  description = "The generated private key data in PEM format"
  sensitive   = true
  value       = var.disable_password_authentication == true && var.generate_admin_ssh_key == true && var.custom_boot_image.os_type == "linux" ? tls_private_key.rsa[0].private_key_pem : null
}

output "windows_vm_password" {
  description = "Password for the windows VM"
  sensitive   = true
  value       = var.admin_password == null ? element(concat(random_password.passwd.*.result, [""]), 0) : var.admin_password
}

output "linux_vm_password" {
  description = "Password for the Linux VM"
  sensitive   = true
  value       = var.disable_password_authentication == false && var.admin_password == null ? element(concat(random_password.passwd.*.result, [""]), 0) : var.admin_password
}

output "windows_vm_public_ips" {
  description = "Public IP's map for the all windows Virtual Machines"
  value       = var.enable_public_ip_address == true && var.custom_boot_image.os_type == "windows" ? zipmap(azurerm_virtual_machine.custom_vm.*.name, azurerm_virtual_machine.custom_vm.*.public_ip_addresses) : null
}


output "linux_vm_public_ips" {
  description = "Public IP's map for the all windows Virtual Machines"
  value       = var.enable_public_ip_address == true && var.custom_boot_image.os_type == "linux" ? zipmap(azurerm_virtual_machine.custom_vm.*.name, azurerm_virtual_machine.custom_vm.*.public_ip_addresses) : null
}


output "linux_virtual_machine_ids" {
  description = "The resource id's of all Linux Virtual Machine."
  value       = var.custom_boot_image.os_type == "linux" ? concat(azurerm_virtual_machine.custom_vm.*.id, [""]) : null
}

output "windows_virtual_machine_ids" {
  description = "The resource id's of all Windows Virtual Machine."
  value       = var.custom_boot_image.os_type == "windows" ? concat(azurerm_virtual_machine.custom_vm.*.id, [""]) : null
}

output "network_security_group_ids" {
  description = "List of Network security groups and ids"
  value       = var.existing_network_security_group_name != null ? data.azurerm_network_security_group.nsg.id : null
}

output "vm_availability_set_id" {
  description = "The resource ID of Virtual Machine availability set"
  value       = var.enable_vm_availability_set == true ? element(concat(azurerm_availability_set.aset.*.id, [""]), 0) : null
}

output "linux_vm_identity" {
  description = "Linux Identity block with principal ID"
  value       = var.custom_boot_image.os_type == "linux" ? azurerm_virtual_machine.custom_vm.*.identity : null
}

output "windows_vm_identity" {
  description = "Windows Identity block with principal ID"
  value       = var.custom_boot_image.os_type == "windows" ? azurerm_virtual_machine.custom_vm.*.identity : null
}

output "custom_boot_image" {
  description = "The custom image object"
  value       = azurerm_managed_disk.custom_boot_image
}