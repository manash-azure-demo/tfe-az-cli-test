# Provider Configuration
provider "azurerm" {
  features {}
  subscription_id   = var.subscription_id
  resource_provider_registrations = "none"
}

# Variables
variable "resource_group_name" {
  type        = string
  description = "The name of the existing resource group."
  default     = "rg_sb_eastus_221777_1_172777938112"  # CHANGE THIS TO YOUR RESOURCE GROUP
}

variable "location" {
  type        = string
  description = "The Azure location where the resources will be created."
  default     = "eastus"
}

variable "subscription_id" {
  type        = string
  description = "The Azure subscription ID."
  default     = "4f6a6eb9-27d0-4ed6-a31c-2bde135e2db6"
}

variable "storage_account_name" {
  description = "The name of the storage account."
  type        = string
  default     = "mkdstg1"  # Must be globally unique
}

variable "blob_container_name" {
  description = "The name of the Blob container."
  type        = string
  default     = "mkdstg1bc1"
}

variable "file_share_name" {
  description = "The name of the File share."
  type        = string
  default     = "mkdstg1fs1"
}

variable "table_name" {
  description = "The name of the Table."
  type        = string
  default     = "mkdstgt1"
}

variable "queue_name" {
  description = "The name of the Queue."
  type        = string
  default     = "mkdstg1q1"
}

# Resource Group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type  = "LRS"
  min_tls_version          = "TLS1_2"
}

# Blob Container
resource "azurerm_storage_container" "blob_container" {
  name                  = var.blob_container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# File Share
resource "azurerm_storage_share" "file_share" {
  name                 = var.file_share_name
  storage_account_name = azurerm_storage_account.storage.name
  quota                = 1024  # Quota in MB
}

# Table Storage
resource "azurerm_storage_table" "table" {
  name                 = var.table_name
  storage_account_name = azurerm_storage_account.storage.name
}

# Queue Storage
resource "azurerm_storage_queue" "queue" {
  name                 = var.queue_name
  storage_account_name = azurerm_storage_account.storage.name
}

# Outputs
output "storage_account_id" {
  description = "The ID of the storage account."
  value       = azurerm_storage_account.storage.id
}

output "blob_container_id" {
  description = "The ID of the Blob container."
  value       = azurerm_storage_container.blob_container.id
}

output "file_share_id" {
  description = "The ID of the File share."
  value       = azurerm_storage_share.file_share.id
}

output "table_id" {
  description = "The ID of the Table."
  value       = azurerm_storage_table.table.id
}

output "queue_id" {
  description = "The ID of the Queue."
  value       = azurerm_storage_queue.queue.id
}