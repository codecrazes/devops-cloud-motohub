#!/usr/bin/env bash
set -euo pipefail
RG="rg-motohub"
SQL_SERVER="sql-motohub-rm558883"
RULE_NAME="dev-luis"
MY_IP="$(curl -s https://ifconfig.me || dig +short myip.opendns.com @resolver1.opendns.com)"
[ -z "$MY_IP" ] && { echo "Falha ao descobrir IP público"; exit 1; }
echo "Liberando $MY_IP para $SQL_SERVER ..."
az sql server firewall-rule create \
  --resource-group "$RG" --server "$SQL_SERVER" \
  --name "$RULE_NAME" \
  --start-ip-address "$MY_IP" \
  --end-ip-address "$MY_IP"
