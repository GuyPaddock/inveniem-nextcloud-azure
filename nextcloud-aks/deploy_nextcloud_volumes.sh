#!/usr/bin/env bash

##
# This script deploys Azure-Blob-storage-backed Nextcloud persisted volume
# claims and persisted volumes to Kubernetes.
#
# @author Guy Elsmore-Paddock (guy@inveniem.com)
# @copyright Copyright (c) 2019, Inveniem
# @license GNU AGPL version 3 or any later version
#

set -e
set -u

source './config.env'

FILES=(
    'blob-volumes.yaml'
    'blob-claims.yaml'
)

echo "Setting up Nextcloud persisted volumes for Azure Blob Storage..."
for file in "${FILES[@]}"; do
    ./preprocess_config.sh "configs/${file}" | kubectl apply -f -
done
echo "Done."
echo ""

echo "Setting up Nextcloud persisted volumes for Azure Files..."
./generate_azure_file_volume_configs.sh | kubectl apply -f -
echo "Done."
echo ""
