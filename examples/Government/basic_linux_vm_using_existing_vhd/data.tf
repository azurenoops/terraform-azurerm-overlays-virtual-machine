data "azurerm_resource_group" "custom_image_storage_acct_rg" {
  name = var.custom_boot_image_storage_acct_resource_group_name
}

data "azurerm_storage_account" "custom_image_storage_acct" {
  name                = var.custom_boot_image_storage_acct_name
  resource_group_name = data.azurerm_resource_group.custom_image_storage_acct_rg.name
}