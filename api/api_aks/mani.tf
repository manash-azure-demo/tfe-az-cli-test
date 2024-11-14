# Provider Configuration
provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}

# Variables for resource names
variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
  default     = "4f6a6eb9-27d0-4ed6-a31c-2bde135e2db6"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group where resources are located"
  default     = "rg_sb_eastus_221777_1_172889125416"
}

variable "apim_name" {
  description = "The name of the API Management instance"
  type        = string
  default     = "mkdapim3"
}

variable "sku" {
  description = "The pricing tier of this API Management service"
  default     = "Developer"
  type        = string
  validation {
    condition     = contains(["Developer", "Standard", "Premium"], var.sku)
    error_message = "The sku must be one of the following: Developer, Standard, Premium."
  }
}

variable "sku_count" {
  description = "The instance size of this API Management service."
  default     = 1
  type        = number
  validation {
    condition     = contains([1, 2], var.sku_count)
    error_message = "The sku_count must be one of the following: 1, 2."
  }
}

variable "aks_name" {
  description = "The name of the existing AKS cluster"
  type        = string
  default     = "mkd-aks-cls1-eus"
}

variable "service_url" {
  description = "The URL of the service hosted in AKS to be exposed via APIM"
  type        = string
  default     = "http://51.8.245.100"
}

# Resource group data block to refer to the existing resource group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Data block for the existing AKS cluster
data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  resource_group_name = var.resource_group_name
}

# Create the API Management service
resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  publisher_name      = "mkdas"
  publisher_email     = "mkdaws0@gmail.com"
  sku_name            = "${var.sku}_${var.sku_count}"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "production"
  }
}

# Create an API within the APIM instance to expose the service in AKS
resource "azurerm_api_management_api" "apim_api" {
  name                = "aks-api"
  resource_group_name = data.azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "AKS API"
  path                = "aks-service"
  protocols           = ["https"]
  service_url         = var.service_url
}

# Output the API Management details
output "apim_id" {
  value = azurerm_api_management.apim.id
}

output "apim_hostname" {
  value = azurerm_api_management.apim.gateway_url
}

output "aks_api_url" {
  value = "${azurerm_api_management.apim.gateway_url}/aks-service"
}