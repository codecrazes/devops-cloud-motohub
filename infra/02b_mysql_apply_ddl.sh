#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

source "$HERE/variables.sh"

# Segredos do storage
if [[ ! -f "$HERE/.storage_secrets" ]]; then
  echo "Faltando $HERE/.storage_secrets. Rode 02_storage.sh primeiro." >&2
  exit 1
fi
# shellcheck disable=SC1090
source "$HERE/.storage_secrets"

SQL_LOCAL="$ROOT/script_db.sql"
DIR_REMOTE="setup"
SQL_REMOTE_PATH="${DIR_REMOTE}/script_db.sql"
WRAPPER_LOCAL="$HERE/.apply_ddl.sh"
WRAPPER_REMOTE_PATH="${DIR_REMOTE}/apply_ddl.sh"
SQL_IN_CONTAINER="/mnt/share/${SQL_REMOTE_PATH}"
WRAPPER_IN_CONTAINER="/mnt/share/${WRAPPER_REMOTE_PATH}"
CG_NAME="motohub-$(printf '%s' "$AZ_RM" | tr '[:upper:]' '[:lower:]')"

echo ">> Variáveis carregadas:"
printf "RG %20s\nLocation %13s\nRM %17s\nStorage %15s\nFileShare %11s\nMySQL DB %14s\n" \
  "$AZ_RG" "$AZ_LOCATION" "$AZ_RM" "$STG_NAME" "$FILESHARE_NAME" "$MYSQL_DB"

if [[ ! -f "$SQL_LOCAL" ]]; then
  echo "Arquivo $SQL_LOCAL não encontrado. Crie/ajuste seu script_db.sql." >&2
  exit 1
fi

# 1) Wrapper que roda dentro do container (sem aspas complicadas)
cat > "$WRAPPER_LOCAL" <<'SH'
#!/bin/sh
set -e
if [ ! -f /mnt/share/setup/script_db.sql ]; then
  echo "ERRO: /mnt/share/setup/script_db.sql não encontrado."
  exit 1
fi
echo ">> Aplicando DDL em ${MYSQL_DB} ..."
# Usa MYSQL_PWD para não expor senha no ps
MYSQL_PWD="${MYSQL_ROOT_PASSWORD}" mysql -uroot "${MYSQL_DB}" < /mnt/share/setup/script_db.sql
echo ">> OK: DDL aplicada."
SH

echo ">> Garantindo diretório '${DIR_REMOTE}' no File Share ${FILESHARE_NAME}..."
az storage directory create \
  --account-name "$STG_NAME" \
  --account-key "$STG_KEY" \
  --share-name "$FILESHARE_NAME" \
  --name "$DIR_REMOTE" -o table || true

echo ">> Enviando script_db.sql para ${FILESHARE_NAME}/${SQL_REMOTE_PATH}..."
az storage file upload \
  --account-name "$STG_NAME" \
  --account-key "$STG_KEY" \
  --share-name "$FILESHARE_NAME" \
  --source "$SQL_LOCAL" \
  --path "$SQL_REMOTE_PATH" -o table

echo ">> Enviando apply_ddl.sh para ${FILESHARE_NAME}/${WRAPPER_REMOTE_PATH}..."
az storage file upload \
  --account-name "$STG_NAME" \
  --account-key "$STG_KEY" \
  --share-name "$FILESHARE_NAME" \
  --source "$WRAPPER_LOCAL" \
  --path "$WRAPPER_REMOTE_PATH" -o table

echo ">> Aguardando MySQL ficar Running..."
for i in {1..60}; do
  state="$(az container show -g "$AZ_RG" -n "$CG_NAME" \
    --query "containers[?name=='mysql'].instanceView.currentState.state" -o tsv 2>/dev/null || true)"
  [ "$state" = "Running" ] && break
  sleep 3
done

echo ">> Conferindo arquivos no container..."
az container exec -g "$AZ_RG" -n "$CG_NAME" --container-name "mysql" \
  --exec-command "/bin/ls -l /mnt/share/${DIR_REMOTE}"

echo ">> Executando wrapper de DDL..."
if ! az container exec -g "$AZ_RG" -n "$CG_NAME" --container-name "mysql" \
  --exec-command "/bin/sh /mnt/share/${WRAPPER_REMOTE_PATH}"; then
  echo "ERRO: Execução do DDL falhou." >&2
  exit 1
fi

echo ">> DDL aplicada com sucesso."
