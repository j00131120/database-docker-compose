#!/bin/bash

# MySQL Docker Compose 启动脚本
# 作者: Database Docker Compose Project
# 版本: 1.0.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 Docker 是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose 未安装，请先安装 Docker Compose"
        exit 1
    fi
    
    log_success "Docker 环境检查通过"
}

# 检查端口占用
check_ports() {
    local mysql_port=${MYSQL_PORT:-3306}
    local phpmyadmin_port=${PHPMYADMIN_PORT:-8080}
    
    if lsof -Pi :$mysql_port -sTCP:LISTEN -t >/dev/null 2>&1; then
        log_warning "端口 $mysql_port 已被占用"
        read -p "是否继续启动？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    if lsof -Pi :$phpmyadmin_port -sTCP:LISTEN -t >/dev/null 2>&1; then
        log_warning "端口 $phpmyadmin_port 已被占用"
        read -p "是否继续启动？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 创建必要目录
create_directories() {
    log_info "创建必要目录..."
    
    mkdir -p data logs backup conf scripts
    
    # 设置目录权限
    chmod 755 data logs backup conf scripts
    chmod 644 conf/*.cnf scripts/*.sql 2>/dev/null || true
    
    log_success "目录创建完成"
}

# 加载环境变量
load_env() {
    if [ -f .env ]; then
        log_info "加载环境变量..."
        export $(cat .env | grep -v '^#' | xargs)
        log_success "环境变量加载完成"
    else
        log_warning "未找到 .env 文件，使用默认配置"
    fi
}

# 启动服务
start_services() {
    log_info "启动 MySQL 服务..."
    
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        log_success "服务启动成功"
    else
        log_error "服务启动失败"
        exit 1
    fi
}

# 等待服务就绪
wait_for_services() {
    log_info "等待服务就绪..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker-compose ps | grep -q "Up"; then
            log_success "服务已就绪"
            break
        fi
        
        log_info "等待服务启动... (尝试 $attempt/$max_attempts)"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    if [ $attempt -gt $max_attempts ]; then
        log_error "服务启动超时"
        exit 1
    fi
}

# 显示服务状态
show_status() {
    log_info "服务状态:"
    docker-compose ps
    
    echo
    log_info "服务访问信息:"
    echo "MySQL 数据库: localhost:${MYSQL_PORT:-3306}"
    echo "phpMyAdmin: http://localhost:${PHPMYADMIN_PORT:-8080}"
    echo "用户名: root"
    echo "密码: ${MYSQL_ROOT_PASSWORD:-123456}"
}

# 主函数
main() {
    echo "========================================"
    echo "    MySQL Docker Compose 启动脚本"
    echo "========================================"
    echo
    
    check_docker
    load_env
    check_ports
    create_directories
    start_services
    wait_for_services
    show_status
    
    echo
    log_success "MySQL 服务启动完成！"
}

# 执行主函数
main "$@"
