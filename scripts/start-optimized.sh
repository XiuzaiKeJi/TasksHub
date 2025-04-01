#!/bin/bash

# 设置错误时退出
set -e

# 定义颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 定义项目根目录
PROJECT_ROOT="/home/TasksHub"
BACKEND_DIR="$PROJECT_ROOT/backend"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
LOG_DIR="$PROJECT_ROOT/logs"
FRONTEND_LOG="$LOG_DIR/frontend.log"
BACKEND_LOG="$LOG_DIR/backend.log"

# 创建日志目录
mkdir -p "$LOG_DIR"

# 显示帮助信息
show_help() {
    echo -e "${BLUE}优化的开发环境启动脚本${NC}"
    echo "使用方法: $0 [选项]"
    echo "选项:"
    echo "  --backend-only    仅启动后端服务"
    echo "  --frontend-only   仅启动前端服务"
    echo "  --db-only         仅启动数据库服务"
    echo "  --help            显示帮助信息"
    echo ""
    echo "说明: 每次只能启动一个服务以优化内存使用"
    echo "日志文件位置:"
    echo "  前端: $FRONTEND_LOG"
    echo "  后端: $BACKEND_LOG"
}

# 清理内存
clean_memory() {
    echo -e "${YELLOW}正在清理内存缓存...${NC}"
    sync # 将缓存同步到磁盘
    
    # 尝试清理缓存，如果没有权限就跳过
    if [ -w /proc/sys/vm/drop_caches ]; then
        echo 3 > /proc/sys/vm/drop_caches
    else
        echo -e "${YELLOW}无权限清理缓存，跳过此步骤${NC}"
    fi
    
    echo -e "${GREEN}内存缓存已处理${NC}"
}

# 显示内存状态
show_memory() {
    echo -e "${BLUE}当前内存状态:${NC}"
    free -h
}

# 停止之前的Node进程
stop_node_processes() {
    echo -e "${YELLOW}正在停止所有Node.js进程...${NC}"
    pkill -f "node|ts-node" 2>/dev/null || true
    sleep 1
    echo -e "${GREEN}Node.js进程已停止${NC}"
}

# 启动后端服务
start_backend() {
    echo -e "${YELLOW}正在启动后端服务...${NC}"
    
    # 切换到后端目录
    cd "$BACKEND_DIR"
    
    # 设置Node.js内存限制，用--max-old-space-size限制V8引擎的堆内存大小
    echo -e "${GREEN}启动命令: npm run dev:optimized${NC}"
    npm run dev:optimized > "$BACKEND_LOG" 2>&1 &
    
    # 记录PID
    BACKEND_PID=$!
    echo -e "${GREEN}后端服务已启动，PID: $BACKEND_PID${NC}"
    echo -e "${BLUE}可在 http://localhost:3000 访问后端API${NC}"
    echo -e "${YELLOW}查看日志: tail -f $BACKEND_LOG${NC}"
}

# 启动前端服务
start_frontend() {
    echo -e "${YELLOW}正在启动前端服务...${NC}"
    
    # 切换到前端目录
    cd "$FRONTEND_DIR"
    
    # 使用优化版本的开发脚本
    echo -e "${GREEN}启动命令: npm run dev:optimized${NC}"
    npm run dev:optimized > "$FRONTEND_LOG" 2>&1 &
    
    # 记录PID
    FRONTEND_PID=$!
    echo -e "${GREEN}前端服务已启动，PID: $FRONTEND_PID${NC}"
    echo -e "${BLUE}可在 http://localhost:5173 访问前端应用${NC}"
    echo -e "${YELLOW}查看日志: tail -f $FRONTEND_LOG${NC}"
}

# 启动数据库服务
start_db() {
    echo -e "${YELLOW}正在启动数据库服务...${NC}"
    
    # 尝试使用sudo启动MySQL
    if command -v sudo >/dev/null 2>&1; then
        sudo systemctl start mysql && echo -e "${GREEN}数据库服务已启动${NC}" || echo -e "${RED}启动数据库失败${NC}"
    else
        echo -e "${RED}无法启动数据库: 缺少sudo权限${NC}"
    fi
}

# 处理参数
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# 清理内存和停止旧进程
clean_memory
stop_node_processes
show_memory

# 解析命令行参数
while [ $# -gt 0 ]; do
    case "$1" in
        --backend-only)
            start_backend
            shift
            ;;
        --frontend-only)
            start_frontend
            shift
            ;;
        --db-only)
            start_db
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}错误: 未知选项 $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

echo -e "${GREEN}命令执行完成${NC}"
show_memory 