#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/variables.sh"

CG_NAME="motohub-$(printf '%s' "$AZ_RM" | tr '[:upper:]' '[:lower:]')"

FQDN="$(az container show -g "$AZ_RG" -n "$CG_NAME" --query 'ipAddress.fqdn' -o tsv | tr -d '\r')"
IP="$(az container show -g "$AZ_RG" -n "$CG_NAME" --query 'ipAddress.ip' -o tsv | tr -d '\r')"
PORT="${APP_PORT}"

echo "FQDN: ${FQDN}"
echo "IP:   ${IP}"
echo "PORT: ${PORT}"

if [ -n "$FQDN" ]; then
  echo "API URL (FQDN): http://${FQDN}:${PORT}"
fi
if [ -n "$IP" ]; then
  echo "API URL (IP):   http://${IP}:${PORT}"
fi
