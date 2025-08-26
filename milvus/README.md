# Milvus Docker Compose Project (Standalone)

## Quick Start

### 0. Configure environment
```bash
cp env.template .env
# edit .env for ports/keys
```

### 1. Start services (scripts supported)
```bash
chmod +x start.sh stop.sh
./start.sh
# or
docker compose -f milvus_docker-compose.yml up -d
```

### 2. Access
- Milvus gRPC: localhost:${MILVUS_PORT:-19530}
- Milvus REST: http://localhost:${MILVUS_HTTP_PORT:-9091}
- MinIO Console: http://localhost:9001 (minio/minioadmin)
- Pulsar: 6650 (broker), 8085 (web)

### 3. Stop services
```bash
./stop.sh
# or
docker compose -f milvus_docker-compose.yml down
```

## Files
- `milvus_docker-compose.yml`
- `env.template` -> `.env`
- `volumes/` for etcd, minio, pulsar, milvus

## Notes
- Adjust resources for etcd/minio/pulsar if needed.
- Change MinIO access keys in `.env` for security.
