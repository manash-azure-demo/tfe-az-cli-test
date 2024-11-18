# Variables Definition

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
  description = "Azure region"
}

# Cluster 1 Variables
variable "vnet_name1" {
  type        = string
  description = "Virtual network name for cluster 1"
}

variable "subnet1_name1" {
  type        = string
  description = "Subnet 1 name for cluster 1"
}

variable "subnet2_name1" {
  type        = string
  description = "Subnet 2 name for cluster 1"
}

variable "nsg1_name" {
  type        = string
  description = "Network Security Group name for cluster 1 - NSG1"
}

variable "nsg2_name" {
  type        = string
  description = "Network Security Group name for cluster 1 - NSG2"
}

variable "route_table_name1" {
  type        = string
  description = "Route table name for cluster 1"
}

variable "aks_eus1_name" {
  type        = string
  description = "AKS cluster name for cluster 1"
}

variable "acr_name" {
  type        = string
  description = "Azure Container Registry name"
}

# Cluster 2 Variables
variable "vnet_name2" {
  type        = string
  description = "Virtual network name for cluster 2"
}

variable "subnet1_name2" {
  type        = string
  description = "Subnet 1 name for cluster 2"
}

variable "subnet2_name2" {
  type        = string
  description = "Subnet 2 name for cluster 2"
}

variable "nsg3_name" {
  type        = string
  description = "Network Security Group name for cluster 2 - NSG3"
}

variable "nsg4_name" {
  type        = string
  description = "Network Security Group name for cluster 2 - NSG4"
}

variable "route_table_name2" {
  type        = string
  description = "Route table name for cluster 2"
}

variable "aks_eus2_name" {
  type        = string
  description = "AKS cluster name for cluster 2"
}

/*variable "key_vault_name" {
  type        = string
  description = "Route table name for cluster 2"
}*/

# Key_Vault

variable "aks1_name" {
  default = "mkd-aks-cls1-eus"
}

variable "aks2_name" {
  default = "mkd-aks-cls2-eus"
}