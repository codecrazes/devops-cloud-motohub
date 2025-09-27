#!/usr/bin/env bash
set -euo pipefail

RG="rg-motohub"
APP_SERVICE_PLAN="plan-motohub"
WEBAPP_NAME="motohub-app-rm558883"
RUNTIME="JAVA:17-java17"

az webapp create \
  --name "$WEBAPP_NAME" \
  --resource-group "$RG" \
  --plan "$APP_SERVICE_PLAN" \
  --runtime "$RUNTIME"

az resource update \
  --resource-group "$RG" \
  --namespace Microsoft.Web \
  --resource-type basicPublishingCredentialsPolicies \
  --name scm \
  --parent "sites/$WEBAPP_NAME" \
  --set properties.allow=true 1>/dev/null

echo "URL: https://$WEBAPP_NAME.azurewebsites.net"
