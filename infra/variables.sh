#!/usr/bin/env bash

# Esse script carrega as variáveis de ambiente do arquivo .env e as imprime no console.

set -euo pipefail

ENV_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Arquivo .env não encontrado em infra/.env. Copie de .env.example e ajuste." >&2
  exit 1
fi
source "$ENV_FILE"

print_var() { printf "%-20s %s\n" "$1" "${2:-}"; }

echo ">> Variáveis carregadas:"
print_var "RG"                   "${AZ_RG:-}"
print_var "Location"            "${AZ_LOCATION:-}"
print_var "RM"                  "${AZ_RM:-}"
print_var "ACR"                 "${ACR_NAME:-}"
print_var "Storage"             "${STG_NAME:-}"
print_var "FileShare"           "${FILESHARE_NAME:-}"
print_var "MySQL Image"         "${MYSQL_IMAGE:-}"
print_var "MySQL DB"            "${MYSQL_DB:-}"
print_var "App Image Repo"      "${APP_IMAGE_REPO:-}"
print_var "App Image Tag"       "${APP_IMAGE_TAG:-}"
print_var "App Port"            "${APP_PORT:-}"
