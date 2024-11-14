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
  default = "rg_sb_eastus_221777_1_172914808451"
}

variable "apim_name" {
  description = "The prefix for the API Management instance name"
  type        = string
  default     = "mkdapim6k"
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

/*# Storage account name must be unique; consider adding a random suffix for uniqueness
variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
  default     = "mkdstorageaccount${random_string.unique_id.result}"
}*/

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

# Local variable for storage account name
locals {
  storage_account_name = "mkdstorageaccount${random_string.unique_id.result}"
}

# Create the Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  identity {
    type = "SystemAssigned"
  }
}

# Create a Blob container
# Create a Blob container for the storage account
resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage.name  # Reference the single instance
  container_access_type = "private"
}

/*data "azurerm_api_management" "apim" {
  name                = var.apim_name # Ensure this matches the existing resource
  resource_group_name = azurerm_resource_group.rg.name
}

data "azurerm_api_management_api" "api" {
  name                = "myblobapi" # Ensure this matches the existing API
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  revision            = "1" # Specify the revision of the existing API
}

# Add operations for GET, POST, PUT, DELETE
resource "azurerm_api_management_api_operation" "get_blob" {
  operation_id        = "getBlob"
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  display_name        = "Get Blob"
  method              = "GET"
  url_template        = "/{blobName}"
  description         = "Retrieve a blob."

  template_parameter {
    name     = "blobName"
    type     = "string"
    required = true
  }

  response {
    status_code = 200
    description = "Blob content retrieved successfully."
    representation {
      content_type = "application/json"
    }
  }
}

resource "azurerm_api_management_api_operation" "create_blob" {
  operation_id        = "createBlob"
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  display_name        = "Create Blob"
  method              = "POST"
  url_template        = "/{blobName}"
  description         = "Create a new blob."

  request {
    representation {
      content_type = "application/json"
    }
  }

  response {
    status_code = 201
    description = "Blob created successfully."
    representation {
      content_type = "application/json"
    }
  }
}

resource "azurerm_api_management_api_operation" "update_blob" {
  operation_id        = "updateBlob"
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  display_name        = "Update Blob"
  method              = "PUT"
  url_template        = "/{blobName}"
  description         = "Update an existing blob."

  request {
    representation {
      content_type = "application/json"
    }
  }

  response {
    status_code = 200
    description = "Blob updated successfully."
    representation {
      content_type = "application/json"
    }
  }
}

resource "azurerm_api_management_api_operation" "delete_blob" {
  operation_id        = "deleteBlob"
  api_name            = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  display_name        = "Delete Blob"
  method              = "DELETE"
  url_template        = "/{blobName}"
  description         = "Delete a blob."

  response {
    status_code = 204
    description = "Blob deleted successfully."
  }
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
}*/

data "azurerm_api_management" "apim" {  
  name           = var.apim_name  
  resource_group_name = azurerm_resource_group.rg.name  
}  
  
data "azurerm_api_management_api" "api" {  
  name           = "myblobapi"  
  api_management_name = azurerm_api_management.apim.name  
  resource_group_name = azurerm_resource_group.rg.name  
  revision        = "1"  
}  
  
# Add operations for GET, POST, PUT, DELETE  
resource "azurerm_api_management_api_operation" "delete_blob" {
  operation_id        = "user-delete"
  api_name        = azurerm_api_management_api.api.name
  api_management_name = azurerm_api_management.apim.name  
  resource_group_name = azurerm_resource_group.rg.name
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
  resource_group_name = azurerm_resource_group.rg.name
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
  resource_group_name = azurerm_resource_group.rg.name
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
  resource_group_name = azurerm_resource_group.rg.name
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