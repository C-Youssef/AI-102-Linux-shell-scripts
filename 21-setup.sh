#!/bin/bash

# Set variable values 
subscription_id=YOUR_SUBSCRIPTION_ID
resource_group=YOUR_RESOURCE_GROUP
location=YOUR_LOCATION_NAME
expiry_date=2022-01-01T00:00:00Z

# Get random numbers to create unique resource names
unique_id=$RANDOM$RANDOM

STORAGE_ACCT_NAME=ai102form$unique_id

# Create a storage account in your Azure resource group 
echo -e Creating storage account $STORAGE_ACCT_NAME ... "\n"
az storage account create --name $STORAGE_ACCT_NAME --subscription $subscription_id --resource-group $resource_group --location $location --sku Standard_LRS --encryption-services blob --default-action Allow --output none

# Get storage key to create a container in the storage account 
AZURE_STORAGE_KEY=$(az storage account keys list --subscription $subscription_id --resource-group $resource_group --account-name $STORAGE_ACCT_NAME | jq -r '.[0] | .value')
echo -e Storage account key1: $AZURE_STORAGE_KEY "\n"

# Create container 
echo -e Creating storage container sampleforms ... "\n"
az storage container create --account-name $STORAGE_ACCT_NAME --name sampleforms --public-access blob --auth-mode key --account-key $AZURE_STORAGE_KEY --output none

# Upload each file as a blob 
echo -e "Uploading files from your local sampleforms folder ./sample-forms to a container called sampleforms in the storage account ... \n"
az storage blob upload-batch -d sampleforms -s ./sample-forms --account-name $STORAGE_ACCT_NAME --auth-mode key --account-key $AZURE_STORAGE_KEY --output none

# Get a Shared Access Signature (a signed URI that points to one or more storage resources) for the blobs in sampleforms   
SAS_TOKEN=$(az storage container generate-sas --account-name $STORAGE_ACCT_NAME --name sampleforms --expiry $expiry_date --permissions rwl --account-key $AZURE_STORAGE_KEY)

# remove quations "" from SAS_TOKEN.
temp="${SAS_TOKEN%\"}"
SAS_TOKEN="${temp#\"}"

echo -e "\nShared access signature (SAS) token:" $SAS_TOKEN "\n"

URI=https://$STORAGE_ACCT_NAME.blob.core.windows.net/sampleforms?$SAS_TOKEN

# Print the generated Shared Access Signature URI, which is used by Azure Storage to authorize access to the storage resource
echo -e SAS URI: $URI "\n"
