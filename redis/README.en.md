# Redis Docker Compose Project

## Quick Start

### 0. Configure environment
```bash
cp env.template .env
# edit .env for port/password
```

### 1. Start (scripts supported)
```bash
chmod +x start.sh stop.sh
./start.sh
# or
docker compose -f redis_docker-compose.yml up -d
```

### 2. Access
- CLI inside container: `docker exec -it redis_container redis-cli -a <password>`
- Host: `redis-cli -h 127.0.0.1 -p 6379 -a <password>`

### 3. Stop
```bash
./stop.sh
# or
docker compose -f redis_docker-compose.yml down
```

## Files
- `redis_docker-compose.yml`
- `env.template` -> `.env`
- `data/`, `logs/`

## Notes
- Bind to 127.0.0.1 by default for safety.
- Add `.env` to `.gitignore`.
