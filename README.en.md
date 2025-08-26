# Database Docker Compose Collections

A curated set of Docker Compose setups for popular databases. Each stack is self-contained in its own directory with scripts, configuration, and documentation.

## Stacks

- OceanBase + OCP (+ Prometheus/Loki/Grafana)
  - Path: `oceanbase/`
  - Docs: `oceanbase/README.md` (Chinese), `oceanbase/README.en.md` (English)
  - Compose: `oceanbase/oceanbase_docker-compose.yml`
- MySQL
  - Path: `mysql/`
  - Compose: `mysql/mysql_docker-compose.yml`
- Redis
  - Path: `redis/`
  - Compose: `redis/redis_docker-compose.yml`
- MongoDB
  - Path: `mongodb/`
  - Compose: `mongodb/mongodb_docker-compose.yml`
- Neo4j
  - Path: `neo4j/`
- Milvus
  - Path: `milvus/`
- PostgreSQL
  - Path: `postgresql/`

## Quick Start (example: OceanBase)
```bash
cd oceanbase
cp env.template .env
chmod +x start.sh stop.sh
./start.sh
```

## Notes
- Each stack may define its own `.env` variables. Copy the provided `env.template` to `.env` before starting.
- Default ports can be changed via `.env`.
- Consider adding `.env` files to `.gitignore` to avoid leaking secrets.

## License
This repository aggregates multiple open-source components. Refer to each subdirectory's README for component-specific licenses.


