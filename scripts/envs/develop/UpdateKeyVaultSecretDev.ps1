### Import Variables
Invoke-Expression (Get-Content ".\VariablesDev.ps1" -Raw)

### Functions
# Set Key Vault Secrets
function UpdateKeyVaultSecret {
  param (
    [string]$FilePath,
    [string[]]$CsvFileNameList
  )

  foreach ($CsvFileName in $CsvFileNameList) {
    $PathToCsvFile = $FilePath + "\" + $CsvFileName
    $SecretList = Import-Csv -Path $PathToCsvFile -Encoding UTF8

    foreach ($Secret in $SecretList) {
      $SecretName = $Secret.SecretName
      $NewSecretValue = $Secret.SecretValue
      $KeyVaultName = $Secret.KeyVaultName
      $UploadedSecretValue = (Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -AsPlainText)

      if ($NewSecretValue -eq $UploadedSecretValue) {
        Write-Host "The secret value of $SecretName is the same as the current value."
      } elseif ($null -eq $UploadedSecretValue){
        Write-Output "The secret $SecretName does not exist."
      } else {
        $Reply = Read-Host "Do you want to update $SecretName? (y/n)"
        if ($Reply -eq "y") {
          $SecuredNewSecretValue = ConvertTo-SecureString -String $NewSecretValue -AsPlainText -Force
          Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $SecuredNewSecretValue
          Write-Host "Updated secret: $SecretName in KeyVault: $KeyVaultName"
        } else {
          Write-Host "The update of $SecretName was canceled."
        }
      }
    }
  }
}

# Login to Azure
Connect-AzAccount -Subscription $SubscriptionId -Tenant $TenantId

# Update Key Vault Secrets
UpdateKeyVaultSecret -FilePath $FilePath -CsvFileNameList $CsvFileNameList