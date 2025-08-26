#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

dirs=(
  oceanbase-data oceanbase-conf oceanbase-backup
  ocp-mysql-data ocp-mysql-init ocp-mysql-conf ocp-mysql-backup
  ocp-redis-data ocp-redis-conf ocp-redis-backup
  ocp-data ocp-logs ocp-config ocp-backup
  prometheus-data prometheus-config
  loki-data loki-config
  grafana-data grafana-provisioning grafana-dashboards
)

for d in "${dirs[@]}"; do
  mkdir -p "$d"
done

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed." >&2; exit 1
fi
if ! docker compose version >/dev/null 2>&1 && ! docker-compose version >/dev/null 2>&1; then
  echo "Docker Compose is not installed." >&2; exit 1
fi

if command -v docker compose >/dev/null 2>&1; then
  docker compose -f oceanbase_docker-compose.yml up -d
else
  docker-compose -f oceanbase_docker-compose.yml up -d
fi

echo "Waiting a few seconds for containers to warm up..."
sleep 5

if command -v docker compose >/dev/null 2>&1; then
  docker compose -f oceanbase_docker-compose.yml ps
else
  docker-compose -f oceanbase_docker-compose.yml ps
fi

echo "Started. OCP: http://localhost:8080  Grafana: http://localhost:3000  Prometheus: http://localhost:9091"


