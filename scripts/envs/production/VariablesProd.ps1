### Environment
$global:Environment = "Production"

### Azure Resource
$global:SubscriptionId = "caa6074c-280f-4787-856a-219fd5467ee0"
$global:TenantId = "d1448c9d-f93c-43c8-880d-402b4ba0bdca"
$global:Location = "Japan West"

# Resource Group
$global:ResourceGroupNameList = @(
  "IAC-Backend" + $Environment + "RG"
  "IAC-Base" + $Environment + "RG"
)
$global:ResourceGroupNameForBackend = $ResourceGroupNameList[0]

# Enterprise Application for GitHub Actions
$global:EnterpriseAppNameList = @(
  "IAC-Backend" + $Environment + "App"
  "IAC-Base" + $Environment + "App"
  "IAC-Container" + $Environment + "App"
)

# Storage Account
$global:StorageAccountName = "stotfstate" + $Environment.ToLower()
$global:StorageContainerNameList = @(
  "backend" + $Environment.ToLower()
  "base" + $Environment.ToLower()
)

# Role Definition IDs(Key Vault Secet User, Key Vault Secret Officer, Key Vault Certificate User, Key Vault Certificates Officer, Key Vault Crypto User, Key Vault Crypto Officer)
$global:RoleDefinitionIds = "4633458b-17de-408a-b874-0445c86b69e6, b86a8fe4-44ce-4948-aee5-eccb2c155cd7, db79e9a7-68ee-4b58-9aeb-b90e7c24fcba, a4417e6f-fecd-4de8-b567-7b0420556985, 12338af0-0e69-4776-bea7-57ae8d297424, 14b46e9e-c2b7-41b4-b07b-48a6ebf60603"

### GitHub
$global:OrganizationName = "yuki-hosokawa0829"
$global:RepositoryNameForBackendProject = "prj-backend"
$global:RepositoryNameForContainerProject = "prj-container"

### File Path to Export CSV File
$global:FilePath = "C:\Users\river\workdir"

### Csv File Name for Key Vault Secrets
$global:CsvFileNameList = @(
  $Environment + "BaseTestCsv.csv"
  $Environment + "ContainerTestCsv.csv"
)

$global:CsvFileNameWithExpDateList = @(
  $Environment + "BaseTestCsvWithExpDate.csv"
  $Environment + "ContainerTestCsvWithExpDate.csv"
)