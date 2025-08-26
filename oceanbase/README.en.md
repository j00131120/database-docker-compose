# OceanBase + OCP Docker Compose Stack

A production-lean Docker Compose setup for OceanBase Database and OCP (OceanBase Cloud Platform), bundled with Prometheus, Loki, and Grafana for monitoring and observability.

## Features

- One-command deployment with Docker Compose
- OCP web UI for operations and management
- Health checks and auto-restart
- Persistent volumes for all data
- Flexible configuration via .env
- Built-in monitoring (Prometheus + Grafana)
- Centralized logs (Loki)
- Sensible performance and security defaults
- Backup directories prepared

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   OCP Web UI    │    │   OCP Service   │    │  OceanBase DB   │
│   (Port 8080)   │◄──►│   (Port 8080)   │◄──►│   (Port 2881)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                               │
                               ▼
                      ┌─────────────────┐    ┌─────────────────┐
                      │   MySQL 8.0     │    │   Redis 7.0     │
                      │   (Port 3306)   │    │   (Port 6379)   │
                      └─────────────────┘    └─────────────────┘
                               │
                               ▼
                      ┌─────────────────┐    ┌─────────────────┐
                      │   Prometheus    │    │     Grafana     │
                      │   (Port 9091)   │    │   (Port 3000)   │
                      └─────────────────┘    └─────────────────┘
                               │
                               ▼
                      ┌─────────────────┐
                      │      Loki       │
                      │   (Port 3100)   │
                      └─────────────────┘
```

## Services

- OceanBase (oceanbase): `oceanbase/oceanbase-ce:latest`, MySQL protocol on 2881, mini mode by default
- OCP (ocp): `oceanbase/ocp:latest`, web 8080, metrics 9090
- MySQL (ocp-mysql): `mysql:8.0`, stores OCP metadata
- Redis (ocp-redis): `redis:7.0-alpine`, cache/session for OCP
- Prometheus: metrics collection on 9091 (mapped from 9090 in container)
- Loki: log aggregation on 3100
- Grafana: dashboards on 3000

## Quick Start

### Method 1: Scripts (recommended)
```bash
chmod +x start.sh stop.sh
./start.sh     # start all services
./stop.sh      # stop services
```

### Method 2: Docker Compose
```bash
docker compose -f oceanbase_docker-compose.yml up -d
# or: docker-compose -f oceanbase_docker-compose.yml up -d
```

## Access

- OCP UI: http://localhost:8080
- OceanBase: host `127.0.0.1`, port `2881`, user `root@sys`, pass `123456`
- MySQL (OCP meta): host `127.0.0.1`, port `3306`, user `ocp`, pass `ocp123456`
- Redis: host `127.0.0.1`, port `6379`, pass `ocp123456`
- Prometheus: http://localhost:9091
- Loki: http://localhost:3100
- Grafana: http://localhost:3000 (admin/admin123)

## Connect Examples

```bash
# OceanBase via obclient
docker exec -it oceanbase obclient -h127.0.0.1 -P2881 -uroot@sys -p123456

# OceanBase via mysql client
mysql -h127.0.0.1 -P2881 -uroot@sys -p123456

# OCP MySQL
mysql -h127.0.0.1 -P3306 -uocp -pocp123456 ocp

# Redis
redis-cli -h 127.0.0.1 -p 6379 -a ocp123456 ping
```

## Configuration

### Using env.template
- Copy `env.template` to `.env` in the same directory as the compose file:
```bash
cp env.template .env
# edit .env to customize ports, passwords, and resources
```
- Compose automatically reads `.env` and replaces `${VAR:-default}` values.
- If a variable is not set in `.env`, the default in the compose file is used.
- Recommendation: add `.env` to `.gitignore` to avoid leaking secrets.

### Key variables
- OceanBase: `OB_PORT`, `OB_ROOT_PASSWORD`, `OB_TENANT_NAME`, `OB_TENANT_PASSWORD`, `OB_MEMORY_LIMIT`, `OB_CPU_COUNT`
- OCP: `OCP_SERVER_PORT`, `OCP_LOG_LEVEL`
- MySQL: `OCP_MYSQL_*`
- Redis: `OCP_REDIS_*`
- Grafana: `GRAFANA_ADMIN_PASSWORD`
- Network: `OCEANBASE_NETWORK_SUBNET`, `OCEANBASE_NETWORK_GATEWAY`

### Persistence
- `./oceanbase-data`, `./oceanbase-conf`, `./oceanbase-backup`
- `./ocp-mysql-data`, `./ocp-mysql-conf`, `./ocp-mysql-backup`
- `./ocp-redis-data`, `./ocp-redis-conf`, `./ocp-redis-backup`
- `./ocp-data`, `./ocp-logs`, `./ocp-config`, `./ocp-backup`
- `./prometheus-data`, `./loki-data`, `./grafana-data`

## Health Checks

- OceanBase: sql select 1 (20 retries)
- OCP: HTTP /health
- MySQL: mysqladmin ping
- Redis: redis-cli ping
- Prometheus/Loki/Grafana: built-in HTTP endpoints
- OCP depends on healthy MySQL, Redis, and OceanBase to start

## Troubleshooting

```bash
# Logs
docker compose -f oceanbase_docker-compose.yml logs -f

# Service status
docker compose -f oceanbase_docker-compose.yml ps

# Port checks (macOS)
lsof -i :2881 ; lsof -i :3306 ; lsof -i :6379 ; lsof -i :8080 ; lsof -i :9091 ; lsof -i :3100 ; lsof -i :3000
```

## Performance Notes

- Allocate sufficient Docker resources (macOS): ≥12GB RAM (16GB+ with monitoring), ≥4 vCPUs
- Adjust resource limits in compose (`deploy.resources`)
- Tune Prometheus/Loki retention and compression as needed

## Security

- Change all default passwords after first start (OceanBase/MySQL/Redis/Grafana)
- Keep `.env` out of version control
- Restrict exposed ports and use Docker network isolation
- Set up regular backups

## Requirements

- Docker 20.10+
- Docker Compose 2.0+
- Linux/macOS recommended; SSD storage preferred

## License

Each component follows its own license:
- OceanBase, OCP, Prometheus, Loki, Grafana: Apache 2.0
- MySQL: GPL v2
- Redis: BSD 3-Clause

---
If this project helps you, please consider giving it a star.


