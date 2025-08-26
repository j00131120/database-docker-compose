# 数据库 Docker Compose 集合

English version: `README.en.md`

为常见数据库提供统一的 Docker Compose 部署方案，每个栈在各自目录内包含 compose 配置、env 模板、启动/停止脚本与说明文档。

## 目录概览

- OceanBase + OCP（含 Prometheus/Loki/Grafana）
  - 目录：`oceanbase/`
  - 文档：`oceanbase/README.md`（中文），`oceanbase/README.en.md`（英文）
  - Compose：`oceanbase/oceanbase_docker-compose.yml`
- MySQL
  - 目录：`mysql/`
  - 文档：`mysql/README.md`（中文），`mysql/README.en.md`（英文）
  - Compose：`mysql/mysql_docker-compose.yml`
- Redis
  - 目录：`redis/`
  - 文档：`redis/README.md`（中文），`redis/README.en.md`（英文）
  - Compose：`redis/redis_docker-compose.yml`
- MongoDB
  - 目录：`mongodb/`
  - 文档：`mongodb/README.md`（中文），`mongodb/README.en.md`（英文）
  - Compose：`mongodb/mongodb_docker-compose.yml`
- PostgreSQL
  - 目录：`postgresql/`
  - 文档：`postgresql/README.md`（中文），`postgresql/README.en.md`（英文）
  - Compose：`postgresql/postgres_docker-compose.yml`
- Neo4j
  - 目录：`neo4j/`
  - 文档：`neo4j/README.md`（中文），`neo4j/README.en.md`（英文）
  - Compose：`neo4j/neo4j_docker-compose.yml`
- Milvus（Standalone）
  - 目录：`milvus/`
  - 文档：`milvus/README.md`（中文），`milvus/README.en.md`（英文）
  - Compose：`milvus/milvus_docker-compose.yml`

## 快速开始（以 OceanBase 为例）
```bash
cd oceanbase
cp env.template .env
chmod +x start.sh stop.sh
./start.sh
```

## 说明
- 每个栈均提供 `env.template`，复制为 `.env` 后按需修改端口、凭据与资源配置。
- `.env` 建议加入 `.gitignore`，避免敏感信息入库。
- 资源不足时可优先启动核心服务，监控与可视化组件可按需启用。

## License
各组件遵循各自的开源许可证，详见对应子目录 README。