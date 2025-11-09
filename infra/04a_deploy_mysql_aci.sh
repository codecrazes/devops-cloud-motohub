#!/usr/bin/env bash
set -euo pipefail
AZ_RG="${AZ_RG:?}"
AZ_LOCATION="${AZ_LOCATION:?}"
STG_NAME="${STG_NAME:?}"
STG_SKU="${STG_SKU:?}"
FILESHARE_NAME="${FILESHARE_NAME:?}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:?}"
MYSQL_DB="${MYSQL_DB:?}"
MYSQL_USER="${MYSQL_USER:?}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:?}"
MYSQL_ACI_NAME="${MYSQL_ACI_NAME:?}"
MYSQL_DNS_LABEL="${MYSQL_DNS_LABEL:?}"
ACR_NAME="${ACR_NAME:?}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$HERE/mysql_aci.yaml"
RENDERED="$HERE/.mysql_aci_rendered.yaml"
az group create -n "$AZ_RG" -l "$AZ_LOCATION" -o none
az storage account create -g "$AZ_RG" -n "$STG_NAME" -l "$AZ_LOCATION" --sku "$STG_SKU" -o none
STG_KEY="$(az storage account keys list -g "$AZ_RG" -n "$STG_NAME" --query "[0].value" -o tsv)"
az storage share-rm create --resource-group "$AZ_RG" --storage-account "$STG_NAME" --name "$FILESHARE_NAME" -o none
ACR_LOGIN_SERVER="$(az acr show -n "$ACR_NAME" --query loginServer -o tsv)"
az acr update -n "$ACR_NAME" --admin-enabled true -o none
if ! az acr repository show-tags -n "$ACR_NAME" --repository mysql --query "[?@=='8.0']" -o tsv | grep -q "8.0"; then
  az acr import -n "$ACR_NAME" --source docker.io/library/mysql:8.0 --image mysql:8.0 -o none
fi
ACR_USERNAME="$(az acr credential show -n "$ACR_NAME" --query username -o tsv)"
ACR_PASSWORD="$(az acr credential show -n "$ACR_NAME" --query 'passwords[0].value' -o tsv)"
export AZ_LOCATION STG_NAME STG_KEY FILESHARE_NAME MYSQL_IMAGE="$ACR_LOGIN_SERVER/mysql:8.0" MYSQL_ROOT_PASSWORD MYSQL_DB MYSQL_USER MYSQL_PASSWORD MYSQL_ACI_NAME MYSQL_DNS_LABEL ACR_LOGIN_SERVER ACR_USERNAME ACR_PASSWORD
envsubst < "$TEMPLATE" > "$RENDERED"
if az container show -g "$AZ_RG" -n "$MYSQL_ACI_NAME" >/dev/null 2>&1; then
  az container delete -g "$AZ_RG" -n "$MYSQL_ACI_NAME" --yes --wait
fi
az container create --resource-group "$AZ_RG" --file "$RENDERED" -o none
for i in $(seq 1 60); do
  ps="$(az container show -g "$AZ_RG" -n "$MYSQL_ACI_NAME" --query "provisioningState" -o tsv || echo Unknown)"
  st="$(az container show -g "$AZ_RG" -n "$MYSQL_ACI_NAME" --query "instanceView.state" -o tsv || echo Unknown)"
  [ "$ps" = "Succeeded" ] && [ "$st" = "Running" ] && break
  sleep 5
done
FQDN="$(az container show -g "$AZ_RG" -n "$MYSQL_ACI_NAME" --query "ipAddress.fqdn" -o tsv)"
IP="$(az container show -g "$AZ_RG" -n "$MYSQL_ACI_NAME" --query "ipAddress.ip" -o tsv)"
echo "MYSQL_ACI_FQDN=$FQDN"
echo "MYSQL_ACI_IP=$IP"
