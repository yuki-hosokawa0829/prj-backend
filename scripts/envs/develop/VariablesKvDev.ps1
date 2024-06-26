### Environment
$global:Environment = "Develop"

### Azure Resource
$global:SubscriptionId = "caa6074c-280f-4787-856a-219fd5467ee0"
$global:TenantId = "d1448c9d-f93c-43c8-880d-402b4ba0bdca"

$global:FilePath = "C:\Users\river\workdir"

# Csv File Name
$global:CsvFileNameList = @(
  $Environment + "ProductTestCsv.csv"
  $Environment + "ContainerTestCsv.csv"
)

$global:CsvFileNameWithExpDateList = @(
  $Environment + "ProductTestCsvWithExpDate.csv"
  $Environment + "ContainerTestCsvWithExpDate.csv"
)