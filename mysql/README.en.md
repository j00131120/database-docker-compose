# MySQL Docker Compose Project

## Quick Start

### 0. Configure environment
```bash
cp env.template .env
# edit .env for ports/passwords
```

### 1. Start (scripts supported)
```bash
./start.sh
# or
docker compose -f mysql_docker-compose.yml up -d
```

### 2. Access
- MySQL: localhost:${MYSQL_PORT:-3306}
- User: `root` / `${MYSQL_ROOT_PASSWORD:-123456}`
- DB: `${MYSQL_DATABASE:-mysql_db}`
- phpMyAdmin: http://localhost:${PHPMYADMIN_PORT:-8080}

### 3. Stop
```bash
./stop.sh
# or
docker compose -f mysql_docker-compose.yml down
```

## Files
- `mysql_docker-compose.yml`
- `env.template` -> `.env`
- `conf/`, `scripts/`, `data/`, `logs/`, `backup/`

## Notes
- Add `.env` to `.gitignore`.
- Tune resources under `deploy.resources`.
