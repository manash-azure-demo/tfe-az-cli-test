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

variable "acr_name" {
  type        = string
  description = "Azure Container Registry name"
}

# Variables for Cluster 2
variable "vnet_name2" {
  type        = string
  description = "Virtual Network name for Cluster 2"
}

variable "subnet1_name2" {
  type        = string
  description = "Subnet 1 name for Cluster 2"
}

variable "subnet2_name2" {
  type        = string
  description = "Subnet 2 name for Cluster 2"
}

variable "nsg3_name" {
  type        = string
  description = "NSG 3 name for Cluster 2"
}

variable "nsg4_name" {
  type        = string
  description = "NSG 4 name for Cluster 2"
}

variable "route_table_name2" {
  type        = string
  description = "Route table name for Cluster 2"
}

variable "aks_eus2_name" {
  type        = string
  description = "AKS Cluster 2 name"
}

# Create Virtual Network for Cluster 2
resource "azurerm_virtual_network" "vnet2" {
  name                = var.vnet_name2
  address_space       = ["10.2.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group
}

# Create Subnets for Cluster 2
resource "azurerm_subnet" "subnet1_2" {
  name                 = var.subnet1_name2
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_subnet" "subnet2_2" {
  name                 = var.subnet2_name2
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.2.2.0/24"]
}

# Create Network Security Groups for Cluster 2
resource "azurerm_network_security_group" "nsg3" {
  name                = var.nsg3_name
  location            = var.location
  resource_group_name = var.resource_group
}

resource "azurerm_network_security_group" "nsg4" {
  name                = var.nsg4_name
  location            = var.location
  resource_group_name = var.resource_group
}

# Associate NSGs with Subnets for Cluster 2
resource "azurerm_subnet_network_security_group_association" "nsg_association3" {
  subnet_id                 = azurerm_subnet.subnet1_2.id
  network_security_group_id = azurerm_network_security_group.nsg3.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_association4" {
  subnet_id                 = azurerm_subnet.subnet2_2.id
  network_security_group_id = azurerm_network_security_group.nsg4.id
}

# Create Route Table for Cluster 2
resource "azurerm_route_table" "route_table2" {
  name                = var.route_table_name2
  location            = var.location
  resource_group_name = var.resource_group
}

# Create Routes for Route Table 2
resource "azurerm_route" "route_to_subnet2_2" {
  name                   = "route-to-subnet2"
  route_table_name       = azurerm_route_table.route_table2.name
  resource_group_name    = var.resource_group
  address_prefix         = "10.2.2.0/24"
  next_hop_type          = "VnetLocal"
}

resource "azurerm_route" "route_to_subnet1_2" {
  name                   = "route-to-subnet1"
  route_table_name       = azurerm_route_table.route_table2.name
  resource_group_name    = var.resource_group
  address_prefix         = "10.2.1.0/24"
  next_hop_type          = "VnetLocal"
}

# Associate Route Table with Subnets for Cluster 2
resource "azurerm_subnet_route_table_association" "route_association3" {
  subnet_id      = azurerm_subnet.subnet1_2.id
  route_table_id = azurerm_route_table.route_table2.id
}

resource "azurerm_subnet_route_table_association" "route_association4" {
  subnet_id      = azurerm_subnet.subnet2_2.id
  route_table_id = azurerm_route_table.route_table2.id
}

# Allow HTTP traffic (port 80) in NSG3
resource "azurerm_network_security_rule" "allow_http_nsg3" {
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
  network_security_group_name = azurerm_network_security_group.nsg3.name
}

# Allow HTTPS traffic (port 443) in NSG3
resource "azurerm_network_security_rule" "allow_https_nsg3" {
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
  network_security_group_name = azurerm_network_security_group.nsg3.name
}

# Allow HTTP traffic (port 80) in NSG4
resource "azurerm_network_security_rule" "allow_http_nsg4" {
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
  network_security_group_name = azurerm_network_security_group.nsg4.name
}

# Allow HTTPS traffic (port 443) in NSG4
resource "azurerm_network_security_rule" "allow_https_nsg4" {
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
  network_security_group_name = azurerm_network_security_group.nsg4.name
}

# Create AKS Cluster for Cluster 2
resource "azurerm_kubernetes_cluster" "aks_eus2" {
  name                = var.aks_eus2_name
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = "mkdaksdnseus2"
  kubernetes_version  = "1.30.1"

  default_node_pool {
    name       = "default"
    vm_size    = "Standard_D2as_v4"
    node_count = 2
    vnet_subnet_id = azurerm_subnet.subnet1_2.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.3.0.0/16"
    dns_service_ip = "10.3.0.10"
  }
}

# Add additional node pool for Cluster 2
resource "azurerm_kubernetes_cluster_node_pool" "application2" {
  name                = "application"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks_eus2.id
  vm_size            = "Standard_D2as_v4"
  node_count         = 3
  vnet_subnet_id     = azurerm_subnet.subnet2_2.id
}

# Data source for the existing Azure Container Registry (ACR)
data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group
}

# Attach ACR to AKS for Cluster 2
resource "azurerm_role_assignment" "acr_role_assignment2" {
  principal_id   = azurerm_kubernetes_cluster.aks_eus2.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope           = data.azurerm_container_registry.acr.id
}

# Outputs
output "cluster2_name" {
  value = azurerm_kubernetes_cluster.aks_eus2.name
}

output "cluster1_kubeconfig" {
  value = azurerm_kubernetes_cluster.aks_eus2.kube_config_raw
  sensitive = true
}

output "vnet2_id" {
  value = azurerm_virtual_network.vnet2.id
}

output "subnet1_2_id" {
  value = azurerm_subnet.subnet1_2.id
}

output "subnet2_2_id" {
  value = azurerm_subnet.subnet2_2.id
}

output "nsg3_id" {
  value = azurerm_network_security_group.nsg3.id
}

output "nsg4_id" {
  value = azurerm_network_security_group.nsg4.id
}