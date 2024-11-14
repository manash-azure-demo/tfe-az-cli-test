param (
    [string]$keyVaultName = "mykeyvaultcbenf5",
    [string]$secretName = "mkdlSecretf1",
    [string]$tenantId = "82676786-5bc7-43c6-b8f8-b3ee02b0b5f3",
    [string]$clientId = "f971d84c-432e-436e-92f8-e435c1b161c5",
    [string]$clientSecret = "qEc8Q~r9BqI9xKGz04pykW8atsfIlD5ejvKB3dt2"
)

function Test-KeyVaultConnection {
    param (
        [string]$keyVaultName,
        [string]$secretName,
        [string]$tenantId,
        [string]$clientId,
        [string]$clientSecret
    )
    
    try {
        # Authenticate using Service Principal
        Write-Output "Authenticating with Service Principal..."
        $SecureClientSecret = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
        $Cred = New-Object System.Management.Automation.PSCredential ($clientId, $SecureClientSecret)
        Connect-AzAccount -ServicePrincipal -TenantId $tenantId -Credential $Cred
        
        # Retrieve the secret from Key Vault
        Write-Output "Retrieving secret from Key Vault..."
        $secret = Get-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName
        
        # If successful, output the secret value
        Write-Output "Secret retrieved successfully: $($secret.SecretValueText)"
        return $secret.SecretValueText
    } catch {
        Write-Error "Error accessing Key Vault: $_"
        return $null
    }
}

# Test the connection by calling the function
$secretValue = Test-KeyVaultConnection -keyVaultName $keyVaultName -secretName $secretName `
                                       -tenantId $tenantId -clientId $clientId -clientSecret $clientSecret

if ($secretValue) {
    Write-Output "Function App has successfully connected to Key Vault!"
} else {
    Write-Output "Failed to connect to Key Vault."
}