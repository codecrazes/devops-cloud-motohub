#!/usr/bin/env bash
set -euo pipefail

RG="rg-motohub"
LOCATION="brazilsouth"
APP_SERVICE_PLAN="plan-motohub"
SUBSCRIPTION="3aa67849-5f49-449a-bd97-b08b65aff32c"

if [[ -n "${SUBSCRIPTION}" ]]; then
  az account set --subscription "${SUBSCRIPTION}"
fi

providers=(Microsoft.Web Microsoft.Insights Microsoft.OperationalInsights Microsoft.ServiceLinker Microsoft.Sql)

for p in "${providers[@]}"; do
  echo "Registrando provider $p..."
  az provider register -n "$p" >/dev/null || true
  for i in {1..30}; do
    state=$(az provider show -n "$p" --query registrationState -o tsv 2>/dev/null || echo "")
    if [[ "$state" == "Registered" ]]; then
      echo "$p: $state"
      break
    fi
    sleep 5
  done
done

az appservice plan create \
  --name "$APP_SERVICE_PLAN" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --sku F1 \
  --is-linux
