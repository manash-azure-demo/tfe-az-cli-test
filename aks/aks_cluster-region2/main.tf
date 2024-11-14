# Provider Configuration
provider "azurerm" {
  features {}
  subscription_id                 = "4f6a6eb9-27d0-4ed6-a31c-2bde135e2db6"  # Your Azure subscription ID
  resource_provider_registrations = "none"  # Prevent automatic resource provider registration
}

################################### Variable change Starts ###################################

##### CHANGE THE RESOURCE GROUP HERE
variable "acr_resource_group" {
  default = "rg_sb_eastus_221777_1_172665478555"
}

variable "resource_group" {
  default = "rg_sb_westeurope_221777_2_17268023858"
}

################################# Variable change End ######################################

variable "location" {
  default = "westeurope"
}

variable "vnet_name" {
  default = "mkdaksVNet"
}

variable "subnet1_name" {
  default = "subnet1"
}

variable "subnet2_name" {
  default = "subnet2"
}

variable "nsg1_name" {
  default = "mkdaksNSG1"
}

variable "nsg2_name" {
  default = "mkdaksNSG2"
}

variable "route_table_name" {
  default = "mkdaksrtn1"
}

variable "aks_name" {
  default = "mkd-aks-cls1-weu"
}

variable "acr_name" {
  default = "mkdaksacreus"
}

# Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group
}

# Create Subnets
resource "azurerm_subnet" "subnet1" {
  name                 = var.subnet1_name
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = var.subnet2_name
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create Network Security Groups
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

# Associate NSGs with Subnets
resource "azurerm_subnet_network_security_group_association" "nsg_association1" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_association2" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.nsg2.id
}

# Create Route Table
resource "azurerm_route_table" "route_table" {
  name                = var.route_table_name
  location            = var.location
  resource_group_name = var.resource_group
}

# Create Routes
resource "azurerm_route" "route_to_subnet2" {
  name                   = "route-to-subnet2"
  route_table_name       = azurerm_route_table.route_table.name
  resource_group_name    = var.resource_group
  address_prefix         = "10.0.2.0/24"
  next_hop_type          = "VnetLocal"
}

resource "azurerm_route" "route_to_subnet1" {
  name                   = "route-to-subnet1"
  route_table_name       = azurerm_route_table.route_table.name
  resource_group_name    = var.resource_group
  address_prefix         = "10.0.1.0/24"
  next_hop_type          = "VnetLocal"
}

# Associate Route Table with Subnets
resource "azurerm_subnet_route_table_association" "route_association1" {
  subnet_id      = azurerm_subnet.subnet1.id
  route_table_id = azurerm_route_table.route_table.id
}

resource "azurerm_subnet_route_table_association" "route_association2" {
  subnet_id      = azurerm_subnet.subnet2.id
  route_table_id = azurerm_route_table.route_table.id
}

# Create AKS Cluster
resource "azurerm_kubernetes_cluster" "aks_weu" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = "mkdaks"
  kubernetes_version  = "1.30.1"

  default_node_pool {
    name       = "default"
    vm_size    = "Standard_D2as_v4"
    node_count = 2
    vnet_subnet_id = azurerm_subnet.subnet1.id
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

# Add additional node pool
resource "azurerm_kubernetes_cluster_node_pool" "application" {
  name                = "application"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_weu.id
  vm_size            = "Standard_D2as_v4"
  node_count         = 2
  vnet_subnet_id     = azurerm_subnet.subnet2.id
}

######### Output the AKS Cluster name########

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_weu.name
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet1_id" {
  value = azurerm_subnet.subnet1.id
}

output "subnet2_id" {
  value = azurerm_subnet.subnet2.id
}