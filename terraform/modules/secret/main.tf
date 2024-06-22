data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
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
  key_vault_id = data.azurerm_key_vault.kv.id
}

output "secrets" {
  value = azurerm_key_vault_secret.secret[*].value
}