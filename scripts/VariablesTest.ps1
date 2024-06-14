### Environment
$Environment = "Production"

### Azure Resource
$global:SubscriptionId = "caa6074c-280f-4787-856a-219fd5467ee0"
$global:TenantId = "d1448c9d-f93c-43c8-880d-402b4ba0bdca"
$global:Location = "Japan West"

# Resource Group
$global:ResourceGroupNameList = @(
                              "IAC-Backend" + $Environment + "RG"
                              "IAC-Base" + $Environment + "RG"
                              "IAC-Product" + $Environment + "RG"
                              )
$global:ResourceGroupNameForBackend = $ResourceGroupNameList[0]

# Enterprise Application for GitHub Actions
$global:EnterpriseAppNameList = @(
                              "IAC-Backend" + $Environment + "App"
                              "IAC-Base" + $Environment + "App"
                              "IAC-Product" + $Environment + "App"
                              "IAC-Container" + $Environment + "App"
                              )

# Storage Account
$global:StorageAccountName = "stotfstate" + $Environment.ToLower()
$global:StorageContainerNameList = @(
                                "backend" + $Environment.ToLower()
                                "base" + $Environment.ToLower()
                                "product" + $Environment.ToLower()
                                )

# Role Definition IDs(Key Vault Secet User, Key Vault Secret Officer, Key Vault Certificate Officer)
$global:RoleDefinitionIds = "4633458b-17de-408a-b874-0445c86b69e6, b86a8fe4-44ce-4948-aee5-eccb2c155cd7, a4417e6f-fecd-4de8-b567-7b0420556985"

### GitHub
$global:OrganizationName = "yuki-hosokawa0829"
$global:RepositoryNameForContainerProject = "prj-container"

### File Path to Export CSV File
$global:FilePath = "C:\Users\river\workdir"