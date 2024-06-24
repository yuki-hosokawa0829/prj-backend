# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

## Terraform configuration

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.54.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = var.backend_resource_group_name
    storage_account_name = var.backend_storage_account_name
    container_name       = var.backend_container_name
    key                  = var.backend_key
    use_azuread_auth     = true
  }

  required_version = ">= 1.2.6"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

locals {
  name_prefix   = "dev"
  secret_keys   = split(",", var.secret_name_list)
  secret_values = split(",", replace(var.secret_value_list, "\r", ""))
  secret_map    = { for idx, key in local.secret_keys : key => local.secret_values[idx] }
}

module "keyvault" {
  source                 = "../../modules/kv"
  key_vault_name         = "${local.name_prefix}keyvaultcontainer"
  secret_map             = local.secret_map
  resource_group_name    = var.resource_group_name
  location               = var.location
  tenant_id              = var.tenant_id
  backend_principal_id   = var.backend_principal_id
  base_principal_id      = var.base_principal_id
  product_principal_id   = var.product_principal_id
  container_principal_id = var.container_principal_id
}