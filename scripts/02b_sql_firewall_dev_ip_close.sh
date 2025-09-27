#!/usr/bin/env bash
set -euo pipefail
RG="rg-motohub"
SQL_SERVER="sql-motohub-rm558883"
RULE_NAME="dev-luis"
echo "Removendo regra $RULE_NAME ..."
az sql server firewall-rule delete \
  --resource-group "$RG" --server "$SQL_SERVER" \
  --name "$RULE_NAME" 
