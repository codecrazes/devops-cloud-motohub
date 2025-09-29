#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/variables.sh"

read -rp "Tem certeza que deseja deletar o Resource Group '$AZ_RG'? (digite YES): " CONFIRM
if [[ "${CONFIRM:-}" == "YES" ]]; then
  az group delete --name "$AZ_RG" --yes --no-wait
  echo ">> Deleção iniciada."
else
  echo ">> Abortado."
fi
