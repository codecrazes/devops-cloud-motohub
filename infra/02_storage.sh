#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/variables.sh"

echo ">> Criando Storage Account..."
az storage account create \
  --name "$STG_NAME" \
  --resource-group "$AZ_RG" \
  --location "$AZ_LOCATION" \
  --sku "$STG_SKU" \
  -o table

echo ">> Obtendo a chave da Storage..."
STG_KEY="$(az storage account keys list -g "$AZ_RG" -n "$STG_NAME" --query '[0].value' -o tsv)"

echo ">> Criando File Share $FILESHARE_NAME ..."
az storage share-rm create \
  --resource-group "$AZ_RG" \
  --storage-account "$STG_NAME" \
  --name "$FILESHARE_NAME" \
  -o table

EXPIRY="$(date -u -d '+30 days' '+%Y-%m-%dT%H:%MZ' 2>/dev/null || date -v+30d -u '+%Y-%m-%dT%H:%MZ')"
SAS_TOKEN="$(az storage share generate-sas \
  --account-name "$STG_NAME" \
  --name "$FILESHARE_NAME" \
  --permissions rwld \
  --expiry "$EXPIRY" \
  --https-only \
  --account-key "$STG_KEY" \
  -o tsv)"

echo "STG_KEY=\"$STG_KEY\"" > "$HERE/.storage_secrets"
echo "SAS_TOKEN=\"$SAS_TOKEN\"" >> "$HERE/.storage_secrets"
echo "EXPIRY=\"$EXPIRY\"" >> "$HERE/.storage_secrets"

echo ">> Storage pronto. Segredos salvos em infra/.storage_secrets"
