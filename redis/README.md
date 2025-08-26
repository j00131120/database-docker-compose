# Redis Docker Compose 项目

这是一个优化的 Redis 容器化部署项目，使用 Docker Compose 进行管理。

## 🚀 快速开始

### 1. 环境准备
确保已安装 Docker 和 Docker Compose：
```bash
docker --version
docker-compose --version
```

### 2. 配置环境变量
复制 `env.template` 为 `.env` 并根据需要修改（与 compose 同目录）：
```bash
cp env.template .env
# 编辑 .env 文件，设置端口/密码等
```

### 3. 启动服务（支持脚本）
```bash
# 使用脚本（推荐）
chmod +x start.sh stop.sh
./start.sh

# 或使用 Docker Compose
docker compose -f redis_docker-compose.yml up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker compose -f redis_docker-compose.yml logs -f redis
```

### 4. 连接 Redis
```bash
# 使用 redis-cli 连接
docker exec -it redis_container redis-cli -a your_password

# 或使用主机端口连接
redis-cli -h localhost -p 6379 -a your_password
```

## 🔧 配置说明

### 主要优化点

#### 安全性改进
- **Alpine 镜像**: 使用 `redis:7.4.5-alpine` 减少攻击面
- **网络隔离**: 创建专用网络 `redis_network`
- **权限控制**: 移除 `privileged: true`，添加 `no-new-privileges`
- **端口绑定**: 默认只允许本地访问 `127.0.0.1:6379`

#### 性能优化
- **资源限制**: 设置内存和 CPU 限制
- **健康检查**: 改进的健康检查机制
- **临时文件系统**: 使用 tmpfs 提高性能

#### 可维护性
- **环境变量**: 敏感信息通过 `.env` 文件管理
- **标签管理**: 添加容器标签便于管理
- **重启策略**: 设置 `restart: unless-stopped`

### 环境配置

#### 开发环境
复制 `docker-compose.override.yml.example` 为 `docker-compose.override.yml`：
```bash
cp docker-compose.override.yml.example docker-compose.override.yml
```

#### 生产环境
- 修改端口绑定为本地访问
- 调整资源限制
- 配置外部日志系统

## 📁 项目结构

```
001_redis/
├── redis_docker-compose.yml           # 主配置文件
├── docker-compose.override.yml.example # 环境配置示例
├── .env.example                      # 环境变量模板
├── redis.conf                        # Redis 配置文件
├── data/                             # 数据持久化目录
├── logs/                             # 日志目录
└── README.md                         # 项目说明
```

## 🛠️ 常用命令

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f redis

# 进入容器
docker exec -it redis_container bash

# 备份数据
docker exec redis_container redis-cli BGSAVE

# 清理数据（谨慎使用）
docker-compose down -v
```

## 🔒 安全建议

1. **修改默认密码**: 在 `.env` 文件中设置强密码
2. **网络访问控制**: 生产环境建议只允许本地访问
3. **定期更新**: 定期更新 Redis 镜像版本
4. **监控日志**: 启用日志记录并定期检查
5. **备份策略**: 定期备份 Redis 数据

## 📊 监控和日志

### 健康检查
服务包含健康检查，可以通过以下命令查看：
```bash
docker inspect redis_container | grep Health -A 10
```

### 日志管理
- 开发环境：使用 json-file 驱动，限制日志大小
- 生产环境：建议使用 syslog 或 ELK 栈

## 🚨 故障排除

### 常见问题

1. **端口冲突**: 确保 6379 端口未被占用
2. **权限问题**: 检查数据目录权限
3. **内存不足**: 调整 `deploy.resources.limits.memory`
4. **连接失败**: 检查防火墙和网络配置

### 日志查看
```bash
# 查看 Redis 日志
docker-compose logs redis

# 查看系统日志
docker exec redis_container tail -f /var/log/redis/redis.log
```

## 📝 更新日志

- **v2.0**: 优化安全性、性能和可维护性
- **v1.0**: 基础 Redis 容器化配置

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。

## 📄 许可证

本项目采用 MIT 许可证。
