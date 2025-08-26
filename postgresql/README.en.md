# PostgreSQL Docker Compose Project

## Quick Start

### 0. Configure environment
```bash
cp env.template .env
# edit .env for ports/passwords
```

### 1. Start (scripts supported)
```bash
chmod +x start.sh stop.sh
./start.sh
# or
docker compose -f postgres_docker-compose.yml up -d
```

### 2. Access
- Postgres: localhost:${POSTGRES_PORT:-5432}
- User: `${POSTGRES_USER:-postgres}` / `${POSTGRES_PASSWORD:-postgres}`
- DB: `${POSTGRES_DB:-app_db}`

### 3. Stop
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

## Notes
- Add `.env` to `.gitignore`.
- Tune resources under `deploy.resources`.
