#!/bin/bash

# MySQL Docker Compose 停止脚本
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

# 检查服务状态
check_status() {
    if ! docker-compose ps | grep -q "Up"; then
        log_warning "MySQL 服务未运行"
        return 1
    fi
    return 0
}

# 安全停止服务
stop_services() {
    log_info "停止 MySQL 服务..."
    
    docker-compose down
    
    if [ $? -eq 0 ]; then
        log_success "服务停止成功"
    else
        log_error "服务停止失败"
        exit 1
    fi
}

# 强制清理
force_cleanup() {
    log_warning "执行强制清理..."
    
    # 停止并删除容器
    docker-compose down --remove-orphans
    
    # 删除数据卷（谨慎操作）
    if [ "$1" = "--force" ]; then
        read -p "⚠️  警告：这将删除所有数据！确认继续？(y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_warning "删除数据卷..."
            docker-compose down -v
            log_success "数据卷已删除"
        fi
    fi
    
    # 清理网络
    docker network prune -f 2>/dev/null || true
    
    log_success "强制清理完成"
}

# 备份数据
backup_data() {
    if check_status; then
        log_info "创建数据备份..."
        
        local backup_dir="backup/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$backup_dir"
        
        # 备份 MySQL 数据
        docker exec mysql8.0 mysqldump -u root -p${MYSQL_ROOT_PASSWORD:-123456} \
            --all-databases --single-transaction --routines --triggers \
            > "$backup_dir/full_backup.sql" 2>/dev/null || {
            log_warning "数据备份失败，可能服务未完全启动"
        }
        
        # 备份配置文件
        cp -r conf "$backup_dir/" 2>/dev/null || true
        cp -r scripts "$backup_dir/" 2>/dev/null || true
        
        log_success "备份完成: $backup_dir"
    fi
}

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo
    echo "选项:"
    echo "  -h, --help     显示此帮助信息"
    echo "  -f, --force    强制清理（删除数据卷）"
    echo "  -b, --backup   停止前备份数据"
    echo
    echo "示例:"
    echo "  $0             正常停止服务"
    echo "  $0 --backup    停止前备份数据"
    echo "  $0 --force     强制清理所有数据"
}

# 主函数
main() {
    echo "========================================"
    echo "    MySQL Docker Compose 停止脚本"
    echo "========================================"
    echo
    
    # 解析命令行参数
    local backup_flag=false
    local force_flag=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -b|--backup)
                backup_flag=true
                shift
                ;;
            -f|--force)
                force_flag=true
                shift
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 加载环境变量
    if [ -f .env ]; then
        export $(cat .env | grep -v '^#' | xargs)
    fi
    
    # 执行备份
    if [ "$backup_flag" = true ]; then
        backup_data
    fi
    
    # 检查服务状态
    if ! check_status; then
        log_info "服务未运行，无需停止"
        exit 0
    fi
    
    # 执行停止操作
    if [ "$force_flag" = true ]; then
        force_cleanup --force
    else
        stop_services
    fi
    
    echo
    log_success "MySQL 服务已停止！"
}

# 执行主函数
main "$@"
