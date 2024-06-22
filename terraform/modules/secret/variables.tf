variable "key_vault_name" {
  description = "The name of the key vault."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the key vault is located."
  type        = string
}

variable "secret_name_list" {
  description = "The name of the secret."
  type        = string
}

variable "secret_value_list" {
  description = "The value of the secret."
  type        = string
}