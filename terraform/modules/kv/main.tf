resource "azurerm_key_vault" "kv" {
  name                       = var.key_vault_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  sku_name                   = "standard"
  tenant_id                  = var.tenant_id
  enable_rbac_authorization  = true
  soft_delete_retention_days = 7
}

resource "azurerm_key_vault_secret" "secret" {
  for_each     = var.secret_map
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.kv.id

  # Set role assignments for the service principal
  depends_on = [
    azurerm_role_assignment.backend_app_secret_officer
  ]
}

#resource "azurerm_key_vault_certificate" "aks_cert" {
#  name         = "imported-cert"
#  key_vault_id = azurerm_key_vault.example.id

#  certificate {
#    contents = filebase64(var.aks_certificate_path)
#    password = var.aks_certificate_password
#  }
#}

resource "azurerm_role_assignment" "backend_app_secret_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.backend_principal_id
}

resource "azurerm_role_assignment" "backend_app_cert_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Certificates Officer"
  principal_id         = var.backend_principal_id
}

resource "azurerm_role_assignment" "backend_app_crypto_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = var.backend_principal_id
}

resource "azurerm_role_assignment" "base_app_cert_user" {
  count                = var.project_suffix == "base" ? 1 : 0
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = var.base_principal_id
}

resource "azurerm_role_assignment" "product_app_secret_officer" {
  count                = var.project_suffix == "product" ? 1 : 0
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.product_principal_id
}

resource "azurerm_role_assignment" "container_app_secret_user" {
  count                = var.project_suffix == "container" ? 1 : 0
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.container_principal_id
}

resource "azurerm_role_assignment" "container_app_cert_user" {
  count                = var.project_suffix == "container" ? 1 : 0
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = var.container_principal_id
}

resource "azurerm_role_assignment" "container_app_crypto_user" {
  count                = var.project_suffix == "container" ? 1 : 0
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = var.container_principal_id
}