#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/variables.sh"

# ---- Segredos do storage (para volume opcional) ----
if [[ ! -f "$HERE/.storage_secrets" ]]; then
  echo "Faltando $HERE/.storage_secrets. Rode 02_storage.sh primeiro." >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$HERE/.storage_secrets"

# ---- Derivações e variáveis que PRECISAM existir antes de usar ----
LOGIN_SERVER="$(az acr show --name "$ACR_NAME" --query loginServer -o tsv | tr -d '\r')"
ACR_USER="$(az acr credential show --name "$ACR_NAME" --query username -o tsv | tr -d '\r')"
ACR_PASS="$(az acr credential show --name "$ACR_NAME" --query 'passwords[0].value' -o tsv | tr -d '\r')"

AZ_RM_LC="$(printf '%s' "${AZ_RM}" | tr '[:upper:]' '[:lower:]')"
CG_NAME="motohub-${AZ_RM_LC}"                # <<<< DEFINA AQUI ANTES DE USAR

export AZ_LOCATION AZ_RG AZ_RM AZ_RM_LC CG_NAME \
       MYSQL_IMAGE MYSQL_DB MYSQL_ROOT_PASSWORD MYSQL_APP_USER MYSQL_APP_PASSWORD \
       FILESHARE_NAME STG_NAME STG_KEY \
       APP_IMAGE_REPO APP_IMAGE_TAG APP_PORT \
       SPRING_DATASOURCE_URL SPRING_DATASOURCE_USERNAME SPRING_DATASOURCE_PASSWORD \
       ACR_LOGIN_SERVER="$LOGIN_SERVER" ACR_USERNAME="$ACR_USER" ACR_PASSWORD="$ACR_PASS"

# ---- Renderiza o YAML ----
TEMPLATE="$HERE/mysql_aci.yaml"
TMP_YAML="$HERE/mysql_aci_rendered.yaml"
envsubst < "$TEMPLATE" > "$TMP_YAML"

echo ">> Deploy do Container Group (API + MySQL) ..."

# Remove se já existir (evita DNS label em uso / zumbi)
if az container show -g "$AZ_RG" -n "$CG_NAME" >/dev/null 2>&1; then
  echo ">> Container group já existe, removendo..."
  az container delete -g "$AZ_RG" -n "$CG_NAME" --yes --wait || true
fi


# Cria sem bloquear o CLI
az container create --resource-group "$AZ_RG" --file "$TMP_YAML" --no-wait

# Aguarda o recurso "aparecer" no ARM
echo ">> Aguardando o recurso ser criado no ARM..."
for i in {1..60}; do
  if az container show -g "$AZ_RG" -n "$CG_NAME" --query "provisioningState" -o tsv >/dev/null 2>&1; then
    break
  fi
  printf "."
  sleep 3
done
echo

# Polling com estados e eventos
for i in {1..120}; do
  PS="$(az container show -g "$AZ_RG" -n "$CG_NAME" --query 'provisioningState' -o tsv 2>/dev/null || true)"
  ST="$(az container show -g "$AZ_RG" -n "$CG_NAME" --query 'instanceView.state' -o tsv 2>/dev/null || true)"
  echo "   -> provisioningState=${PS:-?} | instanceView.state=${ST:-?}"

  az container show -g "$AZ_RG" -n "$CG_NAME" \
    --query "containers[].{name:name,state:instanceView.currentState.state,detail:instanceView.currentState.detailStatus}" -o table || true

  if [[ "$PS" == "Failed" ]]; then
    echo ">> Eventos do grupo (falha no provisionamento):"
    az container show -g "$AZ_RG" -n "$CG_NAME" --query "containers[].instanceView.events" -o jsonc || true
    exit 1
  fi

  if [[ "$PS" == "Succeeded" || "$ST" == "Running" ]]; then
    break
  fi
  sleep 5
done

echo ">> Status:"
az container show -g "$AZ_RG" -n "$CG_NAME" \
  --query "{state:instanceView.state,fqdn:ipAddress.fqdn,ip:ipAddress.ip}" -o table

echo ">> Estados dos containers:"
az container show -g "$AZ_RG" -n "$CG_NAME" \
  --query "containers[].{name:name,state:instanceView.currentState.state,detail:instanceView.currentState.detailStatus,startTime:instanceView.currentState.startTime}" -o table

echo ">> Eventos do container motohub-api:"
az container show -g "$AZ_RG" -n "$CG_NAME" \
  --query "containers[?name=='motohub-api'].instanceView.events[]" -o jsonc || true
