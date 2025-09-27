#!/usr/bin/env bash
set -euo pipefail
RG="rg-motohub"
SQL_SERVER="sql-motohub-rm558883"
WEBAPP_NAME="motohub-app-rm558883"

OUT_NOW=$(az webapp show -g "$RG" -n "$WEBAPP_NAME" --query outboundIpAddresses -o tsv | tr ',' '\n' | sort -u)
OUT_POSSIBLE=$(az webapp show -g "$RG" -n "$WEBAPP_NAME" --query possibleOutboundIpAddresses -o tsv | tr ',' '\n' | sort -u)
IPS=$(printf "%s\n%s\n" "$OUT_NOW" "$OUT_POSSIBLE" | sort -u)

i=1
for ip in $IPS; do
  RULE="appsvc-$i"
  echo "Criando regra $RULE para $ip"
  az sql server firewall-rule create \
    --resource-group "$RG" --server "$SQL_SERVER" \
    --name "$RULE" \
    --start-ip-address "$ip" \
    --end-ip-address "$ip" 1>/dev/null
  i=$((i+1))
done

echo "Regras criadas para IPs do Web App. Reexecute se mudar plano/slot."
