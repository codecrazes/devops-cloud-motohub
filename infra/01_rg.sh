#!/usr/bin/env bash

# Esse script cria o Resource Group usado pelos outros scripts para criação dos recursos, 
# caso queira apagar o resource group use o script ./infra/teardown.sh

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HERE/variables.sh"

az group create --name "$AZ_RG" --location "$AZ_LOCATION" -o table
