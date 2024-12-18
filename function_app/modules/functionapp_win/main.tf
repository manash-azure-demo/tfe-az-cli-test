# Provider Configuration
/*provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id  # Reference from variables
  resource_provider_registrations = "none"  # Prevent automatic resource provider registration
}*/

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
  default     = "82676786-5bc7-43c6-b8f8-b3ee02b0b5f3"
}

# Variables
variable "resource_group_name1" {
  type        = string
  description = "The name of the existing resource group."
  default     = "rg_sb_eastus_221777_1_173098772868"
}

variable "location" {
  type        = string
  description = "The Azure location where the resources will be created."
  default     = "eastus"
}

variable "subscription_id" {
  type        = string
  description = "The Azure location where the resources will be created."
  default     = "4f6a6eb9-27d0-4ed6-a31c-2bde135e2db6"
}

variable "storage_name" {
  type        = string
  description = "The Azure location where the resources will be created."
  default     = "mkdfunctionsa1"
}

variable "key_vault" {
  type        = string
  description = "The Azure location where the resources will be created."
  default     = "mykeyvaultq69" # CHANGE THE KV NAME HERE
}

variable "secret_name1" {
  type        = string
  description = "The name of the secret to be created in Key Vault."
  default     = "mkdSecretf2-w"
}

variable "secret_value1" {
  type        = string
  description = "The value of the secret to be stored in Key Vault."
  default     = "mkd-supersecretvalue123-w"
}

# Data source to fetch the existing Key Vault
data "azurerm_key_vault" "existing_kv" {
  name                = var.key_vault  # Replace with the actual Key Vault name
  resource_group_name = var.resource_group_name1
}

# Data source to fetch the existing Storage Account
data "azurerm_storage_account" "existing_sa" {
  name                 = var.storage_name
  resource_group_name  = var.resource_group_name1
}

# Create a Blob container in the existing storage account
resource "azurerm_storage_container" "function_app_container" {
  name                  = "fapp-container-w"
  storage_account_id  = data.azurerm_storage_account.existing_sa.id
  container_access_type = "private"  # Set the container to private
}

# Create App Service Plan for Windows-based Function App
resource "azurerm_service_plan" "function_plan" {
  name                = "func-app-plan-win"
  location            = var.location
  resource_group_name = var.resource_group_name1
  os_type             = "Windows"  # Set to Windows
  sku_name            = "Y1"       # Consumption pricing tier
}

# Create the Windows Function App (using azurerm_windows_function_app)
resource "azurerm_windows_function_app" "function_app" {
  name                       = "mkd-fapp-w-${random_string.unique_id.result}"
  location                   = var.location
  resource_group_name        = var.resource_group_name1
  service_plan_id            = azurerm_service_plan.function_plan.id
  storage_account_name       = data.azurerm_storage_account.existing_sa.name
  storage_account_access_key = data.azurerm_storage_account.existing_sa.primary_access_key

  site_config {
    always_on = false
    ftps_state = "Disabled"
  }

  app_settings = {
    FUNCTIONS_EXTENSION_VERSION = "~4"
    WEBSITE_RUN_FROM_PACKAGE    = "1"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Assign access policy for Function App to Key Vault
resource "azurerm_key_vault_access_policy" "kv_access_policy" {
  key_vault_id = data.azurerm_key_vault.existing_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_windows_function_app.function_app.identity[0].principal_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
}

# Create a secret in the existing Key Vault
resource "azurerm_key_vault_secret" "my_secret_w" {
  name         = var.secret_name1
  value        = var.secret_value1
  key_vault_id = data.azurerm_key_vault.existing_kv.id

  depends_on = [azurerm_key_vault_access_policy.kv_access_policy]
}

# Generate random string for uniqueness
resource "random_string" "unique_id" {
  length  = 3
  special = false
  upper   = false # Ensures only lowercase letters
}

# Data source to fetch the tenant ID
data "azurerm_client_config" "current" {}

# Outputs
output "function_app_default_hostname" {
  value = azurerm_windows_function_app.function_app.default_hostname
}

output "key_vault_id" {
  value = data.azurerm_key_vault.existing_kv.id
}

output "storage_account_name" {
  value = data.azurerm_storage_account.existing_sa.name
}

output "container_name" {
  value = azurerm_storage_container.function_app_container.name
}