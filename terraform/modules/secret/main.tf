data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_key_vault_secret" "secret" {
  name         = var.secret_name_list
  value        = var.secret_value_list
  key_vault_id = data.azurerm_key_vault.kv.id
}