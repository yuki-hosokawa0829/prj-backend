### Import Variables
Invoke-Expression (Get-Content ".\VariablesDev.ps1" -Raw)

### Functions
# Remove Secrets
function RemoveKeyVaultSecret {
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
        Remove-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -PassThru -Force
      }
    }
      # Wait for 15 seconds
      Start-Sleep -Seconds 15

    foreach ($CsvFile in $CsvFileList) {
      if ($CsvFile.IAM -match "シークレット") {
        $SecretName = $CsvFile.ParamName
        $KeyVaultName = $CsvFile.KeyVaultName.Replace("○○", $Environment.ToLower())
        Remove-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -InRemovedState -PassThru -Force
      }
    }
  }
}

# Login to Azure
Connect-AzAccount -Subscription $SubscriptionId -Tenant $TenantId

# Delete Secrets
RemoveKeyVaultSecret -Environment $Environment -FilePath $FilePath -CsvFileNameList $CsvFileNameList
$Reply = Read-Host "Do you want to execute this procedure? (y/n)"
if ($Reply -eq "y") {
  RemoveKeyVaultSecret -Environment $Environment -FilePath $FilePath -CsvFileNameList $CsvFileNameWithExpDateList
} else {
  Write-Host "The procedure was canceled."
}