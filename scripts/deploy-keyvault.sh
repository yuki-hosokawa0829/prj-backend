#bin/bash
# create resource group
az group create --name $1 --location $2
# create keyvault
az keyvault create --name $3 --resource-group $1 --location $2
# enable rbac authorization
az keyvault update --name $3 --resource-group $1 --enable-rbac-authorization true
# create role assignment
az keyvault role assignment create --role 4633458b-17de-408a-b874-0445c86b69e6 --assignee $4 --scope $(az keyvault show --name $3 --resource-group $1 --query id -o tsv)