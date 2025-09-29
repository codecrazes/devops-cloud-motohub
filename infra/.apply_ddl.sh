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
