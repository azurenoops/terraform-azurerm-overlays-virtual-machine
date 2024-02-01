# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Azurerm provider configuration
provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "custom_image"
  subscription_id = coalesce(var.custom_boot_image.storage_acct_subscription_id, data.azurerm_client_config.current.subscription_id)
  features {}
}