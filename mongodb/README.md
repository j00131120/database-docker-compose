# MongoDB Docker Compose 项目

这是一个经过优化的 MongoDB Docker Compose 部署方案，包含 MongoDB 数据库和 Mongo Express 管理界面。

## 🚀 主要特性

- **MongoDB 7.0**: 使用最新的稳定版本
- **Mongo Express**: Web 管理界面
- **健康检查**: 自动监控服务状态
- **资源限制**: 防止资源滥用
- **安全配置**: 增强容器安全性
- **网络隔离**: 自定义网络配置
- **数据持久化**: 本地数据存储
- **日志管理**: 优化的日志配置

## 📁 项目结构

```
.
├── mongodb_docker-compose.yml  # Docker Compose 配置文件
├── env.template                # 环境变量配置模板
├── database/                   # MongoDB 数据目录
├── logs/                       # MongoDB 日志目录
└── config/                     # MongoDB 配置文件目录
```

## 🔧 配置说明

### 环境变量配置

1. 复制环境变量模板：
   ```bash
   cp env.template .env
   ```

2. 编辑 `.env` 文件，修改以下配置：
   - `MONGO_ROOT_USERNAME`: MongoDB 管理员用户名
   - `MONGO_ROOT_PASSWORD`: MongoDB 管理员密码
   - `ME_BASIC_AUTH_USERNAME`: Mongo Express 登录用户名
   - `ME_BASIC_AUTH_PASSWORD`: Mongo Express 登录密码
   - `ME_COOKIE_SECRET`: Cookie 加密密钥
   - `ME_SESSION_SECRET`: Session 加密密钥

### 网络配置

- **MongoDB**: 127.0.0.1:27017 (仅本地访问)
- **Mongo Express**: 127.0.0.1:27018 (仅本地访问)
- **内部网络**: 172.20.0.0/16

## 🚀 使用方法

### 0. 配置环境变量
```bash
cp env.template .env
# 编辑 .env 修改用户名/密码等
```

### 启动服务（支持脚本）

```bash
# 使用脚本（推荐）
chmod +x start.sh stop.sh
./start.sh

# 或使用 Docker Compose
docker compose -f mongodb_docker-compose.yml up -d

# 查看服务状态
docker compose -f mongodb_docker-compose.yml ps

# 查看服务日志
docker compose -f mongodb_docker-compose.yml logs -f
```

### 停止服务

```bash
# 停止所有服务
docker-compose down

# 停止并删除数据卷
docker-compose down -v
```

### 重启服务

```bash
# 重启特定服务
docker-compose restart mongodb

# 重启所有服务
docker-compose restart
```

## 🔍 服务访问

- **MongoDB**: `mongodb://admin:123456@localhost:27017`
- **Mongo Express**: http://localhost:27018
  - 用户名: `admin`
  - 密码: `123456`

## 📊 监控和健康检查

### 健康检查

- MongoDB: 每30秒检查一次，使用 `db.adminCommand('ping')`
- Mongo Express: 每30秒检查一次，验证 Web 服务可用性

### 资源监控

```bash
# 查看容器资源使用情况
docker stats mongodb mongo-express

# 查看容器详细信息
docker inspect mongodb
```

## 🔒 安全特性

- **端口绑定**: 仅绑定到 127.0.0.1，防止外部访问
- **权限控制**: 使用 `no-new-privileges` 安全选项
- **资源限制**: 限制内存和 CPU 使用
- **网络隔离**: 自定义网络配置

## 📝 日志配置

- **MongoDB**: 最大 100MB，保留 5 个文件
- **Mongo Express**: 最大 50MB，保留 3 个文件
- **日志位置**: `./logs/` 目录

## 🛠️ 故障排除

### 常见问题

1. **端口冲突**: 检查 27017 和 27018 端口是否被占用
2. **权限问题**: 确保 `database/` 目录有正确的读写权限
3. **内存不足**: 调整 `.env` 文件中的内存限制

### 日志查看

```bash
# 查看 MongoDB 日志
docker-compose logs mongodb

# 查看 Mongo Express 日志
docker-compose logs mongo-express

# 实时查看日志
docker-compose logs -f --tail=100
```

## 🔄 升级和维护

### 更新镜像

```bash
# 拉取最新镜像
docker-compose pull

# 重新创建容器
docker-compose up -d --force-recreate
```

### 备份数据

```bash
# 备份数据库
docker exec mongodb mongodump --out /data/backup

# 复制备份文件到本地
docker cp mongodb:/data/backup ./backup
```

## 📚 相关文档

- [MongoDB 官方文档](https://docs.mongodb.com/)
- [Mongo Express 文档](https://github.com/mongo-express/mongo-express)
- [Docker Compose 文档](https://docs.docker.com/compose/)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个项目。

## 📄 许可证

本项目采用 MIT 许可证。
