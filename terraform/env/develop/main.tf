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
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

locals {
  name_prefix = "dev"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "keyvault" {
  source                 = "../../modules/keyvault"
  key_vault_name         = "${local.name_prefix}keyvaultcontainer"
  resource_group_name    = var.resource_group_name
  location               = var.location
  tenant_id              = var.tenant_id
  backend_principal_id   = var.backend_principal_id
  base_principal_id      = var.base_principal_id
  product_principal_id   = var.product_principal_id
  container_principal_id = var.container_principal_id
}