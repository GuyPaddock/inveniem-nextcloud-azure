# Resources for Running Nextcloud on an Azure Kubernetes Service (AKS)
This repository contains docker images, configurations, and scripts to assist in 
getting Nextcloud to run  on an Azure Kubernetes Service.

This approach offers significantly more flexibility for storage than trying to
run Nextcloud on Azure Container Instances.

## Deploying Nextcloud to AKS
### Dependencies
You will need to do the following before you can use this resource kit:
- Create an AKS cluster with at least one node 
  (F2s v2 instances are recommended).
- Setup an Azure Container Registry (ACR).
- Setup a MySQL server instance on Azure.
- Create an empty database and its corresponding user account on the MySQL 
  database instance.
- Install CLI interfaces for each of the following on the machine from which 
  you will be deploying to Azure:
    - Azure (`az`)
    - MySQL (`mysql`)
    - Docker (`docker`)
- Install the Azure CLI on the machine from which you are deploying and
  [sign-in to your Azure account](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli).
- Ensure that your account has the
  [the "Global administrator" role](https://docs.microsoft.com/en-us/azure/active-directory/users-groups-roles/directory-assign-admin-roles) 
  within your Azure AD tenant, for best results.
- Specify credentials and all preferences for deployment in the `config.env`
  file (see next section).

### Choosing the Pod Type
The configurations in this repository support two different Kubernetes pod 
deployment models:
 - An Apache-based deployment model (`apache`), in which Nextcloud is hosted on 
   Apache, with PHP served up via `mod_php` and Apache handling static files 
   directly. Everything necessary to run the Nextcloud is handled by pods 
   containing a single container called `backend-nextcloud-apache`.

 - A PHP-FPM-based deployment model (`fpm-nginx`), in which Nextcloud is hosted 
   on a combination of technologies, with PHP served up via PHP-FPM proxied 
   through Nginx, and Nginx handling static file hosting. This deployment 
   consists of pods with two containers -- `backend-nextcloud-fpm` and 
   `middle-nextcloud-nginx`.

Set this via the `POD_TYPE` setting in `config.env`.

### Providing Settings to the Script
All of the settings needed by scripts need to be provided in `config.env`.

Copy `config.example.env` to `config.env` and then customize it for your needs.

**NOTE:** During installation and upgrades, ensure `NEXTCLOUD_REPLICA_COUNT` is 
set to `1` to avoid a race condition from multiple containers attempting to 
install or upgrade Nextcloud at the same time.

### Granting AKS Access to ACR
In order to use the Docker images generated by the Dockerfiles in this repo, you
will need to publish them to ACR, and you will need to give AKS a means to 
access ACR.

The preferred approach for this is by generating a _service principal_ 
(basically, a user account for AKS to log-in to ACR) and then granting that
service principal only the necessary permissions to access ACR.

The `./setup_aks_acr_service_principal.sh` script can set this up for you
automatically, based on settings in `config.env`. You only need to run this 
script once, even if you have removed Nextcloud from your Azure deployment with 
`./delete_nextcloud.sh`.

### Running the Deployment
Run `./deploy_nextcloud.sh` to create storage accounts and deploy Nextcloud to 
AKS.

#### About Storage Accounts
This resource kit is designed to create a storage account into which all of the
persistent data that Nextcloud requires can be stored. The account is created by 
`./setup_storage_account.sh` as part of the top-level `./deploy_nextcloud.sh` 
script.

All files -- including configuration files, per-user data, and per-client 
shares -- are stored on Azure Files shares that the script creates.

#### About the Redis Cache
To support clustered deployment (i.e. multiple Nextcloud pods behind a load
balancer), this resource kit is designed to create a Redis cache pod within
the cluster that is used to persist file locks and PHP sessions. The cache is 
automatically created by `./deploy_redis_cache.sh` as part of running the 
top-level `./deploy_nextcloud.sh` script.

#### Running the Deployment as Individual Pieces
For greater control -- as an alternative to running the top-level script -- you 
may open the `./deploy_nextcloud.sh` script in a text editor to review each of 
the scripts that top-level script invokes to do its work, and then invoke them 
piecewise to deploy only the portions you'd like to deploy. Please note that 
scripts are listed in dependency order; Nextcloud requires both a Redis cache 
to be in place, as well as storage accounts to be created and registered with 
Kubernetes as persistent volumes in order for deployment of Nextcloud pods to 
proceed.

#### Setting Up Antivirus
If you fully deploy this kit, you will end up with a ClamAV pod and service 
running alongside the pods for Nextcloud. ClamAV is configured to run in daemon 
mode, to support antivirus scans through the 
[Nextcloud Antivirus app](https://docs.nextcloud.com/server/15/admin_manual/configuration_server/antivirus_configuration.html). 
You will need to enable the app and configure antivirus settings under 
`settings/admin/security` after Nextcloud is installed for the first time.

Use these settings:
- **Mode:** 
  Daemon
- **Host:** 
  internal-clamav._NAMESPACE_ (where _NAMESPACE_ is the Kubernetes namespace, 
  such as `default` or `nextcloud-live`)
- **Port:** 
  3310
- **Stream Length:** 
  26214400 bytes
- **File size limit, -1 means no limit:** 
  -1 bytes
- **When infected files are found during a background scan:** 
  _(Administrator choice)_

## Removing Nextcloud from AKS
Run `./delete_nextcloud.sh` to fully remove Nextcloud and its storage accounts
from your AKS and Azure instance. **Beware that this will remove all files you 
currently have stored on Nextcloud.**

Alternatively, open the `./delete_nextcloud.sh` script in a text editor to 
review each of the other scripts that top-level script invokes to do its work, 
and then invoke only the scripts that remove the portions you'd like to remove.

## Admin Utility Scripts
A few scripts have been provided to make administration of deployments slightly
easier.

### Publishing Container Images to ACR
The `./publish_container_images.sh` script can be used to build and publish all 
of the images under `docker` to your ACR instance.

### Connecting to the AKS Kubernetes Dashboard
Run `./launch_aks_dashboard.sh` to setup a tunnel on your local machine at port
`8090`. This script wraps the `az aks browse` command, providing some additional
enhancements like automatic restoration of the tunnel if it dies.

### Connecting to the MySQL CLI
Run `./launch_db_shell.sh` to launch the MySQL CLI, connected via the same 
credentials that Nextcloud uses to connect.

## Licensing
All of the scripts and documentation provided in this repository are licensed
under the GNU Affero GPL version 3, or any later version.

© 2019 Inveniem. All rights reserved.