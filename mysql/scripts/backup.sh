#!/bin/bash

# MySQL 数据库备份脚本
# 作者: Database Docker Compose Project
# 版本: 1.0.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0m'
NC='\033[0m'

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

# 加载环境变量
load_env() {
    if [ -f ../.env ]; then
        export $(cat ../.env | grep -v '^#' | xargs)
    fi
}

# 创建备份目录
create_backup_dir() {
    local backup_dir="../backup/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    echo "$backup_dir"
}

# 备份单个数据库
backup_database() {
    local database=$1
    local backup_dir=$2
    
    log_info "备份数据库: $database"
    
    docker exec mysql8.0 mysqldump -u root -p${MYSQL_ROOT_PASSWORD:-123456} \
        --single-transaction --routines --triggers --events \
        "$database" > "$backup_dir/${database}_backup.sql"
    
    if [ $? -eq 0 ]; then
        log_success "数据库 $database 备份成功"
        # 压缩备份文件
        gzip "$backup_dir/${database}_backup.sql"
        log_success "备份文件已压缩: ${database}_backup.sql.gz"
    else
        log_error "数据库 $database 备份失败"
        return 1
    fi
}

# 备份所有数据库
backup_all_databases() {
    local backup_dir=$1
    
    log_info "备份所有数据库..."
    
    docker exec mysql8.0 mysqldump -u root -p${MYSQL_ROOT_PASSWORD:-123456} \
        --all-databases --single-transaction --routines --triggers --events \
        > "$backup_dir/full_backup.sql"
    
    if [ $? -eq 0 ]; then
        log_success "全量备份成功"
        # 压缩备份文件
        gzip "$backup_dir/full_backup.sql"
        log_success "全量备份文件已压缩: full_backup.sql.gz"
    else
        log_error "全量备份失败"
        return 1
    fi
}

# 备份配置文件
backup_configs() {
    local backup_dir=$1
    
    log_info "备份配置文件..."
    
    cp -r ../conf "$backup_dir/" 2>/dev/null || true
    cp -r ../scripts "$backup_dir/" 2>/dev/null || true
    cp ../.env "$backup_dir/" 2>/dev/null || true
    cp ../mysql_docker-compose.yml "$backup_dir/" 2>/dev/null || true
    
    log_success "配置文件备份完成"
}

# 清理旧备份
cleanup_old_backups() {
    local backup_dir="../backup"
    local keep_days=7
    
    log_info "清理 $keep_days 天前的旧备份..."
    
    find "$backup_dir" -type d -name "*_*" -mtime +$keep_days -exec rm -rf {} \; 2>/dev/null || true
    
    log_success "旧备份清理完成"
}

# 显示备份信息
show_backup_info() {
    local backup_dir=$1
    
    echo
    log_info "备份完成！"
    echo "备份目录: $backup_dir"
    echo "备份时间: $(date)"
    echo
    echo "备份内容:"
    ls -la "$backup_dir"
}

# 主函数
main() {
    echo "========================================"
    echo "      MySQL 数据库备份脚本"
    echo "========================================"
    echo
    
    # 检查参数
    local database=""
    local backup_all=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--database)
                database="$2"
                shift 2
                ;;
            -a|--all)
                backup_all=true
                shift
                ;;
            -h|--help)
                echo "用法: $0 [选项]"
                echo "选项:"
                echo "  -d, --database DATABASE  备份指定数据库"
                echo "  -a, --all                备份所有数据库"
                echo "  -h, --help               显示帮助信息"
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                exit 1
                ;;
        esac
    done
    
    # 加载环境变量
    load_env
    
    # 检查 MySQL 容器状态
    if ! docker ps | grep -q mysql8.0; then
        log_error "MySQL 容器未运行，请先启动服务"
        exit 1
    fi
    
    # 创建备份目录
    local backup_dir=$(create_backup_dir)
    
    # 执行备份
    if [ "$backup_all" = true ]; then
        backup_all_databases "$backup_dir"
    elif [ -n "$database" ]; then
        backup_database "$database" "$backup_dir"
    else
        # 默认备份所有数据库
        backup_all_databases "$backup_dir"
    fi
    
    # 备份配置文件
    backup_configs "$backup_dir"
    
    # 清理旧备份
    cleanup_old_backups
    
    # 显示备份信息
    show_backup_info "$backup_dir"
}

# 执行主函数
main "$@"
