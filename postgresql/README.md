# PostgreSQL Docker Compose Project

## Quick Start

### 0. Configure environment
```bash
cp env.template .env
# edit .env for ports/passwords
```

### 1. Start services (scripts supported)
```bash
chmod +x start.sh stop.sh
./start.sh
# or
docker compose -f postgres_docker-compose.yml up -d
```

### 2. Access
- Postgres: localhost:${POSTGRES_PORT:-5432}, user `${POSTGRES_USER:-postgres}`, pass `${POSTGRES_PASSWORD:-postgres}`

### 3. Stop services
```bash
./stop.sh
# or
docker compose -f postgres_docker-compose.yml down
```

## Files
- `postgres_docker-compose.yml`
- `env.template` -> `.env`
- `initdb/` (optional SQL scripts)
- `data/`, `logs/`, `backup/`

## Healthcheck
Uses `pg_isready` with retries.

## Notes
- Add `.env` to `.gitignore`.
- Tune resources under `deploy.resources`.
