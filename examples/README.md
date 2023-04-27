# Azure Virtual Machines Overlay Terraform Module

Terraform overlay module for Azure Windows or Linux virtual machine deployment with support for Public IP, proximity placement group, Availability Set, boot diagnostics, data drives, and Network Security Group. It supports existing ssh keys and produces ssh key pairs for Linux VMs as needed. If you do not provide a special password for Windows VMs, it generates random passwords.

This module allows you to use an existing NSG group. To enable this functionality, replace the input 'existing_network_security_group_id' with the current NSG group's valid resource id and remove all NSG inbound rules from the module.

## Module Usage for

* [Linux Virtual Machine using Resource Group](basic_linux_virtual_machine_using_existing_RG/)
* [Windows Virtual Machine using Existing NSG](basic_windows_virtual_machine_using_existing_NSG/)

## Terraform Usage

To run this example you need to execute following Terraform commands

```terraform
terraform init
terraform plan
terraform apply
```

Run `terraform destroy` when you don't need these resources.

## Outputs

|Name | Description|
|---- | -----------|
`admin_ssh_key_public`|The generated public key data in PEM format
`admin_ssh_key_private`|The generated private key data in PEM format
`windows_vm_password`|Password for the Windows Virtual Machine
`linux_vm_password`|Password for the Linux Virtual Machine
`windows_vm_public_ips`|Public IP's map for the all windows Virtual Machines
`linux_vm_public_ips`|Public IP's map for the all windows Virtual Machines
`windows_vm_private_ips`|Public IP's map for the all windows Virtual Machines
`linux_vm_private_ips`|Public IP's map for the all windows Virtual Machines
`linux_virtual_machine_ids`|The resource id's of all Linux Virtual Machine
`windows_virtual_machine_ids`|The resource id's of all Windows Virtual Machine
`network_security_group_ids`|List of Network security groups and ids
`vm_availability_set_id`|The resource ID of Virtual Machine availability set