### Import Variables
Invoke-Expression (Get-Content ".\VariablesDev.ps1" -Raw)

### Functions
# Set Key Vault Secrets
function SetKeyVaultSecret {
  param (
    [string]$FilePath,
    [string[]]$CsvFileNameList
  )

  foreach ($CsvFileName in $CsvFileNameList) {
    $PathToCsvFile = $FilePath + "\" + $CsvFileName
    $SecretList = Import-Csv -Path $PathToCsvFile -Encoding UTF8

    foreach ($Secret in $SecretList) {
      $SecretName = $Secret.SecretName
      $SecretValue = (ConvertTo-SecureString -String $Secret.SecretValue -AsPlainText -Force)
      $KeyVaultName = $Secret.KeyVaultName

      if (($KeyVaultName -match "Base" -and $CsvFileName -match "Base") -or ($KeyVaultName -match "Container" -and $CsvFileName -match "Container")) {
        Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $SecretValue
      }
    }
  }
}

# Login to Azure
Connect-AzAccount -Subscription $SubscriptionId -Tenant $TenantId

# Set Key Vault Secrets
SetKeyVaultSecret -FilePath $FilePath -CsvFileNameList $CsvFileNameList