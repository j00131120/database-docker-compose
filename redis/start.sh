#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

mkdir -p data logs

if command -v docker compose >/dev/null 2>&1; then
  docker compose -f redis_docker-compose.yml up -d
else
  docker-compose -f redis_docker-compose.yml up -d
fi

if command -v docker compose >/dev/null 2>&1; then
  docker compose -f redis_docker-compose.yml ps
else
  docker-compose -f redis_docker-compose.yml ps
fi


