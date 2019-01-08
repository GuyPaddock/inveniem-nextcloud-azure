#!/usr/bin/env bash

##
# This is a top-level script to deploy Nextcloud and its storage dependencies to
# Azure and AKS.
#
# @author Guy Elsmore-Paddock (guy@inveniem.com)
# @copyright Copyright (c) 2019, Inveniem
# @license GNU AGPL version 3 or any later version
#

set -e
set -u

./setup_storage_account.sh
./deploy_nextcloud_volumes.sh
./deploy_nextcloud_app.sh
