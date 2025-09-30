#!/usr/bin/env bash
set -euo pipefail

API_BASE="http://SEU_FQDN_OU_IP:8080"

echo "== GET lista =="
curl -s "${API_BASE}/motos" || true
echo

echo "== POST cria (ajuste campos conforme seu modelo) =="
curl -s -X POST "${API_BASE}/motos" \
  -H "Content-Type: application/json" \
  -d '{"placa":"ABC1D23","modelo":"CG 160","ano":2023,"status":"DISPONIVEL"}' \
  | jq .
echo

echo "== GET lista (depois do POST) =="
curl -s "${API_BASE}/motos" | jq .
echo

echo "== PUT atualiza (ajuste ID) =="
curl -s -X PUT "${API_BASE}/motos/1" \
  -H "Content-Type: application/json" \
  -d '{"placa":"ABC1D23","modelo":"CG 160","ano":2023,"status":"MANUTENCAO"}' \
  | jq .
echo

echo "== DELETE (ajuste ID) =="
curl -s -X DELETE "${API_BASE}/motos/1" | jq .
echo
