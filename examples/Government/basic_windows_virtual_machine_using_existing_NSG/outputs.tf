output "windows_vm_password" {
  description = "Password for the windows VM"
  sensitive   = true
  value       = module.mod_virtual_machine.windows_vm_password
}

output "windows_vm_public_ips" {
  description = "Public IP's map for the all windows Virtual Machines"
  value       = module.mod_virtual_machine.windows_vm_public_ips
}

output "windows_vm_private_ips" {
  description = "Public IP's map for the all windows Virtual Machines"
  value       = module.mod_virtual_machine.windows_vm_private_ips
}

output "windows_virtual_machine_ids" {
  description = "The resource id's of all Windows Virtual Machine."
  value       = module.mod_virtual_machine.windows_virtual_machine_ids
}

output "network_security_group_ids" {
  description = "List of Network security groups and ids"
  value       = module.mod_virtual_machine.network_security_group_ids
}

output "vm_availability_set_id" {
  description = "The resource ID of Virtual Machine avilability set"
  value       = module.mod_virtual_machine.vm_availability_set_id
}