#!/usr/bin/env bash
set -euo pipefail
AZ_RG="${AZ_RG:?}"
STG_NAME="${STG_NAME:?}"
FILESHARE_NAME="${FILESHARE_NAME:?}"
MYSQL_ACI_NAME="${MYSQL_ACI_NAME:?}"
MYSQL_DB="${MYSQL_DB:?}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:?}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
SQL_LOCAL="${SQL_LOCAL:-$ROOT/script_db.sql}"
DIR_REMOTE="setup"
SQL_REMOTE_PATH="${DIR_REMOTE}/script_db.sql"
WRAPPER_LOCAL="$HERE/.apply_ddl.sh"
WRAPPER_REMOTE_PATH="${DIR_REMOTE}/apply_ddl.sh"
if [ ! -f "$SQL_LOCAL" ]; then
  echo "Arquivo $SQL_LOCAL não encontrado"; exit 1
fi
STG_KEY="$(az storage account keys list -g "$AZ_RG" -n "$STG_NAME" --query '[0].value' -o tsv)"
cat > "$WRAPPER_LOCAL" <<'SH'
#!/bin/sh
set -e
if [ ! -f /mnt/share/setup/script_db.sql ]; then
  echo "ERRO: /mnt/share/setup/script_db.sql não encontrado."; exit 1
fi
MYSQL_PWD="${MYSQL_ROOT_PASSWORD}" mysql -uroot "${MYSQL_DB}" < /mnt/share/setup/script_db.sql
echo "DDL aplicada."
SH
az storage directory create --account-name "$STG_NAME" --account-key "$STG_KEY" --share-name "$FILESHARE_NAME" --name "$DIR_REMOTE" -o none || true
az storage file upload --account-name "$STG_NAME" --account-key "$STG_KEY" --share-name "$FILESHARE_NAME" --source "$SQL_LOCAL" --path "$SQL_REMOTE_PATH" -o none
az storage file upload --account-name "$STG_NAME" --account-key "$STG_KEY" --share-name "$FILESHARE_NAME" --source "$WRAPPER_LOCAL" --path "$WRAPPER_REMOTE_PATH" -o none
for i in $(seq 1 60); do
  st="$(az container show -g "$AZ_RG" -n "$MYSQL_ACI_NAME" --query "containers[?name=='mysql'].instanceView.currentState.state" -o tsv || true)"
  [ "$st" = "Running" ] && break
  sleep 3
done
az container exec -g "$AZ_RG" -n "$MYSQL_ACI_NAME" --container-name "mysql" --exec-command "/bin/ls -l /mnt/share/${DIR_REMOTE}"
az container exec -g "$AZ_RG" -n "$MYSQL_ACI_NAME" --container-name "mysql" --exec-command "/bin/sh /mnt/share/${WRAPPER_REMOTE_PATH}"
