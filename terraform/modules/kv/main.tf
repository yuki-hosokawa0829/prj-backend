resource "azurerm_key_vault" "kv" {
  name                      = var.key_vault_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  sku_name                  = "standard"
  tenant_id                 = var.tenant_id
  enable_rbac_authorization = true
}

resource "azurerm_role_assignment" "backend_app_secret" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.backend_principal_id
}

resource "azurerm_role_assignment" "backend_app_cert" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = var.backend_principal_id
}

resource "azurerm_role_assignment" "base_app_secret" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.base_principal_id
}

resource "azurerm_role_assignment" "product_app_secret" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.product_principal_id
}

resource "azurerm_role_assignment" "container_app_secret" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.container_principal_id
}