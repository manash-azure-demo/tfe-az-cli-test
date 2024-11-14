subscription_id   = "4f6a6eb9-27d0-4ed6-a31c-2bde135e2db6"
tenant_id         = "82676786-5bc7-43c6-b8f8-b3ee02b0b5f3"
resource_group    = "rg_sb_eastus_221777_1_173134314540" # NEED TO FILL
location          = "eastus"
user_principal_id = "adbc262a-2fee-46db-88c0-e7964a3541b8" # az rest --method GET --url "https://graph.microsoft.com/v1.0/me" --query id -o tsv

# FA Linux Variables
storage_name      = "mkdfappsa1"
secret_name       = "mkdSecretname-linux"
secret_value      = "mkd-secret-value-linux"

# FA Windows Variables

secret_name1       = "mkdSecretname-windows"
secret_value1      = "mkd-secret-value-windows"

