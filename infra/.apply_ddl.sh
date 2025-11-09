#!/bin/sh
set -e
if [ ! -f /mnt/share/setup/script_db.sql ]; then
  echo "ERRO: /mnt/share/setup/script_db.sql não encontrado."; exit 1
fi
MYSQL_PWD="${MYSQL_ROOT_PASSWORD}" mysql -uroot "${MYSQL_DB}" < /mnt/share/setup/script_db.sql
echo "DDL aplicada."
