#!/usr/bin/env bash

##
# This script creates an Azure Storage account and several Azure Blob Storage
# containers for use with Nextcloud deployed on AKS.
#
# @author Guy Elsmore-Paddock (guy@inveniem.com)
# @copyright Copyright (c) 2019, Inveniem
# @license GNU AGPL version 3 or any later version
#

set -u
set -e

source './config.env'

echo "Creating resource group '${STORAGE_RESOURCE_GROUP}'..."
az group create \
  --name "${STORAGE_RESOURCE_GROUP}" \
  --location "${LOCATION}"
echo ""

echo "Creating standard storage account '${STORAGE_ACCOUNT_NAME}'..."
az storage account create \
  --resource-group "${STORAGE_RESOURCE_GROUP}" \
  --name "${STORAGE_ACCOUNT_NAME}" \
  --kind "StorageV2" \
  --sku "Standard_LRS" \
  --location "${LOCATION}"
echo ""

export AZURE_STORAGE_CONNECTION_STRING=$( \
  az storage account show-connection-string \
    --name "${STORAGE_ACCOUNT_NAME}" \
    --query "connectionString" \
    --output=tsv
)

echo "Creating blob containers..."

for blob_container_name in "${STORAGE_BLOB_CONTAINERS[@]}"; do
    echo "Creating blob container '${blob_container_name}'."
    az storage container create --name "${blob_container_name}"
done

echo "Done."
echo ""

STORAGE_ACCOUNT_KEY=$( \
  az storage account keys list \
    --account-name "${STORAGE_ACCOUNT_NAME}" \
    --query "[0].value" \
    --output=tsv
)

echo "Creating BlobFUSE Kubernetes Secret for '${KUBE_STORAGE_ACCOUNT_SECRET}'..."
kubectl create secret generic \
    "${KUBE_STORAGE_ACCOUNT_SECRET}" \
    --from-literal accountname="${STORAGE_ACCOUNT_NAME}" \
    --from-literal accountkey="${STORAGE_ACCOUNT_KEY}" \
    --type="azure/blobfuse"
