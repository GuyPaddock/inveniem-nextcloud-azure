#!/usr/bin/env bash

##
# This script removes the Nextcloud application, its load balancer, its config,
# and its secrets from Kubernetes.
#
# @author Guy Elsmore-Paddock (guy@inveniem.com)
# @copyright Copyright (c) 2019, Inveniem
# @license GNU AGPL version 3 or any later version
#

set -e
set -u

source './config.env'

if [[ "${POD_TYPE:-apache}" = "fpm-nginx" ]]; then
    FILES=('nextcloud-fpm-nginx.template.yaml')
else
    FILES=('nextcloud-apache.template.yaml')
fi

FILES+=(
    'secrets.template.yaml'
    'configmap.template.yaml'
)

# HACK: Until AKS supports pod presets, we have to kludge the dynamic mounts in
# via a variable expansions.
source ./generate_backend_share_mount_lines.sh

echo "Un-deploying Nextcloud core application..."
for file in "${FILES[@]}"; do
    ./preprocess_config.sh "configs/${file}" | kubectl delete -f -
done
echo "Done."
echo ""

# NOTE: This is commented out for now because we can't yet use pod presets on
# AKS. Vote for the feature here:
# https://feedback.azure.com/forums/914020-azure-kubernetes-service-aks/suggestions/35054089-support-podpreset-alpha-feature

#echo "Removing pod preset for dynamic file shares..."
#./generate_share_mount_pod_preset.sh | kubectl delete -f -
#echo "Done."
#echo ""
