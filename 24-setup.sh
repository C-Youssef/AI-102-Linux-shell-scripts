#!/bin/bash

# values for your subscription and resource group
subscription_id=YOUR_SUBSCRIPTION_ID
resource_group=YOUR_RESOURCE_GROUP
location=YOUR_LOCATION_NAME

# Get random numbers to create unique resource names
unique_id=$RANDOM$RANDOM

echo -e Creating storage... "\n"
az storage account create --name ai102str$unique_id --subscription $subscription_id --resource-group $resource_group --location $location --sku Standard_LRS --encryption-services blob --default-action Allow --output none

echo -e Uploading files... "\n"
# Hack to get storage key
AZURE_STORAGE_KEY=$(az storage account keys list --subscription $subscription_id --resource-group $resource_group --account-name ai102str$unique_id | jq -r '.[0] | .value')
echo Azure storage key $AZURE_STORAGE_KEY

az storage container create --account-name ai102str$unique_id --name margies --public-access blob --auth-mode key --account-key $AZURE_STORAGE_KEY --output none
az storage blob upload-batch -d margies -s data --account-name ai102str$unique_id --auth-mode key --account-key $AZURE_STORAGE_KEY  --output none

echo Creating cognitive services account...
az cognitiveservices account create --kind CognitiveServices --location $location --name ai102cog$unique_id --sku S0 --subscription $subscription_id --resource-group $resource_group --yes --output none

echo -e Creating search service... "\n"
echo "(If this gets stuck at '- Running ..' for more than a minute, press CTRL+C then select N)"
az search service create --name ai102srch$unique_id --subscription $subscription_id --resource-group $resource_group --location $location --sku basic --output none

echo ------------------------------------- "\n"
echo Storage account: ai102str$unique_id
az storage account show-connection-string --subscription $subscription_id --resource-group $resource_group --name ai102str$unique_id
echo ----
echo Cognitive Services account: ai102cog$unique_id
az cognitiveservices account keys list --subscription $subscription_id --resource-group $resource_group --name ai102cog$unique_id
echo ----
echo -e Search Service: ai102srch "\n"
echo -e Url: https://ai102srch$unique_id.search.windows.net "\n"
echo -e Admin Keys: "\n"
az search admin-key show --subscription $subscription_id --resource-group $resource_group --service-name ai102srch$unique_id
echo -e Query Keys: "\n"
az search query-key list --subscription $subscription_id --resource-group $resource_group --service-name ai102srch$unique_id