# Provider Configuration
provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id  # Reference from variables
  resource_provider_registrations = "none"  # Prevent automatic resource provider registration
}

# Variables for resource names
variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
  default     = "4f6a6eb9-27d0-4ed6-a31c-2bde135e2db6"  # Your subscription ID
}

variable "tenant_id" {
  default = "82676786-5bc7-43c6-b8f8-b3ee02b0b5f3"
}

# CHANGE THE RESOURCE GROUP HERE
variable "resource_group" {
  default = "rg_sb_westeurope_221777_2_17266547868"
}

variable "kv_resource_group" {
  default = "rg_sb_eastus_221777_1_172665478555"
}

# CHANGE 'objectID' FOR POD LEVEL ACCESS
variable "kubeletidentity_object_id" {
  default = "960a9022-f49d-47df-b4bf-b5fa29226430"
}

# CHANGE THE Key Vault Name HERE
variable "key_vault_name" {
  type    = string
  default = "mkdakskvL"
}

variable "user_principal_id" {
  type    = string
  default = "20c02fad-7423-41d3-97c4-b4258f2f2e75"
}

variable "location" {
  default = "westeurope"
}

variable "aks_name" {
  default = "mkd-aks-cls1-weu"
}

# Fetch current Azure client configuration (tenant_id and object_id)
data "azurerm_client_config" "current" {}

# Fetch existing AKS cluster
data "azurerm_kubernetes_cluster" "existing_aks" {
  name                = var.aks_name
  resource_group_name = var.resource_group
}

# Fetch existing Key Vault
data "azurerm_key_vault" "existing_key_vault" {
  name                = var.key_vault_name
  resource_group_name = var.kv_resource_group
}

# Create Key Vault access policies and role assignments

# AKS Cluster Managed Identity Access to Key Vault
resource "azurerm_key_vault_access_policy" "aks_key_vault_access_policy_weu" {
  key_vault_id = data.azurerm_key_vault.existing_key_vault.id
  tenant_id    = var.tenant_id
  object_id    = data.azurerm_kubernetes_cluster.existing_aks.identity[0].principal_id

  secret_permissions = [
    "Get",   # Permission to read secrets
    "List",  # Permission to list secrets
    "Set",   # Permission to create/update secrets
  ]
}

# Access Policy for Kubelet Identity
resource "azurerm_key_vault_access_policy" "kubelet_key_vault_access_policy_weu" {
  key_vault_id = data.azurerm_key_vault.existing_key_vault.id
  tenant_id    = var.tenant_id
  object_id    = var.kubeletidentity_object_id

  secret_permissions = [
    "Get",   # Permission to read secrets
    "List",  # Permission to list secrets
    "Set",   # Permission to create/update secrets
  ]
}

# Role Assignment for AKS Cluster Managed Identity
resource "azurerm_role_assignment" "aks_key_vault_secrets_user" {
  principal_id        = data.azurerm_kubernetes_cluster.existing_aks.identity[0].principal_id
  role_definition_name = "Key Vault Secrets User"
  scope               = data.azurerm_key_vault.existing_key_vault.id
}

# Create a Key Vault Secret
resource "azurerm_key_vault_secret" "my_secret_weu" {
  name         = "MySecretweu"  # Secret Name
  value        = "SuperSecretValueweu"  # Secret Value
  key_vault_id = data.azurerm_key_vault.existing_key_vault.id  # Reference to the existing Key Vault
}

# Outputs

output "key_vault_uri" {
  value = data.azurerm_key_vault.existing_key_vault.vault_uri
}

output "key_vault_secret_name" {
  value = azurerm_key_vault_secret.my_secret_weu.name
}

output "key_vault_secret_id" {
  value = azurerm_key_vault_secret.my_secret_weu.id
}