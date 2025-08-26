#!/bin/bash

# MySQL 数据库恢复脚本
# 作者: Database Docker Compose Project
# 版本: 1.0.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# 显示可用备份
show_available_backups() {
    local backup_dir="../backup"
    
    if [ ! -d "$backup_dir" ]; then
        log_error "备份目录不存在: $backup_dir"
        exit 1
    fi
    
    echo "可用的备份:"
    echo "========================================"
    
    local count=0
    for dir in "$backup_dir"/*/; do
        if [ -d "$dir" ]; then
            local dirname=$(basename "$dir")
            local backup_time=$(stat -c %y "$dir" | cut -d' ' -f1,2)
            echo "[$count] $dirname ($backup_time)"
            count=$((count + 1))
        fi
    done
    
    if [ $count -eq 0 ]; then
        log_error "没有找到可用的备份"
        exit 1
    fi
    
    echo "========================================"
}

# 选择备份目录
select_backup() {
    local backup_dir="../backup"
    local selected_backup=""
    
    show_available_backups
    
    read -p "请选择要恢复的备份编号: " backup_number
    
    local count=0
    for dir in "$backup_dir"/*/; do
        if [ -d "$dir" ]; then
            if [ $count -eq $backup_number ]; then
                selected_backup="$dir"
                break
            fi
            count=$((count + 1))
        fi
    done
    
    if [ -z "$selected_backup" ]; then
        log_error "无效的备份编号"
        exit 1
    fi
    
    echo "$selected_backup"
}

# 恢复数据库
restore_database() {
    local backup_file=$1
    local database=$2
    
    log_info "恢复数据库: $database"
    
    # 检查备份文件是否存在
    if [ ! -f "$backup_file" ]; then
        log_error "备份文件不存在: $backup_file"
        return 1
    fi
    
    # 创建数据库（如果不存在）
    docker exec mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} \
        -e "CREATE DATABASE IF NOT EXISTS \`$database\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    
    # 恢复数据库
    if [[ "$backup_file" == *.gz ]]; then
        # 解压并恢复
        gunzip -c "$backup_file" | docker exec -i mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} "$database"
    else
        # 直接恢复
        docker exec -i mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} "$database" < "$backup_file"
    fi
    
    if [ $? -eq 0 ]; then
        log_success "数据库 $database 恢复成功"
    else
        log_error "数据库 $database 恢复失败"
        return 1
    fi
}

# 恢复全量备份
restore_full_backup() {
    local backup_file=$1
    
    log_info "恢复全量备份..."
    
    # 检查备份文件是否存在
    if [ ! -f "$backup_file" ]; then
        log_error "备份文件不存在: $backup_file"
        return 1
    fi
    
    # 恢复全量备份
    if [[ "$backup_file" == *.gz ]]; then
        # 解压并恢复
        gunzip -c "$backup_file" | docker exec -i mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456}
    else
        # 直接恢复
        docker exec -i mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} < "$backup_file"
    fi
    
    if [ $? -eq 0 ]; then
        log_success "全量备份恢复成功"
    else
        log_error "全量备份恢复失败"
        return 1
    fi
}

# 恢复配置文件
restore_configs() {
    local backup_dir=$1
    
    log_info "恢复配置文件..."
    
    # 恢复 MySQL 配置
    if [ -d "$backup_dir/conf" ]; then
        cp -r "$backup_dir/conf" ../ 2>/dev/null || true
        log_success "MySQL 配置已恢复"
    fi
    
    # 恢复脚本文件
    if [ -d "$backup_dir/scripts" ]; then
        cp -r "$backup_dir/scripts" ../ 2>/dev/null || true
        log_success "脚本文件已恢复"
    fi
    
    # 恢复环境变量（可选）
    if [ -f "$backup_dir/.env" ]; then
        read -p "是否恢复环境变量文件？(y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cp "$backup_dir/.env" ../ 2>/dev/null || true
            log_success "环境变量文件已恢复"
        fi
    fi
}

# 验证恢复结果
verify_restore() {
    log_info "验证恢复结果..."
    
    # 显示数据库列表
    echo "当前数据库列表:"
    docker exec mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} -e "SHOW DATABASES;"
    
    # 显示表数量
    echo
    echo "各数据库表数量:"
    docker exec mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} -e "
        SELECT 
            table_schema as 'Database',
            COUNT(*) as 'Tables'
        FROM information_schema.tables 
        GROUP BY table_schema 
        ORDER BY table_schema;"
}

# 主函数
main() {
    echo "========================================"
    echo "      MySQL 数据库恢复脚本"
    echo "========================================"
    echo
    
    # 检查参数
    local backup_file=""
    local database=""
    local restore_all=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--file)
                backup_file="$2"
                shift 2
                ;;
            -d|--database)
                database="$2"
                shift 2
                ;;
            -a|--all)
                restore_all=true
                shift
                ;;
            -h|--help)
                echo "用法: $0 [选项]"
                echo "选项:"
                echo "  -f, --file FILE          指定备份文件路径"
                echo "  -d, --database DATABASE  恢复指定数据库"
                echo "  -a, --all                恢复所有数据库"
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
    
    # 如果没有指定备份文件，让用户选择
    if [ -z "$backup_file" ]; then
        backup_file=$(select_backup)
    fi
    
    # 执行恢复
    if [ "$restore_all" = true ] || [[ "$backup_file" == *"full_backup"* ]]; then
        restore_full_backup "$backup_file"
    elif [ -n "$database" ]; then
        restore_database "$backup_file" "$database"
    else
        log_error "请指定要恢复的数据库或使用 --all 参数"
        exit 1
    fi
    
    # 恢复配置文件
    restore_configs "$(dirname "$backup_file")"
    
    # 验证恢复结果
    verify_restore
    
    echo
    log_success "数据库恢复完成！"
}

# 执行主函数
main "$@"
