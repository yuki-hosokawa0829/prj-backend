#bin/bash
# create resource group
az group create --name $1 --location $2
# create storage account
az storage account create --name $3 --resource-group $1 --location $2 --sku Standard_LRS
# create storage container
az storage container create --name $4 --account-name $3
# add role assignment to container
#az role assignment create --role Contributor --assignee-object-id $5 --assignee-principal-type ServicePrincipal --scope /subscriptions/$6/resourceGroups/$1/providers/Microsoft.Storage/storageAccounts/$3/blobServices/default/containers/$4