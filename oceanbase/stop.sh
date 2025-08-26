#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

FORCE="${1:-}"

if command -v docker compose >/dev/null 2>&1; then
  DC="docker compose -f oceanbase_docker-compose.yml"
else
  DC="docker-compose -f oceanbase_docker-compose.yml"
fi

if [[ "$FORCE" == "--force" ]]; then
  $DC down -v
  echo "Removed containers and volumes."
else
  $DC down
  echo "Stopped containers. Use --force to also remove volumes."
fi


