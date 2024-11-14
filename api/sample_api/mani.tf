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
  default = "rg_sb_eastus_221777_1_172684999469"
}

variable "apim_name" {
  description = "The name of the API Management instance"
  type        = string
  default     = "mkdapim1"
}

variable "api_name" {
  description = "The internal name of the new API."
  type        = string
  default     = "mkdapisample1"
}

variable "api_display_name" {
  description = "The display name for the new API."
  type        = string
  default     = "mkdapi1"
}

variable "api_url_suffix" {
  description = "The URL suffix for the new API."
  type        = string
  default     = "apis"
}

variable "backend_service_url" {
  description = "The URL of the backend service to connect to the API."
  type        = string
  default     = "https://jsonplaceholder.typicode.com"
}

variable "product_id" {
  description = "The product to which the API will be added (e.g., starter, unlimited)."
  type        = string
  default     = "starter"
}

# Use an existing Resource Group
data "azurerm_resource_group" "existing" {
  name = var.resource_group_name
}

# Use an existing API Management Service
data "azurerm_api_management" "existing" {
  name                = var.apim_name
  resource_group_name = data.azurerm_resource_group.existing.name
}

# Creating a new API within the API Management Service
resource "azurerm_api_management_api" "sample_api" {
  name                = var.api_name
  resource_group_name = data.azurerm_resource_group.existing.name
  api_management_name = data.azurerm_api_management.existing.name
  revision            = "1"
  display_name        = var.api_display_name
  path                = var.api_url_suffix
  protocols           = ["https"]
  service_url         = var.backend_service_url   # Provide the backend URL for the API
  subscription_required = true
}

# Add Operation to the API (GET /posts)
resource "azurerm_api_management_api_operation" "get_posts" {
  operation_id        = "getPosts"
  api_name            = azurerm_api_management_api.sample_api.name
  api_management_name = data.azurerm_api_management.existing.name
  resource_group_name = data.azurerm_resource_group.existing.name
  display_name        = "Get Posts"
  method              = "GET"
  url_template        = "/posts"
  response {
    status_code = 200
    description = "A successful response"
    representation {
      content_type = "application/json"
    }
  }
}

# Add the API to a Product (e.g., Starter or Unlimited)
resource "azurerm_api_management_product_api" "product_api" {
  api_name            = azurerm_api_management_api.sample_api.name
  product_id          = var.product_id # e.g., "starter"
  api_management_name = data.azurerm_api_management.existing.name
  resource_group_name = data.azurerm_resource_group.existing.name
}

output "api_url" {
  description = "The full URL for the created API."
  value       = "https://${data.azurerm_api_management.existing.gateway_url}/${azurerm_api_management_api.sample_api.path}"
}

output "api_name" {
  description = "The name of the created API."
  value       = azurerm_api_management_api.sample_api.name
}

output "operation_name" {
  description = "The operation created in the API."
  value       = azurerm_api_management_api_operation.get_posts.operation_id
}

