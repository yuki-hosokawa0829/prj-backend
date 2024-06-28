### Import Variables
Invoke-Expression (Get-Content ".\VariablesDev.ps1" -Raw)

### Functions
# Set Key Vault Secrets
function SetKeyVaultSecret {
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
        $SecretValue = ConvertTo-SecureString -String $CsvFile.ParamValue -AsPlainText -Force
        $KeyVaultName = $CsvFile.KeyVaultName.Replace("○○", $Environment.ToLower())
        Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $SecretValue
      }
    }
  }
}

# Login to Azure
Connect-AzAccount -Subscription $SubscriptionId -Tenant $TenantId

# Set Key Vault Secrets
SetKeyVaultSecret -Environment $Environment -FilePath $FilePath -CsvFileNameList $CsvFileNameList