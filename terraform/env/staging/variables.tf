variable "location" {
  description = "The Azure Region in which all resources will be created."
  type        = string
}

variable "tenant_id" {
  description = "The Azure AD tenant ID."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the key vault is located."
  type        = string
}

variable "backend_principal_id" {
  description = "The object ID of the service principal that will access the key vault."
  type        = string
}

variable "base_principal_id" {
  description = "The object ID of the service principal that will access the key vault."
  type        = string
}

variable "product_principal_id" {
  description = "The object ID of the service principal that will access the key vault."
  type        = string
}

variable "container_principal_id" {
  description = "The object ID of the service principal that will access the key vault."
  type        = string
}