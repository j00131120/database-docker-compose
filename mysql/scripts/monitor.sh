#!/bin/bash

# MySQL 数据库监控脚本
# 作者: Database Docker Compose Project
# 版本: 1.0.0

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

# 检查 MySQL 连接
check_connection() {
    log_info "检查 MySQL 连接..."
    
    if docker exec mysql8.0 mysqladmin ping -h localhost -u root -p${MYSQL_ROOT_PASSWORD:-123456} >/dev/null 2>&1; then
        log_success "MySQL 连接正常"
        return 0
    else
        log_error "MySQL 连接失败"
        return 1
    fi
}

# 显示系统状态
show_system_status() {
    log_info "MySQL 系统状态:"
    echo "========================================"
    
    docker exec mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} -e "
        SHOW STATUS LIKE 'Uptime';
        SHOW STATUS LIKE 'Threads_connected';
        SHOW STATUS LIKE 'Threads_running';
        SHOW STATUS LIKE 'Queries';
        SHOW STATUS LIKE 'Slow_queries';
        SHOW STATUS LIKE 'Bytes_received';
        SHOW STATUS LIKE 'Bytes_sent';
        SHOW STATUS LIKE 'Max_used_connections';
        SHOW STATUS LIKE 'Aborted_connects';
        SHOW STATUS LIKE 'Connection_errors';" 2>/dev/null || {
        log_error "无法获取系统状态"
        return 1
    }
}

# 显示变量配置
show_variables() {
    log_info "MySQL 重要配置变量:"
    echo "========================================"
    
    docker exec mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} -e "
        SHOW VARIABLES LIKE 'max_connections';
        SHOW VARIABLES LIKE 'innodb_buffer_pool_size';
        SHOW VARIABLES LIKE 'query_cache_size';
        SHOW VARIABLES LIKE 'slow_query_log';
        SHOW VARIABLES LIKE 'long_query_time';
        SHOW VARIABLES LIKE 'character_set_server';
        SHOW VARIABLES LIKE 'collation_server';
        SHOW VARIABLES LIKE 'default_storage_engine';" 2>/dev/null || {
        log_error "无法获取配置变量"
        return 1
    }
}

# 显示数据库信息
show_database_info() {
    log_info "数据库信息:"
    echo "========================================"
    
    docker exec mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} -e "
        SELECT 
            table_schema as 'Database',
            COUNT(*) as 'Tables',
            ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) as 'Size_MB'
        FROM information_schema.tables 
        GROUP BY table_schema 
        ORDER BY Size_MB DESC;" 2>/dev/null || {
        log_error "无法获取数据库信息"
        return 1
    }
}

# 显示表信息
show_table_info() {
    local database=${1:-mysql_db}
    
    log_info "数据库 $database 表信息:"
    echo "========================================"
    
    docker exec mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} -e "
        SELECT 
            table_name as 'Table',
            table_rows as 'Rows',
            ROUND((data_length + index_length) / 1024 / 1024, 2) as 'Size_MB',
            engine as 'Engine'
        FROM information_schema.tables 
        WHERE table_schema = '$database'
        ORDER BY (data_length + index_length) DESC;" 2>/dev/null || {
        log_error "无法获取表信息"
        return 1
    }
}

# 显示进程列表
show_processes() {
    log_info "当前活动进程:"
    echo "========================================"
    
    docker exec mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} -e "
        SELECT 
            id as 'ID',
            user as 'User',
            host as 'Host',
            db as 'Database',
            command as 'Command',
            time as 'Time',
            state as 'State',
            info as 'Info'
        FROM information_schema.processlist 
        WHERE command != 'Sleep'
        ORDER BY time DESC;" 2>/dev/null || {
        log_error "无法获取进程信息"
        return 1
    }
}

# 显示慢查询
show_slow_queries() {
    log_info "慢查询统计:"
    echo "========================================"
    
    docker exec mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} -e "
        SELECT 
            COUNT(*) as 'Total_Slow_Queries',
            ROUND(AVG(query_time), 4) as 'Avg_Query_Time',
            MAX(query_time) as 'Max_Query_Time',
            MIN(query_time) as 'Min_Query_Time'
        FROM mysql.slow_log 
        WHERE start_time >= DATE_SUB(NOW(), INTERVAL 24 HOUR);" 2>/dev/null || {
        log_warning "慢查询日志未启用或无法访问"
    }
}

# 显示容器资源使用
show_container_stats() {
    log_info "容器资源使用情况:"
    echo "========================================"
    
    docker stats mysql8.0 --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}" 2>/dev/null || {
        log_error "无法获取容器统计信息"
        return 1
    }
}

# 显示日志文件信息
show_log_info() {
    log_info "日志文件信息:"
    echo "========================================"
    
    local log_dir="../logs"
    
    if [ -d "$log_dir" ]; then
        echo "日志目录: $log_dir"
        echo "----------------------------------------"
        
        for log_file in "$log_dir"/*.log; do
            if [ -f "$log_file" ]; then
                local filename=$(basename "$log_file")
                local size=$(du -h "$log_file" | cut -f1)
                local lines=$(wc -l < "$log_file" 2>/dev/null || echo "N/A")
                echo "$filename: $size, $lines 行"
            fi
        done
    else
        log_warning "日志目录不存在"
    fi
}

# 性能建议
show_performance_tips() {
    log_info "性能优化建议:"
    echo "========================================"
    
    echo "1. 连接数优化:"
    echo "   - 当前连接数: $(docker exec mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} -sN -e "SHOW STATUS LIKE 'Threads_connected';" 2>/dev/null | cut -f2 || echo "N/A")"
    echo "   - 最大连接数: $(docker exec mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} -sN -e "SHOW VARIABLES LIKE 'max_connections';" 2>/dev/null | cut -f2 || echo "N/A")"
    echo
    
    echo "2. 缓冲池使用:"
    echo "   - InnoDB 缓冲池大小: $(docker exec mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} -sN -e "SHOW VARIABLES LIKE 'innodb_buffer_pool_size';" 2>/dev/null | cut -f2 || echo "N/A")"
    echo
    
    echo "3. 查询缓存:"
    echo "   - 查询缓存大小: $(docker exec mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} -sN -e "SHOW VARIABLES LIKE 'query_cache_size';" 2>/dev/null | cut -f2 || echo "N/A")"
    echo
    
    echo "4. 慢查询监控:"
    echo "   - 慢查询日志: $(docker exec mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} -sN -e "SHOW VARIABLES LIKE 'slow_query_log';" 2>/dev/null | cut -f2 || echo "N/A")"
    echo "   - 慢查询阈值: $(docker exec mysql8.0 mysql -u root -p${MYSQL_ROOT_PASSWORD:-123456} -sN -e "SHOW VARIABLES LIKE 'long_query_time';" 2>/dev/null | cut -f2 || echo "N/A") 秒"
}

# 主函数
main() {
    echo "========================================"
    echo "      MySQL 数据库监控脚本"
    echo "========================================"
    echo
    
    # 加载环境变量
    load_env
    
    # 检查 MySQL 容器状态
    if ! docker ps | grep -q mysql8.0; then
        log_error "MySQL 容器未运行，请先启动服务"
        exit 1
    fi
    
    # 检查连接
    if ! check_connection; then
        exit 1
    fi
    
    # 显示监控信息
    show_system_status
    echo
    
    show_variables
    echo
    
    show_database_info
    echo
    
    show_table_info
    echo
    
    show_processes
    echo
    
    show_slow_queries
    echo
    
    show_container_stats
    echo
    
    show_log_info
    echo
    
    show_performance_tips
    
    echo
    log_success "监控信息显示完成！"
}

# 执行主函数
main "$@"
