terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id  # Reference from variables
#  skip_provider_registration      = true  # Prevent automatic provider registration
resource_provider_registrations = "none"  # Prevent automatic resource provider registration
}

module "function_app_linux" {
  source = "./modules/functionapp_lux"

  # Passing variables to the module
  subscription_id   = var.subscription_id
  tenant_id         = var.tenant_id
  resource_group_name    = var.resource_group
  location          = var.location
  user_principal_id = var.user_principal_id
  storage_name      = var.storage_name
  secret_name       = var.secret_name
  secret_value      = var.secret_value
}

module "function_app_windows" {
  source = "./modules/functionapp_win"

  # Passing variables to the module
  subscription_id         = var.subscription_id
  tenant_id               = var.tenant_id
  resource_group_name1    = var.resource_group
  location                = var.location
  storage_name            = module.function_app_linux.sa_name
  key_vault               = module.function_app_linux.key_vault_name
  secret_name1            = var.secret_name1
  secret_value1           = var.secret_value1
  
  # Ensure module 2 depends on module 1 completion
  depends_on = [module.function_app_linux]
}