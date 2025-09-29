#!/usr/bin/env bash
set -euo pipefail

API_BASE="http://SEU_FQDN_OU_IP:8080"
PATH_INTENCOES="/intencoes"

CREATE_BODY='{
  "clienteId": 1,
  "motoId": 1,
  "tipo": "ALUGUEL",
  "descricao": "Intenção de locação mensal",
  "status": "ABERTA"
}'

UPDATE_BODY='{
  "clienteId": 1,
  "motoId": 1,
  "tipo": "ALUGUEL",
  "descricao": "Intenção ATUALIZADA",
  "status": "FECHADA"
}'

INTENCAO_ID="${INTENCAO_ID:-}"

has_jq() { command -v jq >/dev/null 2>&1; }

sep() { echo -e "\n============================================\n"; }

echo "== GET lista =="
if has_jq; then
  curl -s "${API_BASE}${PATH_INTENCOES}" | jq . || true
else
  curl -s "${API_BASE}${PATH_INTENCOES}" || true
fi
sep

echo "== POST cria =="
POST_RES="$(curl -s -X POST "${API_BASE}${PATH_INTENCOES}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "${CREATE_BODY}")"

echo "${POST_RES}" | (has_jq && jq . || cat)
sep

if [[ -z "$INTENCAO_ID" ]]; then
  if has_jq; then
    INTENCAO_ID="$(echo "${POST_RES}" | jq -r '.id // .data.id // empty')"
  fi
fi

if [[ -z "$INTENCAO_ID" ]]; then
  echo "⚠️  Não foi possível detectar o ID automaticamente."
  echo "    Se sua API não retorna JSON com 'id' no POST, defina manualmente:"
  echo "    export INTENCAO_ID=<id_gerado>"
  echo "    e re-execute a partir do GET por ID."
else
  echo "➡️  ID detectado: ${INTENCAO_ID}"

  echo "== GET por ID =="
  if has_jq; then
    curl -s "${API_BASE}${PATH_INTENCOES}/${INTENCAO_ID}" | jq . || true
  else
    curl -s "${API_BASE}${PATH_INTENCOES}/${INTENCAO_ID}" || true
  fi
  sep

  echo "== PUT atualiza =="
  PUT_RES="$(curl -s -X PUT "${API_BASE}${PATH_INTENCOES}/${INTENCAO_ID}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d "${UPDATE_BODY}")"
  echo "${PUT_RES}" | (has_jq && jq . || cat)
  sep

  echo "== DELETE =="
  DEL_RES="$(curl -s -X DELETE "${API_BASE}${PATH_INTENCOES}/${INTENCAO_ID}" \
    -H "Accept: application/json" )"
  echo "${DEL_RES}" | (has_jq && jq . || cat)
  sep
fi

echo "== GET lista (final) =="
if has_jq; then
  curl -s "${API_BASE}${PATH_INTENCOES}" | jq . || true
else
  curl -s "${API_BASE}${PATH_INTENCOES}" || true
fi
echo
