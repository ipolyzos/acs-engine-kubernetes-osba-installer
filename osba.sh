#!/bin/bash

# Azure OSBA Installation
#
# NOTE:
#  - Supports Linux and Darwin Operating Systems
#
# Author: Ioannis Polyzos

# Exit immediately if a pipeline returns a non-zero status.
set -o errexit

# Return value of a pipeline is the value of the last command to exit with a non-zero status or zero
# if all commands in the pipeline exit successfully.
set -o pipefail

# Treat unset variables and parameters other than the special parameters ‘@’ or ‘*’ as an error when performing parameter expansion.
set -o nounset

# download and install Kubectl CLI tool
function install_kubectl {
    echo "Installing 'kubectl' CLI"

    # remove current installation if exist
    KBCTL_PATH=`command -v kubectl`
    if [[ ${KBCTL_PATH} ]]
    then
      echo "exists at $KBCTL_PATH"
    fi

    # download and extract the binary for the current env
    case "$OSTYPE" in
        darwin*)  curl -o kubectl https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/darwin/amd64/kubectl ;;
        linux*)   wget https://storage.googleapis.com/kubernetes-release/release/v1.10.2/bin/linux/amd64/kubectl;;
        *)        echo "Unsupported operating system: $OSTYPE" ;;
    esac

    chmod +x kubectl

    # install in the expected path
    sudo mv kubectl /usr/local/bin/
}

# download and install Helm CLI tool
function install_helm {
    echo "Installing 'helm' CLI"

    # download and extract the binary for the current env
    case "$OSTYPE" in
        darwin*)  curl https://kubernetes-helm.storage.googleapis.com/helm-v2.8.1-darwin-amd64.tar.gz | tar xvz --strip-components=1 darwin-amd64/helm ;;
        linux*)   curl https://kubernetes-helm.storage.googleapis.com/helm-v2.8.1-linux-amd64.tar.gz | tar xvz --strip-components=1 linux-amd64/helm ;;
        *)        echo "Unsupported operating system: $OSTYPE" ;;
    esac

    chmod +x helm
    sudo mv helm /usr/local/bin/
}

# download and install 'svcat' CLI
function install_svcat(){
   echo "Installing 'svcat' CLI"

   # download and extract the binary for the current env
   case "$OSTYPE" in
        darwin*)  curl -sLO https://download.svcat.sh/cli/latest/darwin/amd64/svcat ;;
        linux*)   curl -sLO https://download.svcat.sh/cli/latest/linux/amd64/svcat  ;;
        *)        echo "Unsupported operating system: $OSTYPE" ;;
    esac

    chmod +x ./svcat
    mv ./svcat /usr/local/bin/
}

# extract and setup environmental variables
function setup_env_vars(){

   # check if OSBA stability has not been set
   if [[ ! ${OSBA_STABILITY+x} ]]; then
     # if not set it sets default to experimental
     OSBA_STABILITY="EXPERIMENTAL"
   fi

    # extract subscription id
   AZURE_SUBSCRIPTION_ID="$(az account show --query id --out tsv)"
    # create service principal and store its JSON output
   SERVICE_PRINCIPAL_JSON="$(az ad sp create-for-rbac --name osba-sp -o json)"
    # extract svc principal name from svc-principal creation output
   AZURE_SP_NAME="$(echo $SERVICE_PRINCIPAL_JSON | jq -r .name)"
    # extract tenant-id from svc-principal creation output
   AZURE_TENANT_ID="$(echo $SERVICE_PRINCIPAL_JSON | jq -r .tenant)"
    # extract client-id from svc-principal creation output
   AZURE_CLIENT_ID="$(echo $SERVICE_PRINCIPAL_JSON | jq -r .appId)"
    # extract client-secret from svc-principal creation output
   AZURE_CLIENT_SECRET="$(echo $SERVICE_PRINCIPAL_JSON | jq -r .password)"

   if [[ ! ${OSBA_HELM_VERSION+x} ]]; then
     # if not set it sets default helm version used as v0.11.0
     OSBA_HELM_VERSION="v0.11.0"
   fi
}

function remove_osba_installation(){

      # disable exit on non 0
      set +e

      # remove the service-catalog deployment
      echo "Removing service-catalog deployment"
      helm delete catalog --purge

      # remove the OSBA deployment
       echo "Removing OSBA deployment"
      helm delete osba --purge
      helm delete osba-quickstart --purge
      kubectl delete namespace osba

      # delete the service principlan using the
      # predefined name i.d 'osba-sp'
      echo "Removing service principal"
      az ad sp delete --id http://osba-sp
}

# parse arguments
while (( "$#" )); do
    case "$1" in
    -h|--help)
      echo "osba.sh : OSBA Installer for ACS-Engine Kubernetes deployments."
      echo "Usage: ./osba.sh [options]"
      echo "options: "
      echo "    -r, --remove                    Remove OSBA installation."
      echo "    -h, --help                      Display this help message."
      exit 0
      ;;
    -r | --remove)
      echo "- Removing OSBA deployment"
      remove_osba_installation
      exit 0
      ;;
    \? )
      echo "Invalid Option: -$OPTARG" 1>&2
      exit 1
      ;;
  esac
done

echo "- Starting OSBA deployment..."

###
# extract and setup environmental variables
setup_env_vars

##
# Check version requirements

# verify kubectl exists
if ! [ -x "$(command -v kubectl)" ]; then
  echo 'Error: kubectl is not installed.' >&2
  install_kubectl
fi

# kubectl version check
KUBECLT_MAJOR_VERSION=$(kubectl version --insecure-skip-tls-verify=true --client -o json | jq  -r .clientVersion.major)
if [ $KUBECLT_MAJOR_VERSION != 1 ]; then
  echo "* Kubectl major version != 1 ... \n * installing compatible version ..."
  install_kubectl
fi

KUBECLT_MINOR_VERSION=$(kubectl version --insecure-skip-tls-verify=true --client -o json | jq  -r .clientVersion.minor)
if [ $KUBECLT_MINOR_VERSION -lt 9 ]; then
  echo "Kubectl minor version < 9 ...  \n * installing compatible version ..."
  install_kubectl
fi

# Verify Helm CLI exists
if ! [ -x "$(command -v helm)" ]; then
  echo 'Error: helm is not installed.' >&2
  install_helm
fi

# upgrade the Tiller component
helm init \
  --force-upgrade

# initialise Helm in client-only mode
helm init \
  --client-only

# setup service-catalog Helm repository
helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com

# update Helm repository
helm repo update

# install Service Catalog
# (https://svc-cat.io/docs/install)
helm install svc-cat/catalog \
    --name catalog \
    --namespace catalog \
    --set rbacEnable=true \
    --set apiserver.storage.etcd.persistence.enabled=true \
    --wait

# wait untill the deployment of svc-cat/catalog complete
kubectl rollout status deploy/catalog-catalog-apiserver --namespace=catalog -w
kubectl rollout status deploy/catalog-catalog-controller-manager --namespace=catalog -w

# verify 'svcat' CLI exists
if ! [ -x "$(command -v svcat)" ]; then
  echo 'Error: svcat is not installed.' >&2
  install_svcat
fi

# add azure repo in helm
helm repo add azure https://kubernetescharts.blob.core.windows.net/azure

#  deploy osba chart
helm install azure/open-service-broker-azure \
  --name osba \
  --namespace osba \
  --set azure.subscriptionId=$AZURE_SUBSCRIPTION_ID \
  --set azure.tenantId=$AZURE_TENANT_ID \
  --set azure.clientId=$AZURE_CLIENT_ID \
  --set azure.clientSecret=$AZURE_CLIENT_SECRET \
  --set modules.minStability=$OSBA_STABILITY \
  --version $OSBA_HELM_VERSION \
  --wait

# wait untill the deployment of azure/open-service-broker-azure complete
kubectl rollout status deploy/osba-open-service-broker-azure --namespace=osba -w
kubectl rollout status deploy/osba-redis --namespace=osba -w

echo "OSBA deployment completed! ... Enjoy!"
