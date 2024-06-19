#!/bin/bash

#############################################
######### Don't push to main branch #########
#############################################

# variables
$AZURESUBSCRIPTIONID=3b3b3b3b-3b3b-3b3b-3b3b-3b3b3b3b3b3b
$LOCATION=japanwest
$RESOURCEGROUPNAMELIST=("BackendDevelopRG" "BackendStagingRG" "BackendProductionRG" "BaseDevelopRG" "BaseStagingRG" "BaseProductionRG" "ProductDevelopRG" "ProductStagingRG" "ProductProductionRG")
$APPLICATIONNAMELIST=("BackendDevelopApp" "BackendStagingApp" "BackendProductionApp" "BaseDevelopApp" "BaseStagingApp" "BaseProductionApp" "ProductDevelopApp" "ProductStagingApp" "ProductProductionApp")
$USERADMINNAME=riversnonw.onomatopeia@gmail.com
$USERADMINPASSWORD=95283456aA

# Login to Azure
az login -u $USERADMINNAME -p $USERADMINPASSWORDLIST

# Create resource group
for $RESOURCEGROUPNAME in $RESOURCEGROUPNAMELIST
do
    az group create --name $RESOURCEGROUPNAME --location $LOCATION
done

# Create Enterprise Application for GitHub Actions
for $APPLICATIONNAME in $RESOURCEGROUPNAMELIST
do
    az ad sp create-for-rbac --name $APPLICATIONNAME --role Contributor \
       --scopes /subscriptions/$AZURESUBSCRIPTIONID/resourceGroups/$RESOURCEGROUPNAME \
       --json-auth
done