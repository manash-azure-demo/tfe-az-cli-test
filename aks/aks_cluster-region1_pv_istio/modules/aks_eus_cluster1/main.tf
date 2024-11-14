variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "resource_group" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Location for the resources"
}

# Variables for Cluster 1
variable "vnet_name1" {
  type        = string
  description = "Virtual Network name for Cluster 1"
}

variable "subnet1_name1" {
  type        = string
  description = "Subnet 1 name for Cluster 1"
}

variable "subnet2_name1" {
  type        = string
  description = "Subnet 2 name for Cluster 1"
}

variable "nsg1_name" {
  type        = string
  description = "NSG 1 name for Cluster 1"
}

variable "nsg2_name" {
  type        = string
  description = "NSG 2 name for Cluster 1"
}

variable "route_table_name1" {
  type        = string
  description = "Route table name for Cluster 1"
}

variable "aks_eus1_name" {
  type        = string
  description = "AKS Cluster 1 name"
}

variable "acr_name" {
  type        = string
  description = "Azure Container Registry name"
}

/*variable "key_vault_name" {
  type        = string
  description = "Azure key vault name"
}*/

######## Create Virtual Network for Cluster 1
resource "azurerm_virtual_network" "vnet1" {
  name                = var.vnet_name1
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group
}

# Create Subnets for Cluster 1
resource "azurerm_subnet" "subnet1_1" {
  name                 = var.subnet1_name1
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet2_1" {
  name                 = var.subnet2_name1
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create Network Security Groups for Cluster 1
resource "azurerm_network_security_group" "nsg1" {
  name                = var.nsg1_name
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_network_security_group" "nsg2" {
  name                = var.nsg2_name
  location            = var.location
  resource_group_name = var.resource_group
}

# Associate NSGs with Subnets for Cluster 1
resource "azurerm_subnet_network_security_group_association" "nsg_association1" {
  subnet_id                 = azurerm_subnet.subnet1_1.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_association2" {
  subnet_id                 = azurerm_subnet.subnet2_1.id
  network_security_group_id = azurerm_network_security_group.nsg2.id
}

# Create Route Table for Cluster 1
resource "azurerm_route_table" "route_table1" {
  name                = var.route_table_name1
  location            = var.location
  resource_group_name = var.resource_group
}

# Create Routes for Route Table 1
resource "azurerm_route" "route_to_subnet2_1" {
  name                   = "route-to-subnet2"
  route_table_name       = azurerm_route_table.route_table1.name
  resource_group_name    = var.resource_group
  address_prefix         = "10.0.2.0/24"
  next_hop_type          = "VnetLocal"
}

resource "azurerm_route" "route_to_subnet1_1" {
  name                   = "route-to-subnet1"
  route_table_name       = azurerm_route_table.route_table1.name
  resource_group_name    = var.resource_group
  address_prefix         = "10.0.1.0/24"
  next_hop_type          = "VnetLocal"
}

# Associate Route Table with Subnets for Cluster 1
resource "azurerm_subnet_route_table_association" "route_association1" {
  subnet_id      = azurerm_subnet.subnet1_1.id
  route_table_id = azurerm_route_table.route_table1.id
}

resource "azurerm_subnet_route_table_association" "route_association2" {
  subnet_id      = azurerm_subnet.subnet2_1.id
  route_table_id = azurerm_route_table.route_table1.id
}

################################
# Allow HTTP traffic (port 80) in NSG1
resource "azurerm_network_security_rule" "allow_http_nsg1" {
  name                        = "Allow-HTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.nsg1.name
}

# Allow HTTPS traffic (port 443) in NSG1
resource "azurerm_network_security_rule" "allow_https_nsg1" {
  name                        = "Allow-HTTPS"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.nsg1.name
}

# Allow HTTP traffic (port 80) in NSG2
resource "azurerm_network_security_rule" "allow_http_nsg2" {
  name                        = "Allow-HTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.nsg2.name
}

# Allow HTTPS traffic (port 443) in NSG2
resource "azurerm_network_security_rule" "allow_https_nsg2" {
  name                        = "Allow-HTTPS"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.nsg2.name
}
################################

# Create Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Create AKS Cluster for Cluster 1
resource "azurerm_kubernetes_cluster" "aks_eus1" {
  name                = var.aks_eus1_name
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = "mkdaksdnseus"
  kubernetes_version  = "1.30.1"

  default_node_pool {
    name       = "default"
    vm_size    = "Standard_D2as_v4"
    node_count = 2
    vnet_subnet_id = azurerm_subnet.subnet1_1.id
    
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }
}

# Add additional node pool for Cluster 1
resource "azurerm_kubernetes_cluster_node_pool" "application1" {
  name                = "application"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_eus1.id
  vm_size            = "Standard_D2as_v4"
  node_count         = 3
  vnet_subnet_id     = azurerm_subnet.subnet2_1.id
}

/*# Create Key Vault
resource "azurerm_key_vault" "key_vault" {
  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group
  sku_name            = "standard"
  tenant_id           = var.tenant_id
}*/

# Create Key Vault
resource "azurerm_key_vault" "key_vault" {
  name                        = "mykeyvault${random_string.unique_id.result}"
  location                    = var.location
  resource_group_name          = var.resource_group
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
}

# Attach ACR to AKS for Cluster 1
resource "azurerm_role_assignment" "acr_role_assignment1" {
  principal_id   = azurerm_kubernetes_cluster.aks_eus1.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope           = azurerm_container_registry.acr.id
}

# Generate random string for uniqueness
resource "random_string" "unique_id" {
  length  = 2
  special = false
}

# Data source to fetch the tenant ID
data "azurerm_client_config" "current" {}

# Outputs
output "cluster1_name" {
  value = azurerm_kubernetes_cluster.aks_eus1.name
}

/*output "cluster1_url" {
  value = azurerm_kubernetes_cluster.aks_eus1.kube_admin_config[0].host
}

output "cluster1_client_certificate" {
  value = azurerm_kubernetes_cluster.aks_eus1.kube_admin_config[0].client_certificate
}*/

output "cluster1_kubeconfig" {
  value = azurerm_kubernetes_cluster.aks_eus1.kube_config_raw
  sensitive = true
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "vnet1_id" {
  value = azurerm_virtual_network.vnet1.id
}

output "subnet1_1_id" {
  value = azurerm_subnet.subnet1_1.id
}

output "subnet2_1_id" {
  value = azurerm_subnet.subnet2_1.id
}

output "nsg1_id" {
  value = azurerm_network_security_group.nsg1.id
}

output "nsg2_id" {
  value = azurerm_network_security_group.nsg2.id
}

# Outputs
output "key_vault_name" {
  description = "The name of the created Key Vault"
  value       = azurerm_key_vault.key_vault.name
}