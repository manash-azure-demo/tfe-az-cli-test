# Variables Definition

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "resource_group" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "user_principal_id" {
  type = string
}

# Cluster 1 Variables
variable "storage_name" {
  type        = string
  description = "The Azure location where the resources will be created."
}

variable "secret_name" {
  type        = string
  description = "The name of the secret to be created in Key Vault."
}

variable "secret_value" {
  type        = string
  description = "The value of the secret to be stored in Key Vault."
}

/*# Cluster 2 Variables
variable "storage_name1" {
  type        = string
  description = "The Azure location where the resources will be created."
}

variable "key_vault" {
  type        = string
  description = "The Azure location where the resources will be created."
}*/

variable "secret_name1" {
  type        = string
  description = "The name of the secret to be created in Key Vault."
}

variable "secret_value1" {
  type        = string
  description = "The value of the secret to be stored in Key Vault."
}