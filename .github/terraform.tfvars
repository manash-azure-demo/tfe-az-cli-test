subscription_id = "4f6a6eb9-27d0-4ed6-a31c-2bde135e2db6"
tenant_id       = "82676786-5bc7-43c6-b8f8-b3ee02b0b5f3"
resource_group  = "rg_sb_eastus_221777_1_17319464153" # NEED TO FILL
location        = "eastus"
# Key Vault 
#key_vault_name  = "mykeyvault${random_string.unique_id.result}"

# Cluster 1 Variables
vnet_name1      = "mkdaksVNet1"
subnet1_name1   = "subnet1"
subnet2_name1   = "subnet2"
nsg1_name       = "mkdaksNSG1"
nsg2_name       = "mkdaksNSG2"
route_table_name1 = "mkdaksrtn1"
aks_eus1_name   = "mkd-aks-cls1-eus"
acr_name        = "mkdakseusacr"

# Cluster 2 Variables
vnet_name2      = "mkdaksVNeteus2"
subnet1_name2   = "subnet1"
subnet2_name2   = "subnet2"
nsg3_name       = "mkdaksNSG3"
nsg4_name       = "mkdaksNSG4"
route_table_name2 = "mkdaksrtn2"
aks_eus2_name   = "mkd-aks-cls2-eus"

