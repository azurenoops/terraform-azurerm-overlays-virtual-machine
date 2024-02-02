
resource "azurerm_managed_disk" "custom_boot_image" {
  count                = var.instances_count
  name                 = local.vm_os_disk_name
  location             = local.location
  resource_group_name  = local.resource_group_name
  storage_account_type = var.custom_boot_image.storage_acct_type
  create_option        = "Import"
  source_uri           = var.custom_boot_image.storage_uri
  storage_account_id   = var.custom_boot_image.storage_acct_id
  os_type              = var.custom_boot_image.os_type
  disk_size_gb         = var.custom_boot_image.disk_size_gb
  zone                 = var.custom_boot_image.availability_zone
  tags                 = merge({ "ResourceName" = local.vm_os_disk_name }, var.add_tags, var.os_disk_add_tags, )

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
