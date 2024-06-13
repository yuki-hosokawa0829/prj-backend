##### variables
### Azure Resource
$SubscriptionId = "caa6074c-280f-4787-856a-219fd5467ee0"
$TenantId = "d1448c9d-f93c-43c8-880d-402b4ba0bdca"
$Location = "Japan East"
# $Location = "Japan West"

# Resource Group
$ResourceGroupForBackendList = @("IAC-BackendDevelopRG", "IAC-BackendStagingRG", "IAC-BackendProductionRG")
$ResourceGroupForBaseList = @("IAC-BaseDevelopRG", "IAC-BaseStagingRG", "IAC-BaseProductionRG")
$ResourceGroupForProductList = @("IAC-ProductDevelopRG", "IAC-ProductStagingRG", "IAC-ProductProductionRG")
$ResourceGroupForBackendStorage = "IAC-BackendProductionRG"

# Enterprise Application for GitHub Actions
$EnterpriseAppForBackendList = @("IAC-BackendDevelopApp", "IAC-BackendStagingApp", "IAC-BackendProductionApp")
$EnterpriseAppForBaseList = @("IAC-BaseDevelopApp", "IAC-BaseStagingApp", "IAC-BaseProductionApp")
$EnterpriseAppForProductList = @("IAC-ProductDevelopApp", "IAC-ProductStagingApp", "IAC-ProductProductionApp")
$EnterpriseAppForContainerList = @("IAC-ContainerDevelopApp", "IAC-ContainerStagingApp", "IAC-ContainerProductionApp")


# Storage Account
$StorageAccountName = "backendsttfstate"
# $StorageContainerforBackendList = @("backendproduction")
# $StorageContainerforBaseList = @("baseproduction")
# $StorageContainerforProductList = @("productproduction")
$StorageContainerforBackendList = @("backenddevelop", "backendstaging", "backendproduction")
$StorageContainerforBaseList = @("basedevelop", "basestaging", "baseproduction")
$StorageContainerforProductList = @("productdevelop", "productstaging", "productproduction")

### GitHub
$OrganizationName = "yuki-hosokawa0829"
$RepositoryNameForContainerProject = "prj-container"

### File Path to Export CSV File
$FilePath = "C:\Users\river\workdir"


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
    [String[]] $EnterpriseApplicationNameList
  )
  foreach ($EnterpriseApplicationName in $EnterpriseApplicationNameList) {
    $EnterpriseApplication = Get-AzADApplication -DisplayName $EnterpriseApplicationName -ErrorAction SilentlyContinue
    if ($null -eq $EnterpriseApplication) {
      New-AzADApplication -DisplayName $EnterpriseApplicationName
    }
  }
}

# Create Service Principal
function CreateServicePrincipal {
  param (
    [String[]] $EnterpriseApplicationNameList
  )
  foreach ($EnterpriseApplicationName in $EnterpriseApplicationNameList) {
    $ApplicationId = (Get-AzADApplication -DisplayName $EnterpriseApplicationName).AppId
    $ServicePrincipal = Get-AzADServicePrincipal -ApplicationId $ApplicationId -ErrorAction SilentlyContinue
    if ($null -eq $ServicePrincipal) {
      New-AzADServicePrincipal -ApplicationId $ApplicationId
    }
  }
}

# Create Secret and export to CSV file
function CreateSecret {
  param (
    [String[]] $EnterpriseApplicationNameList,
    [string] $FilePath
  )
  $SecretList = @()
  foreach ($EnterpriseApplicationName in $EnterpriseApplicationNameList) {
    $Application = Get-AzADApplication -DisplayName $EnterpriseApplicationName
    $Secret = New-AzADAppCredential -ObjectId $Application.Id -EndDate (Get-Date).AddDays(180)
    $SecretList += [PSCustomObject]@{
      EnterpriseAppName = $EnterpriseApplicationName
      ARM_CLIENT_ID = $Application.AppId
      ARM_CLIENT_SECRET = $Secret.SecretText
    }
  }
  $SecretList | Export-Csv -Path $FilePath -NoTypeInformation
}

# Assign Role to Service Principal
function AssignRoleOverResourceGroup {
  param (
    [String[]] $EnterpriseApplicationNameList,
    [String[]] $ResourceGroupNameList,
    [string] $SubscriptionId
  )
  for ($i = 0; $i -lt $EnterpriseApplicationNameList.Length; $i++) {
    $Scope = "/subscriptions/$SubscriptionId/resourceGroups/" + $ResourceGroupNameList[$i]
    $EnterpriseApplicationName = $EnterpriseApplicationNameList[$i]
    $EnterpriseApplication = Get-AzADApplication -DisplayName $EnterpriseApplicationName
    $ServicePrincipal = Get-AzADServicePrincipal -ApplicationId $EnterpriseApplication.AppId
    New-AzRoleAssignment -ObjectId $ServicePrincipal.Id -RoleDefinitionName "Contributor" -Scope $Scope
  }
}

# Create Storage Container
function CreateStorageContainer {
  param (
    [String] $ResourceGroupName,
    [string] $StorageAccountName,
    [String[]] $ContainerNameList
  )
  $StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
  foreach ($ContainerName in $ContainerNameList) {
    New-AzStorageContainer -Name $ContainerName -Context $StorageAccount.Context
  }
}

# Assign Role to Service Principal over Storage Container
function AssignRoleOverStorageContainer {
  param (
    [String[]] $EnterpriseApplicationNameList,
    [String] $ResourceGroupName,
    [string] $StorageAccountName,
    [String[]] $ContainerNameList
  )
  for ($i = 0; $i -lt $EnterpriseApplicationNameList.Length; $i++) {
    $Scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$StorageAccountName/blobServices/default/containers/" + $ContainerNameList[$i]
    $EnterpriseApplicationName = $EnterpriseApplicationNameList[$i]
    $EnterpriseApplication = Get-AzADApplication -DisplayName $EnterpriseApplicationName
    $ServicePrincipal = Get-AzADServicePrincipal -ApplicationId $EnterpriseApplication.AppId
    New-AzRoleAssignment -ObjectId $ServicePrincipal.Id -RoleDefinitionName "Contributor" -Scope $Scope
  }
}


# Login to Azure
Connect-AzAccount -Subscription $SubscriptionId -Tenant $TenantId

### Project for Backend
# Create Resource Group
CreateResourceGroup -ResourceGroupNameList $ResourceGroupForBackendList -Location $Location

# Create Enterprise Application
CreateEnterpriseApplication -EnterpriseApplicationNameList $EnterpriseAppForBackendList

# Create Service Principal
CreateServicePrincipal -EnterpriseApplicationNameList $EnterpriseAppForBackendList

# Create Secret and export to CSV file
CreateSecret -EnterpriseApplicationNameList $EnterpriseAppForBackendList -FilePath $FilePath"\SecretForIACBackendApp.csv"

# Assign Role to Service Principal over Resource Group
AssignRoleOverResourceGroup -EnterpriseApplicationNameList $EnterpriseAppForBackendList -ResourceGroupNameList $ResourceGroupForBackendList -SubscriptionId $SubscriptionId

# Create Storage Account
$StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupForBackendStorage -Name $StorageAccountName -ErrorAction SilentlyContinue
if ($null -eq $StorageAccount) {
  $StorageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupForBackendStorage -Name $StorageAccountName -SkuName Standard_LRS -Location $Location

  # Export Storage Account Key to CSV File
  $StorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupForBackendStorage -Name $StorageAccountName).Value[0]
  $StorageAccountKeyCsv = @(
    [PSCustomObject]@{
      StorageAccountName = $StorageAccountName
      StorageAccountKey = $StorageAccountKey
    }
  )
  $StorageAccountKeyCsv | Export-Csv -Path $FilePath"\StorageAccountKey.csv" -NoTypeInformation -Encoding UTF8
}

# Create Storage Container
CreateStorageContainer -ResourceGroupName $ResourceGroupForBackendStorage -StorageAccountName $StorageAccountName -ContainerNameList $StorageContainerForBackendList

# Assign Role to Service Principal over Storage Container
AssignRoleOverStorageContainer -EnterpriseApplicationNameList $EnterpriseAppForBackendList -ResourceGroupName $ResourceGroupForBackendStorage -StorageAccountName $StorageAccountName -ContainerNameList $StorageContainerForBackendList


### Project for Base
# Create Resource Group
CreateResourceGroup -ResourceGroupNameList $ResourceGroupForBaseList -Location $Location

# Create Enterprise Application
CreateEnterpriseApplication -EnterpriseApplicationNameList $EnterpriseAppForBaseList

# Create Service Principal
CreateServicePrincipal -EnterpriseApplicationNameList $EnterpriseAppForBaseList

# Create Secret and export to CSV file
CreateSecret -EnterpriseApplicationNameList $EnterpriseAppForBaseList -FilePath $FilePath"\SecretForIACBaseApp.csv"

# Assign Role to Service Principal over Resource Group
AssignRoleOverResourceGroup -EnterpriseApplicationNameList $EnterpriseAppForBaseList -ResourceGroupNameList $ResourceGroupForBaseList -SubscriptionId $SubscriptionId

# Create Storage Container
CreateStorageContainer -ResourceGroupName $ResourceGroupForBackendStorage -StorageAccountName $StorageAccountName -ContainerNameList $StorageContainerForBaseList

# Assign Role to Service Principal over Storage Container
AssignRoleOverStorageContainer -EnterpriseApplicationNameList $EnterpriseAppForBaseList -ResourceGroupName $ResourceGroupForBackendStorage -StorageAccountName $StorageAccountName -ContainerNameList $StorageContainerForBaseList


### Project for Product
# Create Resource Group
CreateResourceGroup -ResourceGroupNameList $ResourceGroupForProductList -Location $Location

# Create Enterprise Application
CreateEnterpriseApplication -EnterpriseApplicationNameList $EnterpriseAppForProductList

# Create Service Principal
CreateServicePrincipal -EnterpriseApplicationNameList $EnterpriseAppForProductList

# Create Secret and export to CSV file
CreateSecret -EnterpriseApplicationNameList $EnterpriseAppForProductList -FilePath $FilePath"\SecretForIACProductApp.csv"

# Assign Role to Service Principal over Resource Group
AssignRoleOverResourceGroup -EnterpriseApplicationNameList $EnterpriseAppForProductList -ResourceGroupNameList $ResourceGroupForProductList -SubscriptionId $SubscriptionId

# Create Storage Container
CreateStorageContainer -ResourceGroupName $ResourceGroupForBackendStorage -StorageAccountName $StorageAccountName -ContainerNameList $StorageContainerForProductList

# Assign Role to Service Principal over Storage Container
AssignRoleOverStorageContainer -EnterpriseApplicationNameList $EnterpriseAppForProductList -ResourceGroupName $ResourceGroupForBackendStorage -StorageAccountName $StorageAccountName -ContainerNameList $StorageContainerForProductList


### Project for Container
# Create Enterprise Application
CreateEnterpriseApplication -EnterpriseApplicationNameList $EnterpriseAppForContainerList

# Create Service Principal
CreateServicePrincipal -EnterpriseApplicationNameList $EnterpriseAppForContainerList

# Create Secret and export to CSV file
CreateSecret -EnterpriseApplicationNameList $EnterpriseAppForContainerList -FilePath $FilePath

# Assign Role to Service Principal over Resource Group
AssignRoleOverResourceGroup -EnterpriseApplicationNameList $EnterpriseAppForContainerList -ResourceGroupNameList $ResourceGroupForProductList -SubscriptionId $SubscriptionId

# Add Federated Credential to connect to Azure by Github Actions
for ($i = 0; $i -lt $EnterpriseAppforContainerList.Length; $i++) {
  if ($EnterpriseAppforContainerList[$i] -match "Develop") {
    $Subject = "repo:" + $OrganizationName + "/" + $RepositoryNameForContainerProject + ":environment:Develop"
  } elseif ($EnterpriseAppforContainerList[$i] -match "Staging") {
    $Subject = "repo:" + $OrganizationName + "/" + $RepositoryNameForContainerProject + ":environment:Staging"
  } else {
    $Subject = "repo:" + $OrganizationName + "/" + $RepositoryNameForContainerProject + ":environment:Production"
  }
  New-AzADAppFederatedCredential -ApplicationObjectId (Get-AzADApplication -DisplayName $EnterpriseAppforContainerList[$i]).Id -Audience api://AzureADTokenExchange -Issuer "https://token.actions.githubusercontent.com/" -Name "GitHubActions" -Subject $Subject
}