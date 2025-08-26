# Neo4j Docker Compose Project

## Quick Start

### 0. Configure environment
```bash
cp env.template .env
# edit .env for ports/auth/memory
```

### 1. Start services (scripts supported)
```bash
chmod +x start.sh stop.sh
./start.sh
# or
docker compose -f neo4j_docker-compose.yml up -d
```

### 2. Access
- Browser: http://localhost:${NEO4J_HTTP_PORT:-7474}
- Bolt: bolt://localhost:${NEO4J_BOLT_PORT:-7687}
- Auth: `${NEO4J_AUTH:-neo4j/neo4jpassword}`

### 3. Stop services
```bash
./stop.sh
# or
docker compose -f neo4j_docker-compose.yml down
```

## Files
- `neo4j_docker-compose.yml`
- `env.template` -> `.env`
- `data/`, `logs/`, `plugins/`, `import/`, `conf/`

## Healthcheck
HTTP probe on 7474.

## Notes
- Change default password on first login.
- Tune memory via `.env`.
