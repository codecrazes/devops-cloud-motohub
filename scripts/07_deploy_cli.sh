#!/usr/bin/env bash
set -euo pipefail

RG="rg-motohub"
WEBAPP_NAME="motohub-app-rm558883"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
API_DIR="${ROOT_DIR}/java-api"

if [[ -x "${API_DIR}/mvnw" ]]; then
  MVN="${API_DIR}/mvnw"
else
  MVN="mvn"
fi

echo ">> Buildando projeto em ${API_DIR} ..."
"${MVN}" -f "${API_DIR}/pom.xml" -q -DskipTests package

JAR_FILE="$(ls -1 "${API_DIR}"/target/*.jar | head -n 1 || true)"
if [[ -z "${JAR_FILE}" ]]; then
  echo "ERRO: Nenhum JAR encontrado em ${API_DIR}/target"
  exit 1
fi
echo ">> JAR encontrado: ${JAR_FILE}"

az webapp config set \
  --resource-group "${RG}" \
  --name "${WEBAPP_NAME}" \
  --startup-file "" >/dev/null

az webapp update \
  --resource-group "${RG}" \
  --name "${WEBAPP_NAME}" \
  --set siteConfig.linuxFxVersion="JAVA|17" >/dev/null

az webapp config appsettings set \
  --resource-group "${RG}" \
  --name "${WEBAPP_NAME}" \
  --settings WEBSITES_PORT="8080" >/dev/null

echo ">> Realizando deploy do JAR no App Service..."
az webapp deploy \
  --resource-group "${RG}" \
  --name "${WEBAPP_NAME}" \
  --type jar \
  --src-path "${JAR_FILE}"

echo "OK! Abra: https://${WEBAPP_NAME}.azurewebsites.net"
echo "Logs em tempo real:"
az webapp log tail -g "${RG}" -n "${WEBAPP_NAME}"
