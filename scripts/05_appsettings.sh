set -euo pipefail

RG="rg-motohub"
WEBAPP_NAME="motohub-app-rm558883"
SQL_SERVER="sql-motohub-rm558883"
SQL_DB="motohubdb"

SPRING_DATASOURCE_URL="jdbc:sqlserver://$SQL_SERVER.database.windows.net:1433;database=$SQL_DB;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"

SPRING_DATASOURCE_USERNAME="admsql"
SPRING_DATASOURCE_PASSWORD="wVYE#5uZ6b"

az webapp config appsettings set \
  --name "$WEBAPP_NAME" \
  --resource-group "$RG" \
  --settings \
    SPRING_DATASOURCE_URL="$SPRING_DATASOURCE_URL" \
    SPRING_DATASOURCE_USERNAME="$SPRING_DATASOURCE_USERNAME" \
    SPRING_DATASOURCE_PASSWORD="$SPRING_DATASOURCE_PASSWORD" \
    WEBSITES_PORT="8080" \
    JAVA_OPTS="-Xms256m -Xmx512m"

echo "App settings aplicados."
