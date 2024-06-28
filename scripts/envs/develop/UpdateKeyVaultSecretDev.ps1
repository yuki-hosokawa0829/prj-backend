### Import Variables
Invoke-Expression (Get-Content ".\VariablesDev.ps1" -Raw)

### Functions
# Set Key Vault Secrets
function UpdateKeyVaultSecret {
  param (
    [string]$Environment,
    [string]$FilePath,
    [string[]]$CsvFileNameList
  )

  foreach ($CsvFileName in $CsvFileNameList) {
    $PathToCsvFile = Join-Path -Path $FilePath -ChildPath $CsvFileName
    $CsvFileList = Import-Csv -Path $PathToCsvFile -Encoding UTF8

    foreach ($CsvFile in $CsvFileList) {
      if ($CsvFile.IAM -match "シークレット") {
        $SecretName = $CsvFile.ParamName
        $KeyVaultName = $CsvFile.KeyVaultName.Replace("○○", $Environment.ToLower())
        $NewSecretValue = $CsvFile.ParamValue
        $UploadedSecretValue = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -AsPlainText)

        if ($NewSecretValue -eq $UploadedSecretValue) {
          Write-Host "The secret value of $SecretName is the same as the current value."
        } elseif ($null -eq $UploadedSecretValue){
          Write-Output "The secret $SecretName does not exist."
        } else {
          Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $SecuredNewSecretValue
          Write-Host "Updated secret: $SecretName in KeyVault: $KeyVaultName"
        }
      }
    }
  }
}

# Login to Azure
Connect-AzAccount -Subscription $SubscriptionId -Tenant $TenantId

# Update Key Vault Secrets
UpdateKeyVaultSecret -Environment $Environment -FilePath $FilePath -CsvFileNameList $CsvFileNameList