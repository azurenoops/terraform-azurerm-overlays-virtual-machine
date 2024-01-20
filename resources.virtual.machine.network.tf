# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------
# Network Interface for Virtual Machine
#---------------------------------------
resource "azurerm_network_interface" "nic" {
  count                         = var.instances_count
  name                          = var.instances_count == 1 ? lower("${local.vm_nic_name}") : lower("nic-${format("%s%s", lower(replace(local.vm_nic_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
  location                      = local.location
  resource_group_name           = local.resource_group_name
  dns_servers                   = var.dns_servers
  enable_ip_forwarding          = var.enable_ip_forwarding
  enable_accelerated_networking = var.enable_accelerated_networking
  internal_dns_name_label       = var.internal_dns_name_label
  tags                          = merge({ "ResourceName" = var.instances_count == 1 ? lower("${local.vm_nic_name}") : lower("nic-${format("%s%s", lower(replace(local.vm_nic_name, "/[[:^alnum:]]/", "")), count.index + 1)}") }, var.add_tags, var.nic_add_tags, )

  ip_configuration {
    name                          = lower("ipconfig-${format("%s%s", lower(replace(local.ip_configuration_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
    primary                       = true
    subnet_id                     = data.azurerm_subnet.snet.0.id
    private_ip_address_allocation = var.private_ip_address_allocation_type
    private_ip_address            = var.private_ip_address_allocation_type == "Static" ? element(concat(var.private_ip_address, [""]), count.index) : null
    public_ip_address_id          = var.enable_public_ip_address == true ? element(concat(azurerm_public_ip.pip.*.id, [""]), count.index) : null
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}


resource "azurerm_network_interface" "secondary_nic" {
  count                         = var.additional_nic_configuration != null ? var.instances_count : 0
  name                          = var.instances_count == 1 ? lower("${local.vm_secondary_nic_name}") : lower("nic-${format("%s%s", lower(replace(local.vm_secondary_nic_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
  location                      = local.location
  resource_group_name           = local.resource_group_name
  dns_servers                   = var.dns_servers
  enable_ip_forwarding          = var.enable_ip_forwarding
  enable_accelerated_networking = var.enable_accelerated_networking
  internal_dns_name_label       = var.internal_dns_name_label
  tags                          = merge({ "ResourceName" = var.instances_count == 1 ? lower("${local.vm_secondary_nic_name}") : lower("nic-${format("%s%s", lower(replace(local.vm_secondary_nic_name, "/[[:^alnum:]]/", "")), count.index + 1)}") }, var.add_tags, var.nic_add_tags, )

  ip_configuration {
    name                          = lower("ipconfig-${format("%s%s", lower(replace(local.secondary_ip_configuration_name, "/[[:^alnum:]]/", "")), count.index + 1)}")
    primary                       = true
    subnet_id                     = lookup(var.additional_nic_configuration, "subnet_id", null)
    private_ip_address_allocation = "Static"
    private_ip_address            = lookup(var.additional_nic_configuration, "private_ip_address", null)
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

#---------------------------------------------------------------
# Network security group for Virtual Machine Network Interface
#---------------------------------------------------------------
resource "azurerm_network_security_rule" "nsg_rule" {
  for_each                    = { for k, v in local.nsg_inbound_rules : k => v if k != null }
  name                        = each.key
  priority                    = 100 * (each.value.idx + 1)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = each.value.security_rule.destination_port_range
  source_address_prefix       = each.value.security_rule.source_address_prefix
  destination_address_prefix  = element(concat(data.azurerm_subnet.snet.0.address_prefixes, [""]), 0)
  description                 = "Inbound_Port_${each.value.security_rule.destination_port_range}"
  resource_group_name         = data.azurerm_network_security_group.nsg.resource_group_name
  network_security_group_name = data.azurerm_network_security_group.nsg.name
}

resource "azurerm_network_interface_security_group_association" "nsgassoc" {
  count                     = var.instances_count
  network_interface_id      = element(concat(azurerm_network_interface.nic.*.id, [""]), count.index)
  network_security_group_id = data.azurerm_network_security_group.nsg.id
}
