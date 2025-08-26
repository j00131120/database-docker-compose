# MySQL Docker Compose 项目

这是一个优化的MySQL 8.0 Docker Compose项目，包含完整的数据库配置、监控和管理工具。

## 特性

- 🚀 **高性能**: 优化的MySQL配置，支持高并发访问
- 🔒 **安全性**: 安全配置和权限控制
- 📊 **监控**: 完整的日志记录和慢查询监控
- 🛠️ **管理**: 集成phpMyAdmin管理界面
- 📈 **可扩展**: 支持自定义配置和资源限制
- 🔄 **持久化**: 数据持久化存储，支持备份恢复

## 项目结构

```
.
├── mysql_docker-compose.yml    # Docker Compose 配置文件
├── conf/                       # MySQL 配置文件目录
│   └── my.cnf                 # MySQL 配置文件
├── scripts/                    # 数据库初始化脚本
│   └── init.sql               # 数据库表结构和初始数据
├── data/                       # MySQL 数据持久化目录
├── logs/                       # MySQL 日志文件目录
├── backup/                     # 数据库备份目录
└── README.md                   # 项目说明文档
```

## 快速开始

### 0. 配置环境变量（建议）

```bash
cd mysql
cp env.template .env
# 按需修改端口/密码等
```

### 1. 启动服务（可用脚本）

```bash
# 使用脚本
./start.sh

# 或使用 Docker Compose
docker compose -f mysql_docker-compose.yml up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker compose -f mysql_docker-compose.yml logs -f mysql
```

### 2. 访问服务

- **MySQL 数据库**: `localhost:3306`
  - 用户名: `root`
  - 密码: `123456`
  - 数据库: `mysql_db`

- **phpMyAdmin**: `http://localhost:8080`
  - 用户名: `root`
  - 密码: `123456`

### 3. 停止服务

```bash
# 停止所有服务
docker-compose down

# 停止并删除数据卷
docker-compose down -v
```

## 配置说明

### 环境变量

可以通过修改 `.env` 文件来自定义配置：

```bash
# 数据库配置
MYSQL_ROOT_PASSWORD=123456
MYSQL_DATABASE=mysql_db
MYSQL_USER=app_user
MYSQL_PASSWORD=app_password

# 端口配置
MYSQL_PORT=3306
PHPMYADMIN_PORT=8080

# 时区配置
TZ=Asia/Shanghai
```

### MySQL 配置

主要配置参数位于 `conf/my.cnf`：

- **字符集**: UTF8MB4 支持完整的Unicode字符
- **存储引擎**: InnoDB 支持事务和行级锁
- **连接数**: 最大200个并发连接
- **缓冲池**: 256MB InnoDB缓冲池
- **日志**: 慢查询、错误日志、通用日志

### 资源限制

- **内存限制**: 最大1GB，预留512MB
- **CPU限制**: 最大1核，预留0.5核
- **临时文件**: 100MB tmpfs挂载

## 数据库管理

### 备份数据库

```bash
# 进入MySQL容器
docker exec -it mysql8.0 bash

# 备份数据库
mysqldump -u root -p mysql_db > /backup/mysql_db_$(date +%Y%m%d_%H%M%S).sql
```

### 恢复数据库

```bash
# 恢复数据库
mysql -u root -p mysql_db < /backup/backup_file.sql
```

### 查看日志

```bash
# 查看慢查询日志
tail -f logs/slow.log

# 查看错误日志
tail -f logs/error.log

# 查看通用日志
tail -f logs/general.log
```

## 性能优化

### 1. 连接池配置

```sql
-- 查看当前连接数
SHOW STATUS LIKE 'Threads_connected';

-- 查看最大连接数
SHOW VARIABLES LIKE 'max_connections';
```

### 2. 慢查询分析

```sql
-- 启用慢查询日志
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;

-- 查看慢查询统计
SHOW STATUS LIKE 'Slow_queries';
```

### 3. 索引优化

```sql
-- 分析表结构
ANALYZE TABLE users;
ANALYZE TABLE products;

-- 查看索引使用情况
SHOW INDEX FROM users;
```

## 安全配置

- **权限控制**: 创建专用应用用户
- **网络安全**: 自定义网络子网
- **容器安全**: 禁用特权提升
- **文件权限**: 只读临时文件系统

## 故障排除

### 常见问题

1. **端口冲突**: 修改 `.env` 文件中的端口配置
2. **权限问题**: 确保目录有正确的读写权限
3. **内存不足**: 调整 `deploy.resources.limits.memory` 配置
4. **连接超时**: 检查网络配置和防火墙设置

### 日志分析

```bash
# 查看容器日志
docker-compose logs mysql

# 查看MySQL错误日志
docker exec mysql8.0 cat /var/log/mysql/error.log
```

## 扩展功能

### 添加监控

可以集成 Prometheus + Grafana 进行数据库监控：

```yaml
# 在 docker-compose.yml 中添加
  prometheus:
    image: prom/prometheus
    # ... 配置

  grafana:
    image: grafana/grafana
    # ... 配置
```

### 主从复制

可以配置MySQL主从复制以提高可用性。

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！
