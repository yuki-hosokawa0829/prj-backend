variable "location" {
  description = "The Azure Region in which all resources will be created."
  type        = string
}

variable "tenant_id" {
  description = "The Azure AD tenant ID."
  type        = string
}

variable "environment" {
  description = "The environment to deploy to."
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

variable "container_principal_id" {
  description = "The object ID of the service principal that will access the key vault."
  type        = string
}

variable "backend_resource_group_name" {
  description = "The name of the resource group in which the backend resources are located."
  type        = string
}

variable "backend_storage_account_name" {
  description = "The name of the storage account in which the backend resources are located."
  type        = string
}

variable "backend_container_name" {
  description = "The name of the container in which the backend resources are located."
  type        = string
}

variable "backend_key" {
  description = "The key to access the backend resources."
  type        = string
}