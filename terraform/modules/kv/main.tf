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

resource "azurerm_role_assignment" "base_app_secret_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.base_principal_id
}

resource "azurerm_role_assignment" "product_app_secret_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.product_principal_id
}

resource "azurerm_role_assignment" "product_app_cert_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = var.product_principal_id
}

resource "azurerm_role_assignment" "container_app_secret_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.container_principal_id
}

resource "azurerm_key_vault" "kv" {
  name                       = var.key_vault_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  sku_name                   = "standard"
  tenant_id                  = var.tenant_id
  enable_rbac_authorization  = true
  soft_delete_retention_days = 7
}

resource "terraform_data" "secret_name_list" {
  input = split(",", var.secret_name_list)
}

resource "terraform_data" "secret_value_list" {
  input = split(",", replace(var.secret_value_list, "\r", ""))
}

resource "azurerm_key_vault_secret" "secret" {
  count        = length(terraform_data.secret_name_list)
  name         = terraform_data.secret_name_list.output[count.index]
  value        = terraform_data.secret_value_list.output[count.index]
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [
    azurerm_role_assignment.backend_app_secret_officer
  ]
}

output "secrets" {
  value = azurerm_key_vault_secret.secret[*].value
}

output "length" {
  value = length(terraform_data.secret_name_list)
}