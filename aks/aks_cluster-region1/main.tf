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

module "aks_eus_cluster1" {
  source = "./modules/aks_eus_cluster1"

  # Passing variables to the module
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  resource_group  = var.resource_group
  location        = var.location

  vnet_name1        = var.vnet_name1
  subnet1_name1     = var.subnet1_name1
  subnet2_name1     = var.subnet2_name1
  nsg1_name         = var.nsg1_name
  nsg2_name         = var.nsg2_name
  route_table_name1 = var.route_table_name1
  aks_eus1_name     = var.aks_eus1_name
  acr_name          = var.acr_name
  #key_vault_name    = var.key_vault_name
}

module "aks_eus_cluster2" {
  source = "./modules/aks_eus_cluster2"

  # Passing variables to the module
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  resource_group  = var.resource_group
  location        = var.location

  vnet_name2        = var.vnet_name2
  subnet1_name2     = var.subnet1_name2
  subnet2_name2     = var.subnet2_name2
  nsg3_name         = var.nsg3_name
  nsg4_name         = var.nsg4_name
  route_table_name2 = var.route_table_name2
  aks_eus2_name     = var.aks_eus2_name
  #acr_name          = var.acr_name

  # Reference the ACR name from the first module output
  acr_name          = module.aks_eus_cluster1.acr_name

  # Ensure module 2 depends on module 1 completion
  depends_on = [module.aks_eus_cluster1]
}