#!/usr/bin/env bash

# Esse script faz o build da imagem Docker da aplicação e faz o push para o ACR criado no passo anterior
# A imagem é construída localmente, então é necessário ter o Docker instalado e rodando

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
source "$HERE/variables.sh"

LOGIN_SERVER="$(az acr show --name "$ACR_NAME" --query loginServer -o tsv | tr -d '\r')"

echo ">> Login no ACR (docker login via admin creds)"
ACR_USER="$(az acr credential show --name "$ACR_NAME" --query username -o tsv | tr -d '\r')"
ACR_PASS="$(az acr credential show --name "$ACR_NAME" --query 'passwords[0].value' -o tsv | tr -d '\r')"

echo "Registry: ${LOGIN_SERVER}"

echo "$ACR_PASS" | docker login "$LOGIN_SERVER" --username "$ACR_USER" --password-stdin

echo ">> Build local (Dockerfile em ./app)"
docker build --pull -t "${APP_IMAGE_REPO}:${APP_IMAGE_TAG}" "$ROOT/app"

echo ">> Tag + push"
docker tag "${APP_IMAGE_REPO}:${APP_IMAGE_TAG}" "${LOGIN_SERVER}/${APP_IMAGE_REPO}:${APP_IMAGE_TAG}"
docker push "${LOGIN_SERVER}/${APP_IMAGE_REPO}:${APP_IMAGE_TAG}"

echo ">> OK: ${LOGIN_SERVER}/${APP_IMAGE_REPO}:${APP_IMAGE_TAG}"
