### Import Variables
Invoke-Expression (Get-Content ".\VariablesKvDev.ps1" -Raw)

### Functions
# Set Key Vault Secrets with Exspiration Date
function SetKeyVaultSecretWithExpDate {
  param (
    [string]$FilePath,
    [string[]]$CsvFileNameWithExpDateList
  )

  foreach ($CsvFileNameWithExpDate in $CsvFileNameWithExpDateList) {
    $PathToCsvFile = $FilePath + "\" + $CsvFileNameWithExpDate
    $SecretList = Import-Csv -Path $PathToCsvFile -Encoding UTF8

    foreach ($Secret in $SecretList) {
      $SecretName = $Secret.SecretName
      $SecretValue = (ConvertTo-SecureString -String $Secret.SecretValue -AsPlainText -Force)
      $KeyVaultName = $Secret.KeyVaultName
      $ExpDate = $Secret.ExpirationDate

      if (($KeyVaultName -match "Base" -and $CsvFileNameWithExpDate -match "Base") -or ($KeyVaultName -match "Container" -and $CsvFileNameWithExpDate -match "Container")) {
        Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $SecretValue -Expires $ExpDate
      }
    }
  }
}


# Login to Azure
Connect-AzAccount -Subscription $SubscriptionId -Tenant $TenantId

# Set Key Vault Secrets with Exspilation Date
$Reply = Read-Host "Do you want to execute this procedure? (y/n)"
if ($Reply -eq "y") {
  SetKeyVaultSecretWithExpDate -FilePath $FilePath -CsvFileNameWithExpDateList $CsvFileNameWithExpDateList
} else {
  Write-Host "The procedure was canceled."
}