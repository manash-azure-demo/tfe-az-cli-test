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

# Resource Group Variable
variable "resource_group" {
  default = "rg_sb_eastus_221777_1_172956589232"
}

## az aks show --resource-group rg_sb_eastus_221777_1_172956589232 --name mkd-aks-cls1-eus --query "identityProfile.kubeletidentity.objectId"
variable "kubeletidentity_object_id_cls1" {
  default = "bb66c63d-9100-455d-8ec8-52d1ef71c87c"
}

variable "kubeletidentity_object_id_cls2" {
  default = "5b6566ba-6153-4cc4-990b-a869618883ce"
}

variable "key_vault_name" {
  type = string
  default = "mykeyvaultUe"
}

# az rest --method GET --url "https://graph.microsoft.com/v1.0/me" --query id -o tsv
variable "user_principal_id" {
  type = string
  default = "44f30de1-cd07-4e82-bbc4-573c64147171"
}

variable "location" {
  default = "eastus"
}

variable "aks1_name" {
  default = "mkd-aks-cls1-eus"
}

variable "aks2_name" {
  default = "mkd-aks-cls2-eus"
}

# Fetch existing AKS cluster
data "azurerm_kubernetes_cluster" "existing_aks1" {
  name                = var.aks1_name
  resource_group_name = var.resource_group
}

data "azurerm_kubernetes_cluster" "existing_aks2" {
  name                = var.aks2_name
  resource_group_name = var.resource_group
}

# Fetch existing Key Vault
data "azurerm_key_vault" "existing_key_vault" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group
}

# Create Key Vault access policies and role assignments

# AKS Cluster Managed Identity Access to Key Vault
resource "azurerm_key_vault_access_policy" "aks_key_vault_access_policy1" {
  key_vault_id = data.azurerm_key_vault.existing_key_vault.id
  tenant_id    = var.tenant_id
  object_id    = data.azurerm_kubernetes_cluster.existing_aks1.identity[0].principal_id

  secret_permissions = [
    "Get",   # Permission to read secrets
    "List",  # Permission to list secrets
    "Set",   # Permission to create/update secrets
  ]
}

resource "azurerm_key_vault_access_policy" "aks_key_vault_access_policy2" {
  key_vault_id = data.azurerm_key_vault.existing_key_vault.id
  tenant_id    = var.tenant_id
  object_id    = data.azurerm_kubernetes_cluster.existing_aks2.identity[0].principal_id

  secret_permissions = [
    "Get",   # Permission to read secrets
    "List",  # Permission to list secrets
    "Set",   # Permission to create/update secrets
  ]
}

# Access Policy for Kubelet Identity
resource "azurerm_key_vault_access_policy" "kubelet_key_vault_access_policy1" {
  key_vault_id = data.azurerm_key_vault.existing_key_vault.id
  tenant_id    = var.tenant_id
  object_id    = var.kubeletidentity_object_id_cls1
  secret_permissions = [
   "Get",   # Permission to read secrets
   "List",  # Permission to list secrets
   "Set",   # Permission to create/update secrets
  ]
}

resource "azurerm_key_vault_access_policy" "kubelet_key_vault_access_policy2" {
  key_vault_id = data.azurerm_key_vault.existing_key_vault.id
  tenant_id    = var.tenant_id
  object_id    = var.kubeletidentity_object_id_cls2
  secret_permissions = [
   "Get",   # Permission to read secrets
   "List",  # Permission to list secrets
   "Set",   # Permission to create/update secrets
  ]
}

# Access Policy for the Lab User
resource "azurerm_key_vault_access_policy" "user_key_vault_access_policy" {
  key_vault_id = data.azurerm_key_vault.existing_key_vault.id
  tenant_id    = var.tenant_id
  object_id    = var.user_principal_id

  secret_permissions = [
    "Get",   # Permission to read secrets
    "List",  # Permission to list secrets
    "Set",   # Permission to create/update secrets
    "Delete"
  ]
}

# Role Assignment for AKS Cluster Managed Identity
resource "azurerm_role_assignment" "aks_key_vault_secrets_user1" {
  principal_id        = data.azurerm_kubernetes_cluster.existing_aks1.identity[0].principal_id
  role_definition_name = "Key Vault Secrets User"
  scope               = data.azurerm_key_vault.existing_key_vault.id
}

resource "azurerm_role_assignment" "aks_key_vault_secrets_user2" {
  principal_id        = data.azurerm_kubernetes_cluster.existing_aks2.identity[0].principal_id
  role_definition_name = "Key Vault Secrets User"
  scope               = data.azurerm_key_vault.existing_key_vault.id
}

# Role Assignment for Lab User
resource "azurerm_role_assignment" "user_key_vault_secrets_officer" {
  principal_id        = var.user_principal_id
  role_definition_name = "Key Vault Secrets Officer"
  scope               = data.azurerm_key_vault.existing_key_vault.id
}

resource "azurerm_role_assignment" "user_key_vault_crypto_officer" {
  principal_id        = var.user_principal_id
  role_definition_name = "Key Vault Crypto Officer"
  scope               = data.azurerm_key_vault.existing_key_vault.id
}

resource "azurerm_role_assignment" "user_key_vault_contributor" {
  principal_id        = var.user_principal_id
  role_definition_name = "Key Vault Contributor"
  scope               = data.azurerm_key_vault.existing_key_vault.id
}

resource "azurerm_role_assignment" "user_key_vault_secrets_user" {
  principal_id        = var.user_principal_id
  role_definition_name = "Key Vault Secrets User"
  scope               = data.azurerm_key_vault.existing_key_vault.id
}

# Create a Key Vault Secret
resource "azurerm_key_vault_secret" "my_secret1" {
  name         = "MySecreteuscls1"  # Secret Name
  value        = "Super-Secret-Value-eus-cls1"  # Secret Value
  key_vault_id = data.azurerm_key_vault.existing_key_vault.id  # Reference to the existing Key Vault

  depends_on = [azurerm_key_vault_access_policy.aks_key_vault_access_policy1]  # Ensure access policy is created first
}

resource "azurerm_key_vault_secret" "my_secret2" {
  name         = "MySecreteuscls2"  # Secret Name
  value        = "Super-Secret-Value-eus-cls2"  # Secret Value
  key_vault_id = data.azurerm_key_vault.existing_key_vault.id  # Reference to the existing Key Vault

  depends_on = [azurerm_key_vault_access_policy.aks_key_vault_access_policy2]  # Ensure access policy is created first
}

# Outputs
output "key_vault_uri" {
  value = data.azurerm_key_vault.existing_key_vault.vault_uri
}

output "key_vault_secret_name" {
  value = azurerm_key_vault_secret.my_secret1.name
}

output "key_vault_secret_id" {
  value = azurerm_key_vault_secret.my_secret1.id
}

output "key_vault_secret_name1" {
  value = azurerm_key_vault_secret.my_secret2.name
}

output "key_vault_secret_id1" {
  value = azurerm_key_vault_secret.my_secret2.id
}