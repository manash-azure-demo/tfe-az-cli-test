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

variable "tenant_id" {
  default = "82676786-5bc7-43c6-b8f8-b3ee02b0b5f3"
}

# Resource Group Variable
variable "resource_group" {
  default = "rg_sb_eastus_221777_1_172956589232"
}

## az aks show --resource-group rg_sb_eastus_221777_1_172956589232 --name mkd-aks-cls1-eus --query "identityProfile.kubeletidentity.objectId"
variable "kubeletidentity_object_id_cls1" {
  default = "bb66c63d-9100-455d-8ec8-52d1ef71c87c"
}

variable "kubeletidentity_object_id_cls2" {
  default = "5b6566ba-6153-4cc4-990b-a869618883ce"
}

variable "key_vault_name" {
  type = string
  default = "mykeyvaultUe"
}

# az rest --method GET --url "https://graph.microsoft.com/v1.0/me" --query id -o tsv
variable "user_principal_id" {
  type = string
  default = "44f30de1-cd07-4e82-bbc4-573c64147171"
}

variable "location" {
  default = "eastus"
}

variable "aks1_name" {
  default = "mkd-aks-cls1-eus"
}

variable "aks2_name" {
  default = "mkd-aks-cls2-eus"
}

# Kubernetes Cluster data source for kubeconfig access
data "azurerm_kubernetes_cluster" "existing_aks1" {
  name                = var.aks1_name
  resource_group_name = var.resource_group
}

# Create Azure Storage Account for Persistent Volume
resource "azurerm_storage_account" "storage_account" {
  name                     = "st${random_string.unique_id.result}aks"
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create a Storage Container for the PVs
resource "azurerm_storage_container" "storage_container" {
  name                  = "pv-container"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

# Generate random string for unique storage account name
resource "random_string" "unique_id" {
  length  = 2
  special = false
  upper   = false
}

# Write kubeconfig to a local file
resource "local_file" "kubeconfig" {
  content  = base64decode(data.azurerm_kubernetes_cluster.existing_aks1.kube_admin_config_raw)
  filename = "${path.module}/kubeconfig_aks1.yaml"
}

# Kubernetes Manifest for Persistent Volume
resource "local_file" "pv_manifest" {
  content = <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: azurefile-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  azureFile:
    secretName: azure-secret
    shareName: ${azurerm_storage_container.storage_container.name}
    readOnly: false
EOF
  filename = "${path.module}/pv.yaml"
}

# Kubernetes Manifest for Persistent Volume Claim
resource "local_file" "pvc_manifest" {
  content = <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azurefile-pvc
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
EOF
  filename = "${path.module}/pvc.yaml"
}

# Apply PV and PVC using kubectl (ensure kubectl is configured)
resource "null_resource" "apply_k8s_resources" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.pv_manifest.filename} && kubectl apply -f ${local_file.pvc_manifest.filename}"
    environment = {
      KUBECONFIG = local_file.kubeconfig.filename
    }
  }

  depends_on = [
    local_file.pv_manifest,
    local_file.pvc_manifest,
    local_file.kubeconfig,
    data.azurerm_kubernetes_cluster.existing_aks1
  ]
}