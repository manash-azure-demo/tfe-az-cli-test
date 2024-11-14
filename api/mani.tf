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

# Variables for the existing resource group and other parameters
variable "resource_group_name" {
  default = "rg_sb_eastus_221777_1_172688627320"
}

variable "apim_name" {
  description = "The name of the API Management instance"
  type        = string
  default     = "mkdapim2"
}

#variable "apim_sku" {
#  description = "SKU (pricing tier) for API Management"
#  type        = string
  #default     = Developer # Change to Basic, Standard, Premium as needed
#}

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

# Resource group data block to refer to the existing resource group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Create the API Management service
resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  publisher_name      = "mkdas"
  publisher_email     = "mkdaws0@gmail.com"
  sku_name            = "${var.sku}_${var.sku_count}"

  # Optional: Configure additional API Management settings
  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "production"
  }
}

# Output the API Management details
output "apim_id" {
  value = azurerm_api_management.apim.id
}

output "apim_hostname" {
  value = azurerm_api_management.apim.gateway_url
}