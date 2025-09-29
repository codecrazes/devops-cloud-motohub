#!/usr/bin/env bash
set -euo pipefail

req() {
  local ns="$1"
  local state
  state="$(az provider show --namespace "$ns" --query registrationState -o tsv 2>/dev/null || echo "NotRegistered")"
  echo ">> $ns: $state"
  if [[ "$state" != "Registered" ]]; then
    echo ">> Registrando $ns ..."
    az provider register --namespace "$ns" -o none || true
  fi
}

wait_registered() {
  local ns="$1"
  echo ">> Aguardando registro de $ns ..."
  for i in {1..30}; do
    state="$(az provider show --namespace "$ns" --query registrationState -o tsv 2>/dev/null || echo "NotRegistered")"
    if [[ "$state" == "Registered" ]]; then
      echo ">> $ns: Registered"
      return 0
    fi
    sleep 5
  done
  echo "⚠️  Tempo esgotado aguardando $ns (estado atual: $state). Tente novamente mais tarde." >&2
  return 1
}

echo "== Assinatura atual =="
az account show --query "{name:name, id:id}" -o table

req "Microsoft.ContainerInstance"
req "Microsoft.ContainerRegistry"
req "Microsoft.Storage"
req "Microsoft.Network"

wait_registered "Microsoft.ContainerInstance"
