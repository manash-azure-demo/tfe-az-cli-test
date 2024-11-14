# Provider Configuration
/*provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id  # Reference from variables
  resource_provider_registrations = "none"  # Prevent automatic resource provider registration
}*/

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
  default = "82676786-5bc7-43c6-b8f8-b3ee02b0b5f3"
}

# az rest --method GET --url "https://graph.microsoft.com/v1.0/me" --query id -o tsv
variable "user_principal_id" {
  type = string
  default = "3cc99a92-de8f-4575-b28d-b26b4b8c3fce"
}

# Variables
variable "resource_group_name" {
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

variable "secret_name" {
  type        = string
  description = "The name of the secret to be created in Key Vault."
  default     = "mkdlSecretf1-l"  # Update as needed
}

variable "secret_value" {
  type        = string
  description = "The value of the secret to be stored in Key Vault."
  default     = "mkdl-supersecretvalue123-l"  # Update as needed
}

# Create Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = "mykeyvault${random_string.unique_id.result}"
  location                    = var.location
  resource_group_name          = var.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
}

# Create a storage account for the Function App
resource "azurerm_storage_account" "sa" {
  name                      = var.storage_name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
}

# Create a blob container within the storage account
resource "azurerm_storage_container" "function_app_container" {
  name                  = "fapp-container-l"  # You can change this name as needed
  storage_account_id  = azurerm_storage_account.sa.id
  container_access_type = "private"  # Set this to private for secure access
}

# Create App Service Plan for Linux-based Function App
resource "azurerm_service_plan" "function_plan" {
  name                = "func-app-plan-lux"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"  # Set to Linux for Linux-based Function App
  sku_name            = "Y1"       # Consumption pricing tier
}

# Create the Linux Function App (using azurerm_linux_function_app)
resource "azurerm_linux_function_app" "function_app" {
  name                       = "mkd-fapp-l-${random_string.unique_id.result}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.function_plan.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key

  site_config {
    always_on = false  # This setting can be true or false depending on the plan
    ftps_state = "Disabled"
  }

  app_settings = {
    FUNCTIONS_EXTENSION_VERSION = "~4"
    WEBSITE_RUN_FROM_PACKAGE    = "1"
    # Example of setting a reference to the container storage
    STORAGE_CONTAINER_NAME      = azurerm_storage_container.function_app_container.name  # Add this to reference the container
  }

  identity {
    type = "SystemAssigned"
  }
}

# Assign access policy for Function App to Key Vault
resource "azurerm_key_vault_access_policy" "kv_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_function_app.function_app.identity[0].principal_id  # Correct reference to identity

  secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
}

# Access Policy for the Lab User
resource "azurerm_key_vault_access_policy" "user_key_vault_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = var.tenant_id
  object_id    = var.user_principal_id

  secret_permissions = [
    "Get",   # Permission to read secrets
    "List",  # Permission to list secrets
    "Set",   # Permission to create/update secrets
    "Delete"
  ]
}

# Role Assignment for Lab User
resource "azurerm_role_assignment" "user_key_vault_secrets_officer" {
  principal_id        = var.user_principal_id
  role_definition_name = "Key Vault Secrets Officer"
  scope               = azurerm_key_vault.kv.id
}

resource "azurerm_role_assignment" "user_key_vault_crypto_officer" {
  principal_id        = var.user_principal_id
  role_definition_name = "Key Vault Crypto Officer"
  scope               = azurerm_key_vault.kv.id
}

resource "azurerm_role_assignment" "user_key_vault_contributor" {
  principal_id        = var.user_principal_id
  role_definition_name = "Key Vault Contributor"
  scope               = azurerm_key_vault.kv.id
}

resource "azurerm_role_assignment" "user_key_vault_secrets_user" {
  principal_id        = var.user_principal_id
  role_definition_name = "Key Vault Secrets User"
  scope               = azurerm_key_vault.kv.id
}

# Create a secret in Key Vault
resource "azurerm_key_vault_secret" "my_secret_l" {
  name         = var.secret_name
  value        = var.secret_value
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_key_vault_access_policy.kv_access_policy]  # Ensure access policy is applied before creating secret
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
  value = azurerm_linux_function_app.function_app.default_hostname
}

output "key_vault_id" {
  value = azurerm_key_vault.kv.id
}

output "key_vault_name" {
  description = "The name of the created Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "sa_name" {
  description = "The name of the created Key Vault"
  value       = azurerm_storage_account.sa.name
}

output "storage_account_id" {
  value = azurerm_storage_account.sa.id
}

output "key_vault_uri" {
  description = "The URI to access the Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}