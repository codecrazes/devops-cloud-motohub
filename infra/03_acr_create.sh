#!/usr/bin/env bash

# Esse script cria o Azure Container Registry (ACR) usado para armazenar as imagens Docker da aplicação

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/variables.sh"

az provider register --namespace Microsoft.ContainerRegistry >/dev/null 2>&1 || true

az acr create \
  --resource-group "$AZ_RG" \
  --name "$ACR_NAME" \
  --sku Standard \
  --location "$AZ_LOCATION" \
  --admin-enabled true \
  -o table

echo ">> Login Server:"
az acr show --name "$ACR_NAME" --query loginServer -o tsv
