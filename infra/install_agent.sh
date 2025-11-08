#!/usr/bin/env bash
set -euo pipefail
[ "$(id -u)" -ne 0 ] || { echo "do not run as root"; exit 1; }
: "${AZP_URL:?}"
: "${AZP_TOKEN:?}"
: "${AZP_POOL:?}"
: "${AZP_AGENT_NAME:?}"
AGENT_DIR="$HOME/azdo-agent"
PKG_VER="4.263.0"
PKG_NAME="vsts-agent-linux-x64-${PKG_VER}.tar.gz"
PKG_URL="https://download.agent.dev.azure.com/agent/${PKG_VER}/${PKG_NAME}"
sudo apt-get update -y
sudo apt-get install -y curl wget tar git jq ca-certificates openssl krb5-user zlib1g
mkdir -p "${AGENT_DIR}"
cd "${AGENT_DIR}"
rm -f "${PKG_NAME}"
wget -q "${PKG_URL}" -O "${PKG_NAME}"
tar xzf "${PKG_NAME}" -C "${AGENT_DIR}"
rm -f "${PKG_NAME}"
sudo ./bin/installdependencies.sh
./config.sh --unattended --url "${AZP_URL}" --auth pat --token "${AZP_TOKEN}" --pool "${AZP_POOL}" --agent "${AZP_AGENT_NAME}" --acceptTeeEula --work "_work" --replace
if sudo ./svc.sh install && sudo ./svc.sh start; then
  :
else
  nohup ./run.sh >/var/log/azdo-agent.log 2>&1 &
fi
