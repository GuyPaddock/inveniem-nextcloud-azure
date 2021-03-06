#!/usr/bin/env bash

##
# This script deploys the SFTP-WS server app and load balancer to Kubernetes.
#
# @author Guy Elsmore-Paddock (guy@inveniem.com)
# @copyright Copyright (c) 2019, Inveniem
# @license GNU AGPL version 3 or any later version
#

set -e
set -u

source './config.env'

FILES+=(
  'app-sftp-ws-server.template.yaml'
)

../../set_context.sh

# HACK: Until AKS supports pod presets, we have to kludge the dynamic mounts in
# via a variable expansions instead.
source ./generate_share_mount_lines.sh

echo "Deploying SFTP-WS server application..."
for file in "${FILES[@]}"; do
  ../../preprocess_config.sh "configs/${file}" | kubectl apply -f -
done
echo "Done."
echo ""
