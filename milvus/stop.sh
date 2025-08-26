#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

FORCE="${1:-}"

if command -v docker compose >/dev/null 2>&1; then
  DC="docker compose -f milvus_docker-compose.yml"
else
  DC="docker-compose -f milvus_docker-compose.yml"
fi

if [[ "$FORCE" == "--force" ]]; then
  $DC down -v
else
  $DC down
fi


