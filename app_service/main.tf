  # Provider Configuration
  provider "azurerm" {
    features {}
    subscription_id                 = var.subscription_id  # Reference from variables
    resource_provider_registrations = "none"  # Prevent automatic resource provider registration
  }

  variable "subscription_id" {
    type        = string
    description = "The Azure subscription ID where the resources will be created."
    default     = "4f6a6eb9-27d0-4ed6-a31c-2bde135e2db6"
  }

  variable "resource_group_name" {
    description = "The name of the existing resource group"
    type        = string
    default     = "rg_sb_eastus_221777_1_172933295280"
  }

  variable "location" {
    description = "The Azure region for the app service"
    type        = string
    default     = "eastus"
  }

  variable "app_service_plan_name" {
    description = "The name of the App Service Plan"
    type        = string
    default     = "mkd-appservice-plan"
  }

  variable "app_service_name" {
    description = "The name of the App Service"
    type        = string
    default     = "mkdwebapp1"
  }

  # Retrieve the existing resource group
  data "azurerm_resource_group" "existing" {
    name = var.resource_group_name
  }

  # Create App Service Plan in Standard S1
  resource "azurerm_service_plan" "app_service_plan" {
    name                = var.app_service_plan_name
    location            = data.azurerm_resource_group.existing.location
    resource_group_name = data.azurerm_resource_group.existing.name
    sku_name = "S1"
    os_type = "Windows"
    worker_count = "3"
  }

  # Define the App Service on Windows

  resource "azurerm_windows_web_app" "web_app" {
    name                = var.app_service_name
    location            = data.azurerm_resource_group.existing.location
    resource_group_name = data.azurerm_resource_group.existing.name
    service_plan_id     = azurerm_service_plan.app_service_plan.id
    
    site_config {}

    identity {
      type = "SystemAssigned"
    }
  }

  # Optional - Assign output to check URLs
  output "app_service_default_site" {
    value = azurerm_windows_web_app.web_app.default_hostname
  }

  output "app_service_url" {
    description = "The URL of the App Service"
    value       = azurerm_windows_web_app.web_app.default_hostname
  }