### Import Variables
Invoke-Expression (Get-Content ".\VariablesDev.ps1" -Raw)

### Functions
# Set Key Vault Secrets with Exspiration Date
function SetKeyVaultSecretWithExpDate {
  param (
    [string]$Environment,
    [string]$FilePath,
    [string[]]$CsvFileNameWithExpDateList
  )

  foreach ($CsvFileName in $CsvFileNameWithExpDateList) {
    $PathToCsvFile = Join-Path -Path $FilePath -ChildPath $CsvFileName
    $CsvFileList = Import-Csv -Path $PathToCsvFile -Encoding UTF8

    foreach ($CsvFile in $CsvFileList) {
      if ($CsvFile.IAM -match "シークレット") {
        $SecretName = $CsvFile.ParamName
        $SecretValue = ConvertTo-SecureString -String $CsvFile.ParamValue -AsPlainText -Force
        $KeyVaultName = $CsvFile.KeyVaultName.Replace("○○", $Environment.ToLower())
        $ExpDate = $CsvFile.ExpDate
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
  SetKeyVaultSecretWithExpDate -Environment $Environment -FilePath $FilePath -CsvFileNameWithExpDateList $CsvFileNameWithExpDateList
} else {
  Write-Host "The procedure was canceled."
}