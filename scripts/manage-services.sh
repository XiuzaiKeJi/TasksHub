#!/bin/bash

# 设置颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 定义目录
PROJECT_ROOT="/home/TasksHub"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_DIR="$PROJECT_ROOT/backend"
LOG_DIR="$PROJECT_ROOT/logs"
FRONTEND_LOG="$LOG_DIR/frontend.log"
BACKEND_LOG="$LOG_DIR/backend.log"

# 确保日志目录存在
mkdir -p "$LOG_DIR"

# 显示帮助信息
show_help() {
    echo -e "${BLUE}TasksHub服务管理脚本${NC}"
    echo "使用方法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  start-frontend  启动前端服务（最小内存模式）"
    echo "  start-backend   启动后端服务（最小内存模式）"
    echo "  start-db        启动数据库服务"
    echo "  stop-db         停止数据库服务"
    echo "  status          显示服务状态"
    echo "  stop-frontend   停止前端服务"
    echo "  stop-backend    停止后端服务"
    echo "  stop-safe       安全地停止所有项目服务（不影响IDE）"
    echo "  memory          显示内存状态"
    echo "  logs-frontend   查看前端日志"
    echo "  logs-backend    查看后端日志"
    echo "  help            显示此帮助信息"
    echo ""
    echo "示例: $0 start-frontend"
}

# 显示内存状态
show_memory() {
    echo -e "${BLUE}当前内存状态:${NC}"
    free -h
    echo ""
    echo -e "${BLUE}内存消耗最大的进程:${NC}"
    ps aux --sort=-%mem | head -6
}

# 安全停止前端进程
stop_frontend() {
    echo -e "${YELLOW}正在停止前端进程...${NC}"
    # 查找前端进程
    local frontend_pids=$(ps aux | grep -E "vite|node.*frontend" | grep -v grep | awk '{print $2}')
    if [ -n "$frontend_pids" ]; then
        echo -e "${YELLOW}发现前端进程: $frontend_pids${NC}"
        kill $frontend_pids 2>/dev/null || true
        echo -e "${GREEN}前端进程已停止${NC}"
    else
        echo -e "${BLUE}未发现运行中的前端进程${NC}"
    fi
}

# 安全停止后端进程
stop_backend() {
    echo -e "${YELLOW}正在停止后端进程...${NC}"
    # 查找后端进程
    local backend_pids=$(ps aux | grep -E "node.*backend|ts-node|nodemon" | grep -v grep | awk '{print $2}')
    if [ -n "$backend_pids" ]; then
        echo -e "${YELLOW}发现后端进程: $backend_pids${NC}"
        kill $backend_pids 2>/dev/null || true
        echo -e "${GREEN}后端进程已停止${NC}"
    else
        echo -e "${BLUE}未发现运行中的后端进程${NC}"
    fi
}

# 安全停止所有项目进程
stop_safe() {
    echo -e "${YELLOW}正在安全停止所有项目进程...${NC}"
    stop_frontend
    stop_backend
    # 额外检查是否有遗漏的项目进程，但避免停止IDE进程
    local project_pids=$(ps aux | grep -E "node.*TasksHub" | grep -v "cursor|Cursor|IDE|ide|code-server" | grep -v grep | awk '{print $2}')
    if [ -n "$project_pids" ]; then
        echo -e "${YELLOW}发现其他项目进程: $project_pids${NC}"
        kill $project_pids 2>/dev/null || true
    fi
    echo -e "${GREEN}项目进程已安全停止${NC}"
    show_memory
}

# 显示服务状态
show_status() {
    echo -e "${BLUE}服务状态:${NC}"
    echo -e "${YELLOW}前端服务:${NC}"
    ps aux | grep -E "vite|node.*frontend" | grep -v grep || echo "未运行"
    echo -e "${YELLOW}后端服务:${NC}"
    ps aux | grep -E "node.*backend|ts-node|nodemon" | grep -v grep || echo "未运行"
    echo ""
    show_memory
}

# 启动前端服务
start_frontend() {
    # 先停止可能正在运行的前端进程
    stop_frontend
    
    echo -e "${YELLOW}正在启动前端服务(最小内存模式)...${NC}"
    cd "$FRONTEND_DIR"
    
    # 设置最低限度的Vite内存配置
    export NODE_OPTIONS="--max-old-space-size=256"
    export VITE_MEMORY_LIMIT=true
    
    # 使用npx直接启动vite，避免额外的npm开销
    echo -e "${BLUE}启动命令: npx --no-install vite --port 5173 --host localhost${NC}"
    npx --no-install vite --port 5173 --host localhost &> "$FRONTEND_LOG" &
    
    # 记录PID
    FRONTEND_PID=$!
    echo -e "${GREEN}前端服务已启动，PID: $FRONTEND_PID${NC}"
    echo -e "${BLUE}可在 http://localhost:5173 访问前端应用${NC}"
    echo -e "${YELLOW}查看日志: $0 logs-frontend${NC}"
    
    # 稍等一下确认服务是否启动
    sleep 3
    if ps -p $FRONTEND_PID > /dev/null; then
        echo -e "${GREEN}前端服务正在运行${NC}"
    else
        echo -e "${RED}警告: 前端服务可能未成功启动${NC}"
        echo -e "${YELLOW}日志内容:${NC}"
        tail -n 10 "$FRONTEND_LOG"
    fi
}

# 启动后端服务
start_backend() {
    # 先停止可能正在运行的后端进程
    stop_backend
    
    echo -e "${YELLOW}正在启动后端服务(最小内存模式)...${NC}"
    cd "$BACKEND_DIR"
    
    # 设置最低限度的Node.js内存配置
    export NODE_OPTIONS="--max-old-space-size=256"
    
    # 使用最轻量的方式启动ts-node
    echo -e "${BLUE}启动命令: npx --no-install ts-node --transpile-only src/index.ts${NC}"
    npx --no-install ts-node --transpile-only src/index.ts &> "$BACKEND_LOG" &
    
    # 记录PID
    BACKEND_PID=$!
    echo -e "${GREEN}后端服务已启动，PID: $BACKEND_PID${NC}"
    echo -e "${BLUE}可在 http://localhost:3000 访问后端API${NC}"
    echo -e "${YELLOW}查看日志: $0 logs-backend${NC}"
    
    # 稍等一下确认服务是否启动
    sleep 3
    if ps -p $BACKEND_PID > /dev/null; then
        echo -e "${GREEN}后端服务正在运行${NC}"
    else
        echo -e "${RED}警告: 后端服务可能未成功启动${NC}"
        echo -e "${YELLOW}日志内容:${NC}"
        tail -n 10 "$BACKEND_LOG"
    fi
}

# 启动数据库服务
start_db() {
    echo -e "${YELLOW}正在启动数据库服务...${NC}"
    
    # 尝试使用sudo启动MySQL
    if command -v sudo >/dev/null 2>&1; then
        sudo systemctl start mysql && echo -e "${GREEN}数据库服务已启动${NC}" || echo -e "${RED}启动数据库失败${NC}"
        
        # 显示MySQL内存使用
        echo -e "${BLUE}MySQL内存使用情况:${NC}"
        ps aux | grep mysql | grep -v grep || echo -e "${RED}未找到MySQL进程${NC}"
    else
        echo -e "${RED}无法启动数据库: 缺少sudo权限${NC}"
    fi
}

# 停止数据库服务
stop_db() {
    echo -e "${YELLOW}正在停止数据库服务...${NC}"
    
    # 尝试使用sudo停止MySQL
    if command -v sudo >/dev/null 2>&1; then
        sudo systemctl stop mysql && echo -e "${GREEN}数据库服务已停止${NC}" || echo -e "${RED}停止数据库失败${NC}"
    else
        echo -e "${RED}无法停止数据库: 缺少sudo权限${NC}"
    fi
    
    show_memory
}

# 查看前端日志
logs_frontend() {
    echo -e "${BLUE}前端日志:${NC}"
    if [ -f "$FRONTEND_LOG" ]; then
        tail -n 20 -f "$FRONTEND_LOG"
    else
        echo -e "${RED}前端日志文件不存在${NC}"
    fi
}

# 查看后端日志
logs_backend() {
    echo -e "${BLUE}后端日志:${NC}"
    if [ -f "$BACKEND_LOG" ]; then
        tail -n 20 -f "$BACKEND_LOG"
    else
        echo -e "${RED}后端日志文件不存在${NC}"
    fi
}

# 主函数 - 处理命令行参数
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

case "$1" in
    start-frontend)
        start_frontend
        ;;
    start-backend)
        start_backend
        ;;
    start-db)
        start_db
        ;;
    status)
        show_status
        ;;
    stop-frontend)
        stop_frontend
        show_memory
        ;;
    stop-backend)
        stop_backend
        show_memory
        ;;
    stop-db)
        stop_db
        ;;
    stop-safe)
        stop_safe
        ;;
    memory)
        show_memory
        ;;
    logs-frontend)
        logs_frontend
        ;;
    logs-backend)
        logs_backend
        ;;
    help)
        show_help
        ;;
    *)
        echo -e "${RED}错误: 未知命令 $1${NC}"
        show_help
        exit 1
        ;;
esac 