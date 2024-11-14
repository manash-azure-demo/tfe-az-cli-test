# Define the resource group variable
$RESOURCE_GROUP = "rg_sb_eastus_221777_1_172749191357"

# Retrieve the AKS cluster IDs in parallel
$AKS_CLS1_ID = Start-Job -ScriptBlock {
    param($resourceGroup)
    az aks show --resource-group $resourceGroup --name mkd-aks-cls1-eus --query "identityProfile.kubeletidentity.objectId" -o tsv
} -ArgumentList $RESOURCE_GROUP

$AKS_CLS2_ID = Start-Job -ScriptBlock {
    param($resourceGroup)
    az aks show --resource-group $resourceGroup --name mkd-aks-cls2-eus --query "identityProfile.kubeletidentity.objectId" -o tsv
} -ArgumentList $RESOURCE_GROUP

# Wait for both jobs to complete and retrieve results
Wait-Job -Job $AKS_CLS1_ID, $AKS_CLS2_ID
$AKS_CLS1_ID = Receive-Job -Job $AKS_CLS1_ID
$AKS_CLS2_ID = Receive-Job -Job $AKS_CLS2_ID

# Retrieve the user principal ID from Microsoft Graph
$USER_PRINCIPAL_ID = az rest --method GET --url "https://graph.microsoft.com/v1.0/me" --query id -o tsv

# Output the retrieved values
Write-Output "AKS CLS1 ID: $AKS_CLS1_ID"
Write-Output "AKS CLS2 ID: $AKS_CLS2_ID"
Write-Output "User Principal ID: $USER_PRINCIPAL_ID"