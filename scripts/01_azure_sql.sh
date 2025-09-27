#!/usr/bin/env bash
set -euo pipefail

RG="rg-motohub"
LOCATION="brazilsouth"
SQL_SERVER="sql-motohub-rm558883"
SQL_ADMIN_USER="admsql"
SQL_ADMIN_PASS="wVYE#5uZ6b"
SQL_DB="motohubdb"

az group create --name "$RG" --location "$LOCATION"

az sql server create \
  --name "$SQL_SERVER" \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --admin-user "$SQL_ADMIN_USER" \
  --admin-password "$SQL_ADMIN_PASS" \
  --enable-public-network true

az sql db create \
  --resource-group "$RG" \
  --server "$SQL_SERVER" \
  --name "$SQL_DB" \
  --service-objective Basic \
  --backup-storage-redundancy Local \
  --zone-redundant false

JDBC_URL="jdbc:sqlserver://$SQL_SERVER.database.windows.net:1433;database=$SQL_DB;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
echo
echo ">> Use estes valores como variáveis no App Service / CI:"
echo "SPRING_DATASOURCE_URL=$JDBC_URL"
echo "SPRING_DATASOURCE_USERNAME=$SQL_ADMIN_USER"
echo "SPRING_DATASOURCE_PASSWORD=$SQL_ADMIN_PASS"
