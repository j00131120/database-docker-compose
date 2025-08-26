# MongoDB Docker Compose Project

## Quick Start

### 0. Configure environment
```bash
cp env.template .env
# edit .env for usernames/passwords
```

### 1. Start (scripts supported)
```bash
chmod +x start.sh stop.sh
./start.sh
# or
docker compose -f mongodb_docker-compose.yml up -d
```

### 2. Access
- MongoDB: `mongodb://admin:123456@localhost:27017`
- Mongo Express: http://localhost:27018 (default admin/123456)

### 3. Stop
```bash
./stop.sh
# or
docker compose -f mongodb_docker-compose.yml down
```

## Files
- `mongodb_docker-compose.yml`
- `env.template` -> `.env`
- `database/`, `logs/`, `config/`

## Notes
- Binds to 127.0.0.1 by default.
- Add `.env` to `.gitignore`.
