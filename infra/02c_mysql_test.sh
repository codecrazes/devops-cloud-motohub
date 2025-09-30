#!/usr/bin/env bash

# Esse script testa a conexão com o banco MySQL rodando no ACI, e lista as tabelas do banco.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/variables.sh"

CG_NAME="motohub-${AZ_RM,,}"

echo ">> Teste: SELECT 1"
az container exec \
  --resource-group "$AZ_RG" \
  --name "$CG_NAME" \
  --container-name "mysql" \
  --exec-command "/bin/sh -lc 'mysql -uroot -p\"${MYSQL_ROOT_PASSWORD}\" -e \"SELECT 1\"'"

echo ">> Tabelas no banco ${MYSQL_DB}:"
az container exec \
  --resource-group "$AZ_RG" \
  --name "$CG_NAME" \
  --container-name "mysql" \
  --exec-command "/bin/sh -lc 'mysql -uroot -p\"${MYSQL_ROOT_PASSWORD}\" -D ${MYSQL_DB} -e \"SHOW TABLES\"'"
