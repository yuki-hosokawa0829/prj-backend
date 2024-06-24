### Import Variables
Invoke-Expression (Get-Content ".\VariablesStg.ps1" -Raw)


### Functions
# Create Resource Group
function CreateResourceGroup {
  param (
    [String[]] $ResourceGroupNameList,
    [string] $Location
  )

  foreach ($ResourceGroupName in $ResourceGroupNameList) {
    $ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if ($null -eq $ResourceGroup) {
      New-AzResourceGroup -Name $ResourceGroupName -Location $Location
    }
  }
}

# Create Enterprise Application
function CreateEnterpriseApplication {
  param (
    [String[]] $EnterpriseAppNameList
  )

  foreach ($EnterpriseAppName in $EnterpriseAppNameList) {
    $EnterpriseApplication = Get-AzADApplication -DisplayName $EnterpriseAppName -ErrorAction SilentlyContinue
    if ($null -eq $EnterpriseApplication) {
      New-AzADApplication -DisplayName $EnterpriseAppName
    }
  }
}

# Create Service Principal
function CreateServicePrincipal {
  param (
    [String[]] $EnterpriseAppNameList
  )

  foreach ($EnterpriseAppName in $EnterpriseAppNameList) {
    $ApplicationId = (Get-AzADApplication -DisplayName $EnterpriseAppName).AppId
    $ServicePrincipal = Get-AzADServicePrincipal -ApplicationId $ApplicationId -ErrorAction SilentlyContinue

    if ($null -eq $ServicePrincipal) {
      New-AzADServicePrincipal -ApplicationId $ApplicationId
    }
  }
}

# Create Secret and export to CSV file
function CreateSecret {
  param (
    [string] $Environment,
    [String[]] $EnterpriseAppNameList,
    [string] $FilePath
  )

  $SecretList = @()
  $PathToCsv = $FilePath + "\AppSecretFor" + $Environment + ".csv"

  foreach ($EnterpriseAppName in $EnterpriseAppNameList) {
    $Application = Get-AzADApplication -DisplayName $EnterpriseAppName
    $ServicePrincipal = Get-AzADServicePrincipal -ApplicationId $Application.AppId
    $Secret = Get-AzADAppCredential -ObjectId $Application.Id -ErrorAction SilentlyContinue

    if ($null -eq $Secret) {
      $Secret = New-AzADAppCredential -ObjectId $Application.Id -EndDate (Get-Date).AddDays(180)
      $SecretList += [PSCustomObject]@{
        EnterpriseAppName = $EnterpriseAppName
        ARM_CLIENT_ID = $Application.AppId
        ARM_CLIENT_SECRET = $Secret.SecretText
        SERVICE_PRINCIPAL_ID = $ServicePrincipal.Id
      }

      $SecretList | Export-Csv -Path $PathToCsv -NoTypeInformation -Encoding UTF8
    }
  }
}

# Assign Contributor Role to Service Principal
function AssignRoleOverResourceGroup {
  param (
    [string] $SubscriptionId,
    [String[]] $EnterpriseAppNameList,
    [String[]] $ResourceGroupNameList
  )

  for ($i = 0; $i -lt $EnterpriseAppNameList.Length; $i++) {

    if ($i -lt 3) {
      $Scope = "/subscriptions/$SubscriptionId/resourceGroups/" + $ResourceGroupNameList[$i]
      $EnterpriseApplication = Get-AzADApplication -DisplayName $EnterpriseAppNameList[$i]
      $ServicePrincipal = Get-AzADServicePrincipal -ApplicationId $EnterpriseApplication.AppId
      $RoleAssginment =  Get-AzRoleAssignment -Scope $Scope -ObjectId $ServicePrincipal.Id -RoleDefinitionName "Contributor"
    } else {
      $Scope = "/subscriptions/$SubscriptionId/resourceGroups/" + $ResourceGroupNameList[$i - 1]
      $EnterpriseApplication = Get-AzADApplication -DisplayName $EnterpriseAppNameList[$i]
      $ServicePrincipal = Get-AzADServicePrincipal -ApplicationId $EnterpriseApplication.AppId
      $RoleAssginment =  Get-AzRoleAssignment -Scope $Scope -ObjectId $ServicePrincipal.Id -RoleDefinitionName "Contributor"
    }

    if ($null -eq $RoleAssginment) {
      New-AzRoleAssignment -ObjectId $ServicePrincipal.Id -RoleDefinitionName "Contributor" -Scope $Scope
    }
  }
}

# Create Storage Account
function CreateStorageAccount {
  param (
    [string] $Environment,
    [String] $ResourceGroupName,
    [string] $StorageAccountName,
    [String] $Location
  )

  $StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue
  $PathToCsv = $FilePath + "\StorageAccountKeyFor" + $Environment + ".csv"

  if ($null -eq $StorageAccount) {
    $StorageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -SkuName Standard_LRS -Location $Location
    # Export Storage Account Key to CSV File
    $StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName).Value[0]
    $StorageAccountKeyCsv = @(
      [PSCustomObject]@{
        StorageAccountName = $StorageAccountName
        StorageAccountKey = $StorageAccountKey
      }
    )

    $StorageAccountKeyCsv | Export-Csv -Path $PathToCsv -NoTypeInformation -Encoding UTF8
  }
}

# Create Storage Container
function CreateStorageContainer {
  param (
    [String] $Environment,
    [String] $ResourceGroupName,
    [string] $StorageAccountName,
    [String[]] $StorageContainerNameList
  )

  $StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue

  foreach ($StorageContainerName in $StorageContainerNameList) {
    $StorageContainer = Get-AzStorageContainer -Name $StorageContainerName -Context $StorageAccount.Context -ErrorAction SilentlyContinue

    if ($null -eq $StorageContainer) {
      New-AzStorageContainer -Name $StorageContainerName -Context $StorageAccount.Context
    }
  }
}

# Assign Contributor Role to Service Principal over Storage Container
function AssignRoleOverStorageContainer {
  param (
    [string] $Environment,
    [string] $SubscriptionId,
    [String[]] $EnterpriseAppNameList,
    [String] $ResourceGroupName,
    [string] $StorageAccountName,
    [String[]] $StorageContainerNameList
  )

  for ($i = 0; $i -lt $EnterpriseAppNameList.Length; $i++) {

    if ($i -lt 3) {
      $Scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$StorageAccountName/blobServices/default/containers/" + $StorageContainerNameList[$i]
      $EnterpriseApplication = Get-AzADApplication -DisplayName $EnterpriseAppNameList[$i]
      $ServicePrincipal = Get-AzADServicePrincipal -ApplicationId $EnterpriseApplication.AppId
      $RoleAssginment =  Get-AzRoleAssignment -Scope $Scope -ObjectId $ServicePrincipal.Id -RoleDefinitionName "Contributor"
    } else {
      $Scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$StorageAccountName/blobServices/default/containers/" + $StorageContainerNameList[$i - 1]
      $EnterpriseApplication = Get-AzADApplication -DisplayName $EnterpriseAppNameList[$i]
      $ServicePrincipal = Get-AzADServicePrincipal -ApplicationId $EnterpriseApplication.AppId
      $RoleAssginment =  Get-AzRoleAssignment -Scope $Scope -ObjectId $ServicePrincipal.Id -RoleDefinitionName "Contributor"
    }

    if ($null -eq $RoleAssginment) {
      New-AzRoleAssignment -ObjectId $ServicePrincipal.Id -RoleDefinitionName "Contributor" -Scope $Scope
    }
  }
}

function AssignRBACAdministerRoleToServicePrincipal {
  param (
    [string] $SubscriptionId,
    [String[]] $EnterpriseAppNameList,
    [String] $ResourceGroupName,
    [String] $RoleDefinitionIds
  )

  # Assign RBAC Administer Role to Service Principal over Resource Group to manage IAM setting of Key Vault
  $ServicePrincipalIdList = @()
  $Scope = "/subscriptions/$SubscriptionId/resourceGroups/" + $ResourceGroupName

  foreach ($EnterpriseAppName in $EnterpriseAppNameList) {
    $EnterpriseApplication = Get-AzADApplication -DisplayName $EnterpriseAppName
    $ServicePrincipalIdList += (Get-AzADServicePrincipal -ApplicationId $EnterpriseApplication.AppId).Id
  }

  # Create Condition for Role Assignment to manage IAM setting of Key Vault
  $ServicePrincipalIds = $ServicePrincipalIdList -join ", "
  $Condition = "((!(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})) OR (@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {$RoleDefinitionIds} AND @Request[Microsoft.Authorization/roleAssignments:PrincipalId] ForAnyOfAnyValues:GuidEquals {$ServicePrincipalIds})) AND ((!(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})) OR (@Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {$RoleDefinitionIds} AND @Resource[Microsoft.Authorization/roleAssignments:PrincipalId] ForAnyOfAnyValues:GuidEquals {$ServicePrincipalIds}))"
  $RoleAssginment = Get-AzRoleAssignment -Scope $Scope -ObjectId $ServicePrincipalIdList[0] -RoleDefinitionName "Role Based Access Control Administrator"

  if ($null -eq $RoleAssginment) {
    New-AzRoleAssignment -ObjectId $ServicePrincipalIdList[0] -RoleDefinitionName "Role Based Access Control Administrator" -Scope $Scope -ConditionVersion 2.0 -Condition $Condition
  }
}

function AddFederatedCredential {
  param (
    [string] $OrganizationName,
    [string] $RepositoryNameForBackendProject,
    [string] $RepositoryNameForContainerProject,
    [String[]] $EnterpriseAppNameList
  )

  # Add Federated Credential to connect to Azure by Github Actions
  foreach ($EnterpriseAppName in $EnterpriseAppNameList) {

    if ($EnterpriseAppName -match "Backend") {

      if ($EnterpriseAppName -match "Develop") {
        $Subject = "repo:" + $OrganizationName + "/" + $RepositoryNameForBackendProject + ":environment:develop"
      } elseif ($EnterpriseAppName -match "Staging") {
        $Subject = "repo:" + $OrganizationName + "/" + $RepositoryNameForBackendProject + ":environment:staging"
      } else {
        $Subject = "repo:" + $OrganizationName + "/" + $RepositoryNameForBackendProject + ":environment:production"
      }

      $ApplicationObjectId = (Get-AzADApplication -DisplayName $EnterpriseAppName).Id
      $FederatedCredentialName = (Get-AzADAppFederatedCredential -ApplicationObjectId $ApplicationObjectId).Name

      if ($FederatedCredentialName -ne "GithubActions") {
        New-AzADAppFederatedCredential -ApplicationObjectId $ApplicationObjectId -Audience "api://AzureADTokenExchange" -Issuer "https://token.actions.githubusercontent.com/" -Name "GitHubActions" -Subject $Subject
      }

    } elseif ($EnterpriseAppName -match "Container") {

      if ($EnterpriseAppName -match "Develop") {
        $Subject = "repo:" + $OrganizationName + "/" + $RepositoryNameForContainerProject + ":environment:develop"
      } elseif ($EnterpriseAppName -match "Staging") {
        $Subject = "repo:" + $OrganizationName + "/" + $RepositoryNameForContainerProject + ":environment:staging"
      } else {
        $Subject = "repo:" + $OrganizationName + "/" + $RepositoryNameForContainerProject + ":environment:production"
      }

      $ApplicationObjectId = (Get-AzADApplication -DisplayName $EnterpriseAppName).Id
      $FederatedCredentialName = (Get-AzADAppFederatedCredential -ApplicationObjectId $ApplicationObjectId).Name

      if ($FederatedCredentialName -ne "GithubActions") {
        New-AzADAppFederatedCredential -ApplicationObjectId $ApplicationObjectId -Audience "api://AzureADTokenExchange" -Issuer "https://token.actions.githubusercontent.com/" -Name "GitHubActions" -Subject $Subject
      }
    }
  }
}

# Login to Azure
Connect-AzAccount -Subscription $SubscriptionId -Tenant $TenantId

# Create Resource Group
CreateResourceGroup -ResourceGroupNameList $ResourceGroupNameList -Location $Location

# Create Enterprise Application
CreateEnterpriseApplication -EnterpriseAppNameList $EnterpriseAppNameList

# Create Service Principal
CreateServicePrincipal -EnterpriseAppNameList $EnterpriseAppNameList

# Create Secret and export to CSV file
CreateSecret -Environment $Environment -EnterpriseAppNameList $EnterpriseAppNameList -FilePath $FilePath

# Assign Contributor Role to Service Principal over Resource Group
AssignRoleOverResourceGroup -SubscriptionId $SubscriptionId -EnterpriseAppNameList $EnterpriseAppNameList -ResourceGroupNameList $ResourceGroupNameList

# Create Storage Account
CreateStorageAccount -Environment $Environment -ResourceGroupName $ResourceGroupNameForBackend -StorageAccountName $StorageAccountName -Location $Location

# Create Storage Container
CreateStorageContainer -Environment $Environment -ResourceGroupName $ResourceGroupNameForBackend -StorageAccountName $StorageAccountName -StorageContainerNameList $StorageContainerNameList

# Assign Contributor Role to Service Principal over Storage Container
AssignRoleOverStorageContainer -SubscriptionId $SubscriptionId -Environment $Environment -EnterpriseAppNameList $EnterpriseAppNameList -ResourceGroupName $ResourceGroupNameForBackend -StorageAccountName $StorageAccountName -StorageContainerNameList $StorageContainerNameList

# Assign RBAC Administer Role to Service Principal
AssignRBACAdministerRoleToServicePrincipal -SubscriptionId $SubscriptionId -EnterpriseAppNameList $EnterpriseAppNameList -ResourceGroupName $ResourceGroupNameForBackend -RoleDefinitionIds $RoleDefinitionIds

# Add Federated Credential to connect to Azure by Github Actions
AddFederatedCredential -OrganizationName $OrganizationName -RepositoryNameForBackendProject $RepositoryNameForBackendProject -RepositoryNameForContainerProject $RepositoryNameForContainerProject -EnterpriseAppNameList $EnterpriseAppNameList