### Import Variables
Invoke-Expression (Get-Content ".\VariablesKvDev.ps1" -Raw)

### Functions
# Remove Secrets
function RemoveKeyVaultSecret {
  param (
    [string]$FilePath,
    [string[]]$CsvFileNameList
  )

  foreach ($CsvFileName in $CsvFileNameList) {
    $PathToCsvFile = $FilePath + "\" + $CsvFileName
    $SecretList = Import-Csv -Path $PathToCsvFile -Encoding UTF8

    foreach ($Secret in $SecretList) {
      $SecretName = $Secret.SecretName
      $KeyVaultName = $Secret.KeyVaultName
      Remove-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -PassThru -Force
    }
    # Wait for 15 seconds
    Start-Sleep -Seconds 15

    foreach ($Secret in $SecretList) {
      $SecretName = $Secret.SecretName
      $KeyVaultName = $Secret.KeyVaultName
      Remove-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -InRemovedState -PassThru -Force
    }
  }
}

# Login to Azure
Connect-AzAccount -Subscription $SubscriptionId -Tenant $TenantId

# Delete Secrets
RemoveKeyVaultSecret -FilePath $FilePath -CsvFileNameList $CsvFileNameList
RemoveKeyVaultSecret -FilePath $FilePath -CsvFileNameList $CsvFileNameWithExpDateList