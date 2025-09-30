#!/usr/bin/env sh
set -e

HOST="${DB_HOST:-127.0.0.1}"
PORT="${DB_PORT:-3306}"
TIMEOUT="${DB_WAIT_TIMEOUT:-120}" # segundos

echo "Starting Motohub as UID=$(id -u), GID=$(id -g)"
echo "Waiting for MySQL at ${HOST}:${PORT} (timeout ${TIMEOUT}s)..."

i=0
# ping sem credenciais e forçando protocolo TCP (independe do usuário existir)
until mysqladmin ping --protocol=tcp -h"${HOST}" -P"${PORT}" --silent >/dev/null 2>&1; do
  i=$((i+1))
  if [ "$i" -ge "$TIMEOUT" ]; then
    echo "MySQL não respondeu em ${TIMEOUT}s. Abortando."
    exit 1
  fi
  sleep 1
done

echo "MySQL disponível. Subindo a aplicação..."
echo "Java opts: '${JAVA_OPTS}' | Server port: '${APP_PORT}'"

exec java $JAVA_OPTS -jar /app/app.jar --server.port="${APP_PORT}"
