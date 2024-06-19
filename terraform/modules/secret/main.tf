data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_key_vault_secret" "secret" {
  name         = "ExampleSecret"
  value        = "SuperSecretValue"
  key_vault_id = data.azurerm_key_vault.kv.id
}