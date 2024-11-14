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
  default = "rg_sb_eastus_221777_1_172915617545"
}

variable "apim_name_prefix" {
  description = "The prefix for the API Management instance name"
  type        = string
  default     = "mkdapim"
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

variable "container_name" {
  description = "The name of the Blob storage container"
  type        = string
  default     = "myblobcontainer"
}

# Generate a random string for uniqueness
resource "random_string" "unique_id" {
  length  = 2
  special = false
  upper   = false
}

# Resource group data block to refer to the existing resource group
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# Create the API Management service with a unique name
resource "azurerm_api_management" "apim" {
  name                = "${var.apim_name_prefix}${random_string.unique_id.result}"
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

# Create an API within the API Management instance
resource "azurerm_api_management_api" "api" {
  name                = "myblobapi"
  resource_group_name = data.azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "My Blob API"
  path                = "blob"
  protocols           = ["https"]
}

# Local variable for storage account name
locals {
  storage_account_name = "mkdstorageaccount${random_string.unique_id.result}"
}

# Create the Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = local.storage_account_name
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = data.azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  identity {
    type = "SystemAssigned"
  }
}

# Create a Blob container for the storage account
resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage.name  # Reference the single instance
  container_access_type = "container"
}

# Add operations for GET, POST, PUT, DELETE  
resource "azurerm_api_management_api_operation" "delete_blob" {
  operation_id        = "user-delete"
  api_name        = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.apim.name  
  resource_group_name = data.azurerm_resource_group.rg.name
  display_name        = "Delete User Operation"
  method              = "DELETE"
  url_template        = "/users/{id}/delete"
  description         = "This can only be done by the logged in user."

  template_parameter {
    name     = "id"
    type     = "number"
    required = true
  }

  response {
    status_code = 200
  }
}

resource "azurerm_api_management_api_operation" "create_blob" {
  operation_id        = "create-blob"
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.apim.name  
  resource_group_name = data.azurerm_resource_group.rg.name
  display_name        = "Create Blob Operation"
  method              = "PUT"
  url_template        = "/blobs/{id}"
  description         = "Create or upload a blob."

  template_parameter {
    name     = "id"
    type     = "string"
    required = true
  }

  request {
    description = "Upload blob content"
    representation {
      content_type = "application/json"
    }
  }

  response {
    status_code = 201
    description = "Blob created successfully"
  }
}

resource "azurerm_api_management_api_operation" "get_blob" {
  operation_id        = "get-blob"
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.apim.name  
  resource_group_name = data.azurerm_resource_group.rg.name
  display_name        = "Get Blob Operation"
  method              = "GET"
  url_template        = "/blobs/{id}"
  description         = "Retrieve a specific blob by its ID."

  template_parameter {
    name     = "id"
    type     = "string"
    required = true
  }

  response {
    status_code = 200
    description = "Blob retrieved successfully"
    representation {
      content_type = "application/json"
    }
  }
}

resource "azurerm_api_management_api_operation" "update_blob" {
  operation_id        = "update-blob"
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.apim.name  
  resource_group_name = data.azurerm_resource_group.rg.name
  display_name        = "Update Blob Operation"
  method              = "PATCH"
  url_template        = "/blobs/{id}"
  description         = "Update an existing blob."

  template_parameter {
    name     = "id"
    type     = "string"
    required = true
  }

  request {
    description = "Update blob content"
    representation {
      content_type = "application/json"
    }
  }

  response {
    status_code = 200
    description = "Blob updated successfully"
  }
}
  
output "http_methods" {
  value = [
    azurerm_api_management_api_operation.get_blob.method,
    azurerm_api_management_api_operation.create_blob.method,
    azurerm_api_management_api_operation.update_blob.method,
    azurerm_api_management_api_operation.delete_blob.method
  ]
  description = "List of HTTP methods configured for the API"
}

# Output the API Management details
output "apim_id" {
  value = azurerm_api_management.apim.id
}

output "apim_name" {
  value = azurerm_api_management.apim.name
}

output "apim_hostname" {
  value = azurerm_api_management.apim.gateway_url
}