# OceanBase + OCP Docker Compose 项目

这是一个完整的 OceanBase 数据库和 OCP (OceanBase Cloud Platform) 运维管理平台的 Docker Compose 部署项目，集成了完整的监控、日志和可视化解决方案。

## 🚀 项目特性

- **一键部署**: 完整的 Docker Compose 配置，支持一键启动
- **运维管理**: 集成 OCP 平台，提供图形化管理界面
- **高可用性**: 支持健康检查和自动重启
- **数据持久化**: 所有数据目录持久化保存
- **灵活配置**: 支持环境变量自定义配置
- **监控告警**: 内置 Prometheus + Grafana 监控体系
- **日志聚合**: 集成 Loki 日志收集和分析
- **性能优化**: 生产级性能调优和安全配置
- **备份策略**: 完整的备份和恢复机制

## 🏗️ 项目架构

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

## 📋 服务说明

### 1. OceanBase 数据库 (oceanbase)
- **镜像**: `oceanbase/oceanbase-ce:latest`
- **端口**: 2881 (MySQL 协议)
- **模式**: mini (最小部署)
- **内存**: 6GB (可配置)
- **CPU**: 2 核 (可配置)
- **功能**: 分布式数据库，兼容 MySQL 协议
- **优化**: 性能调优、系统日志、错误信息增强

### 2. OCP 运维管理平台 (ocp)
- **镜像**: `oceanbase/ocp:latest`
- **端口**: 8080 (Web UI), 9090 (监控指标)
- **功能**: 集群监控、运维管理、性能分析、告警管理
- **优化**: JVM 调优、监控集成、日志管理

### 3. MySQL 数据库 (ocp-mysql)
- **镜像**: `mysql:8.0`
- **端口**: 3306
- **用途**: 存储 OCP 元数据、配置信息、监控数据
- **数据库**: ocp
- **优化**: InnoDB 优化、字符集配置、性能调优

### 4. Redis 缓存 (ocp-redis)
- **镜像**: `redis:7.0-alpine`
- **端口**: 6379
- **用途**: OCP 缓存服务、会话存储、性能优化
- **优化**: 内存管理、持久化配置、性能调优

### 5. Prometheus 监控 (oceanbase-prometheus)
- **镜像**: `prom/prometheus:latest`
- **端口**: 9091
- **功能**: 指标收集、存储、告警管理
- **监控**: OceanBase、OCP、MySQL、Redis 等所有服务

### 6. Loki 日志聚合 (oceanbase-loki)
- **镜像**: `grafana/loki:latest`
- **端口**: 3100
- **功能**: 集中化日志收集、查询、分析
- **支持**: 多种日志格式、高性能查询

### 7. Grafana 可视化 (oceanbase-grafana)
- **镜像**: `grafana/grafana:latest`
- **端口**: 3000
- **功能**: 监控数据可视化、仪表板、告警
- **数据源**: Prometheus、Loki、MySQL、OceanBase

## 🚀 快速开始

### 方法一：使用自动化脚本（推荐）

```bash
# 1. 给脚本添加执行权限
chmod +x start.sh stop.sh

# 2. 启动所有服务
./start.sh

# 3. 停止服务
./stop.sh
```

### 方法二：使用 Docker Compose

```bash
# 1. 启动所有服务
docker-compose up -d

# 2. 查看服务状态
docker-compose ps

# 3. 查看日志
docker-compose logs -f

# 4. 停止服务
docker-compose down
```

## 🌐 服务访问

| 服务 | 地址 | 端口 | 用户名 | 密码 | 说明 |
|------|------|------|--------|------|------|
| **OCP Web UI** | http://localhost:8080 | 8080 | - | - | 运维管理界面 |
| **OceanBase** | localhost | 2881 | root@sys | 123456 | 数据库连接 |
| **MySQL** | localhost | 3306 | ocp | ocp123456 | OCP 元数据 |
| **Redis** | localhost | 6379 | - | ocp123456 | 缓存服务 |
| **Prometheus** | http://localhost:9091 | 9091 | - | - | 监控指标 |
| **Loki** | http://localhost:3100 | 3100 | - | - | 日志查询 |
| **Grafana** | http://localhost:3000 | 3000 | admin | admin123 | 监控面板 |

## 🔧 连接示例

### 连接 OceanBase
```bash
# 使用 obclient 连接
docker exec -it oceanbase obclient -h127.0.0.1 -P2881 -uroot@sys -p123456

# 使用 MySQL 客户端
mysql -h127.0.0.1 -P2881 -uroot@sys -p123456

# 连接租户数据库
mysql -h127.0.0.1 -P2881 -uroot@oceanbase_db -p123456
```

### 连接 OCP 数据库
```bash
# 连接 OCP 元数据库
mysql -h127.0.0.1 -P3306 -uocp -pocp123456 ocp

# 连接 root 用户
mysql -h127.0.0.1 -P3306 -uroot -pocp123456
```

### 连接 Redis
```bash
# 使用 redis-cli 连接
redis-cli -h localhost -p 6379 -a ocp123456

# 测试连接
redis-cli -h localhost -p 6379 -a ocp123456 ping
```

### 访问监控服务
```bash
# Prometheus 查询界面
curl http://localhost:9091/api/v1/query?query=up

# Loki 日志查询
curl "http://localhost:3100/loki/api/v1/query_range?query={job=\"oceanbase\"}"

# Grafana API
curl http://localhost:3000/api/health
```

## ⚙️ 配置说明

### 环境变量配置
复制 `env.template` 为 `.env` 并自定义配置：

```bash
cp env.template .env
# 编辑 .env 文件修改配置
```

#### 使用方式说明
- `.env` 文件需与 `oceanbase_docker-compose.yml` 放在同一目录（本目录）。
- Docker Compose 会在启动时自动读取 `.env`，替换 compose 中的 `${VAR:-默认值}`。
- 若 `.env` 未定义某变量，将使用 compose 文件里的默认值（冒号后的部分）。

示例：
```bash
# 复制模板并修改端口/密码/资源限制
cp env.template .env
vim .env

# 启动（两种方式二选一）
docker compose -f oceanbase_docker-compose.yml up -d
# 或
./start.sh
```

建议：
- `.env` 通常包含敏感信息，建议加入 `.gitignore`，避免提交到远端仓库。
- 首次启动后尽快修改默认密码（OceanBase/MySQL/Redis/Grafana），并同步更新 `.env`。

### 主要配置项
- **OceanBase**: 内存限制、CPU 核心数、租户配置
- **OCP**: 服务端口、日志级别、时区设置、监控配置
- **MySQL**: 数据库密码、端口配置、性能参数
- **Redis**: 缓存密码、端口配置、内存策略
- **监控服务**: 数据保留、告警规则、日志配置

### 数据持久化
- `./oceanbase-data`: OceanBase 数据目录
- `./oceanbase-conf`: OceanBase 配置目录
- `./oceanbase-backup`: OceanBase 备份目录
- `./ocp-mysql-data`: MySQL 数据目录
- `./ocp-mysql-conf`: MySQL 配置目录
- `./ocp-mysql-backup`: MySQL 备份目录
- `./ocp-redis-data`: Redis 数据目录
- `./ocp-redis-conf`: Redis 配置目录
- `./ocp-redis-backup`: Redis 备份目录
- `./ocp-data`: OCP 数据目录
- `./ocp-logs`: OCP 日志目录
- `./ocp-config`: OCP 配置目录
- `./ocp-backup`: OCP 备份目录
- `./prometheus-data`: Prometheus 数据
- `./loki-data`: Loki 日志数据
- `./grafana-data`: Grafana 数据

## 📊 健康检查

所有服务都配置了健康检查：

| 服务 | 检查方式 | 检查间隔 | 超时时间 | 重试次数 |
|------|----------|----------|----------|----------|
| **OceanBase** | SQL 查询 | 10s | 5s | 20 |
| **OCP** | HTTP 健康检查 | 30s | 10s | 3 |
| **MySQL** | mysqladmin ping | 10s | 5s | 5 |
| **Redis** | redis-cli ping | 10s | 5s | 5 |
| **Prometheus** | HTTP 健康检查 | 30s | 10s | 3 |
| **Loki** | HTTP 就绪检查 | 30s | 10s | 3 |
| **Grafana** | API 健康检查 | 30s | 10s | 3 |

## 🛠️ 管理脚本

### start.sh - 启动脚本
```bash
./start.sh
```
**功能**:
- 检查系统环境 (Docker, Docker Compose)
- 检查端口占用
- 创建必要目录
- 启动所有服务
- 等待服务就绪
- 显示服务状态

### stop.sh - 停止脚本
```bash
./stop.sh          # 交互式停止
./stop.sh --force  # 强制清理
```
**功能**:
- 安全停止服务
- 清理容器和网络
- 可选的数据清理
- 交互式操作选择

## 🔍 监控和日志

### 查看服务状态
```bash
# 查看所有服务状态
docker-compose ps

# 查看特定服务状态
docker-compose ps oceanbase
docker-compose ps ocp
docker-compose ps prometheus
```

### 查看服务日志
```bash
# 查看所有服务日志
docker-compose logs -f

# 查看特定服务日志
docker-compose logs -f oceanbase
docker-compose logs -f ocp
docker-compose logs -f prometheus
docker-compose logs -f loki
docker-compose logs -f grafana
```

### 进入容器调试
```bash
# 进入 OceanBase 容器
docker exec -it oceanbase bash

# 进入 OCP 容器
docker exec -it ocp bash

# 进入监控容器
docker exec -it oceanbase-prometheus sh
docker exec -it oceanbase-loki sh
docker exec -it oceanbase-grafana bash
```

### 监控数据查询
```bash
# Prometheus 查询
curl "http://localhost:9091/api/v1/query?query=up"

# Loki 日志查询
curl "http://localhost:3100/loki/api/v1/query_range?query={job=\"oceanbase\"}"

# Grafana 仪表板
# 访问 http://localhost:3000 查看预配置的仪表板
```

## 🚨 故障排除

### 常见问题

#### 1. 服务启动失败
```bash
# 查看详细错误日志
docker-compose logs [service-name]

# 检查端口占用
lsof -i :2881
lsof -i :3306
lsof -i :6379
lsof -i :8080
lsof -i :9091
lsof -i :3100
lsof -i :3000

# 检查磁盘空间
df -h

# 检查资源使用
docker stats
```

#### 2. OceanBase 连接失败
```bash
# 检查 OceanBase 状态
docker exec -it oceanbase obd cluster list

# 检查网络连接
docker exec -it oceanbase ping ocp-mysql
docker exec -it oceanbase ping ocp-redis

# 检查系统参数
docker exec -it oceanbase cat /proc/sys/fs/file-max
```

#### 3. OCP 无法访问
```bash
# 检查 OCP 服务状态
docker exec -it ocp ps aux

# 检查配置文件
docker exec -it ocp cat /opt/ocp/config/ocp.properties

# 检查数据库连接
docker exec -it ocp-mysql mysql -uocp -pocp123456 -e "SELECT 1"

# 检查监控端点
curl -f http://localhost:9090/metrics
```

#### 4. 监控服务问题
```bash
# 检查 Prometheus 配置
docker exec -it oceanbase-prometheus cat /etc/prometheus/prometheus.yml

# 检查 Loki 配置
docker exec -it oceanbase-loki cat /etc/loki/loki-config.yml

# 检查 Grafana 配置
docker exec -it oceanbase-grafana cat /etc/grafana/grafana.ini
```

### 重启服务
```bash
# 重启特定服务
docker-compose restart [service-name]

# 重启所有服务
docker-compose restart

# 重新创建服务
docker-compose down
docker-compose up -d
```

### 清理和重置
```bash
# 停止并清理容器
docker-compose down

# 清理数据（谨慎操作）
docker-compose down -v
sudo rm -rf ./oceanbase-data ./ocp-*-data ./prometheus-data ./loki-data ./grafana-data

# 清理镜像（可选）
docker-compose down --rmi all
```

## 📈 性能优化

### 系统参数优化
```bash
# 增加文件描述符限制
echo 655350 > /proc/sys/fs/file-max

# 增加 AIO 请求数限制
echo 1048576 > /proc/sys/fs/aio-max-nr

# 调整虚拟内存映射
echo 655360 > /proc/sys/vm/max_map_count

# 设置内存过度提交
echo 0 > /proc/sys/vm/overcommit_memory
```

### Docker 资源限制
在 `docker-compose.yml` 中调整资源限制：
```yaml
deploy:
  resources:
    limits:
      memory: 8G
      cpus: '4.0'
    reservations:
      memory: 4G
      cpus: '2.0'
```

### 监控性能调优
```bash
# Prometheus 存储优化
# 在 prometheus-config/prometheus.yml 中调整：
# - storage.tsdb.retention.time: 30d
# - storage.tsdb.wal-compression: true

# Loki 查询优化
# 在 loki-config/loki-config.yml 中调整：
# - query_range.results_cache.enabled: true
# - query_range.results_cache.max_size_mb: 200
```

## 🔒 安全配置

### 生产环境建议
1. **修改默认密码**: 更改所有服务的默认密码
2. **网络隔离**: 使用 Docker 网络隔离服务
3. **访问控制**: 限制外部访问端口
4. **日志审计**: 启用详细的日志记录
5. **定期备份**: 设置自动备份策略
6. **TLS 加密**: 启用 HTTPS 和 TLS 加密
7. **防火墙规则**: 配置网络防火墙

### 密码管理
```bash
# 修改 OceanBase 密码
docker exec -it oceanbase obclient -h127.0.0.1 -P2881 -uroot@sys -p123456 -e "ALTER USER 'root'@'%' IDENTIFIED BY 'new_password';"

# 修改 MySQL 密码
docker exec -it ocp-mysql mysql -uroot -pocp123456 -e "ALTER USER 'ocp'@'%' IDENTIFIED BY 'new_password';"

# 修改 Redis 密码
docker exec -it ocp-redis redis-cli -a ocp123456 CONFIG SET requirepass "new_password"

# 修改 Grafana 密码
# 访问 http://localhost:3000 在 Web 界面中修改
```

### 网络安全
```bash
# 检查网络配置
docker network inspect oceanbase-network

# 限制端口访问
# 使用 iptables 或 ufw 限制外部访问
sudo ufw allow from 192.168.1.0/24 to any port 8080
sudo ufw allow from 192.168.1.0/24 to any port 3000
```

## 📚 学习资源

### 官方文档
- [OceanBase 官方文档](https://www.oceanbase.com/docs)
- [OCP 使用指南](https://www.oceanbase.com/docs/ocp)
- [Prometheus 官方文档](https://prometheus.io/docs/)
- [Loki 官方文档](https://grafana.com/docs/loki/)
- [Grafana 官方文档](https://grafana.com/docs/)
- [Docker Compose 文档](https://docs.docker.com/compose/)

### 社区资源
- [OceanBase 社区](https://github.com/oceanbase/oceanbase)
- [OCP 社区](https://github.com/oceanbase/ocp)
- [Prometheus 社区](https://github.com/prometheus/prometheus)
- [Grafana 社区](https://github.com/grafana/grafana)
- [问题反馈](https://github.com/oceanbase/oceanbase/issues)

### 监控仪表板
- **OceanBase 监控**: 预配置的 OceanBase 专用仪表板
- **系统监控**: 主机资源使用监控
- **应用监控**: OCP 服务性能监控
- **数据库监控**: MySQL 和 Redis 性能监控

## 🆘 获取帮助

### 问题反馈
1. 查看项目 Issues
2. 提交新的 Issue
3. 联系项目维护者

### 社区支持
- 加入 OceanBase 技术交流群
- 参与社区讨论
- 分享使用经验

### 监控告警
- 配置关键指标告警
- 设置服务状态告警
- 配置性能阈值告警

## 📋 系统要求

### 最低要求
- **操作系统**: Linux (Ubuntu 18.04+, CentOS 7+)
- **内存**: 12GB RAM (包含监控服务)
- **存储**: 50GB 可用空间
- **Docker**: 20.10+
- **Docker Compose**: 2.0+

### 推荐配置
- **操作系统**: Linux (Ubuntu 20.04+, CentOS 8+)
- **内存**: 24GB RAM
- **存储**: 100GB+ SSD
- **Docker**: 23.0+
- **Docker Compose**: 2.20+

### 网络要求
- **端口**: 2881, 3306, 6379, 8080, 9091, 3100, 3000
- **带宽**: 建议 100Mbps+
- **延迟**: 建议 < 10ms

## 📝 更新日志

### v2.0.0 (2024-08-26)
- ✨ 集成完整的监控体系 (Prometheus + Loki + Grafana)
- 🚀 性能优化和安全增强
- 🔧 自动化管理脚本
- 📊 预配置监控仪表板
- 🔒 生产级安全配置
- 📚 完整的文档和使用指南

### v1.0.0 (2024-08-26)
- ✨ 初始版本发布
- 🚀 支持 OceanBase + OCP 完整部署
- 🔧 提供自动化管理脚本
- 📊 集成健康检查和监控

## 📄 许可证

本项目遵循各组件对应的开源许可证：
- **OceanBase**: Apache License 2.0
- **OCP**: Apache License 2.0
- **MySQL**: GPL v2
- **Redis**: BSD 3-Clause
- **Prometheus**: Apache License 2.0
- **Loki**: Apache License 2.0
- **Grafana**: Apache License 2.0

## 🔗 相关链接

- [项目主页](https://github.com/your-username/oceanbase-ocp)
- [问题反馈](https://github.com/your-username/oceanbase-ocp/issues)
- [优化配置说明](OPTIMIZATION.md)
- [环境变量模板](env.template)

---

**⭐ 如果这个项目对您有帮助，请给我们一个 Star！**

**📧 如有问题或建议，欢迎提交 Issue 或联系维护者。**
