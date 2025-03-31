#!/bin/bash

# 设置错误时退出
set -e

# 定义项目根目录
PROJECT_ROOT="/home/TasksHub"
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
SCRIPT_DIR="$PROJECT_ROOT/scripts"

# 显示帮助信息
show_help() {
    echo "使用方法: $0 [选项]"
    echo "选项:"
    echo "  --init          初始化数据库"
    echo "  --start-backend 启动后端服务"
    echo "  --start-frontend 启动前端服务"
    echo "  --start-all     启动所有服务"
    echo "  --monitor-db    监控数据库"
    echo "  --backup-db     备份数据库"
    echo "  --restore-db    恢复数据库"
    echo "  --help          显示帮助信息"
}

# 初始化数据库
init_database() {
    echo "=== 初始化数据库 ==="
    # 确保数据库脚本具有执行权限
    chmod +x "$BACKEND_DIR/scripts/init-db.sh"
    # 执行数据库初始化脚本
    cd "$BACKEND_DIR" && ./scripts/init-db.sh --seed
    echo "=== 数据库初始化完成 ==="
}

# 启动后端服务
start_backend() {
    echo "=== 启动后端服务 ==="
    cd "$BACKEND_DIR" && npm run dev &
    echo "=== 后端服务已启动 ==="
}

# 启动前端服务
start_frontend() {
    echo "=== 启动前端服务 ==="
    cd "$FRONTEND_DIR" && npm run dev &
    echo "=== 前端服务已启动 ==="
}

# 监控数据库
monitor_database() {
    echo "=== 监控数据库 ==="
    chmod +x "$BACKEND_DIR/scripts/monitor-db.sh"
    cd "$BACKEND_DIR" && ./scripts/monitor-db.sh
    echo "=== 数据库监控完成 ==="
}

# 备份数据库
backup_database() {
    echo "=== 备份数据库 ==="
    chmod +x "$BACKEND_DIR/scripts/backup-db.sh"
    cd "$BACKEND_DIR" && ./scripts/backup-db.sh
    echo "=== 数据库备份完成 ==="
}

# 恢复数据库
restore_database() {
    echo "=== 恢复数据库 ==="
    chmod +x "$BACKEND_DIR/scripts/restore-db.sh"
    cd "$BACKEND_DIR" && ./scripts/restore-db.sh
    echo "=== 数据库恢复完成 ==="
}

# 处理参数
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# 解析命令行参数
while [ $# -gt 0 ]; do
    case "$1" in
        --init)
            init_database
            shift
            ;;
        --start-backend)
            start_backend
            shift
            ;;
        --start-frontend)
            start_frontend
            shift
            ;;
        --start-all)
            start_backend
            start_frontend
            shift
            ;;
        --monitor-db)
            monitor_database
            shift
            ;;
        --backup-db)
            backup_database
            shift
            ;;
        --restore-db)
            restore_database
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "错误: 未知选项 $1"
            show_help
            exit 1
            ;;
    esac
done

echo "命令执行完成" 