#!/bin/bash

# 定义目录
FRONTEND_DIR="/home/TasksHub/frontend"
LOG_DIR="/home/TasksHub/logs"
FRONTEND_LOG="$LOG_DIR/frontend.log"

# 确保日志目录存在
mkdir -p "$LOG_DIR"

# 显示内存状态
echo "当前内存状态:"
free -h

# 停止可能运行的前端进程
echo "正在停止可能运行的Node.js进程..."
pkill -f "vite" 2>/dev/null || true
sleep 1

# 切换到前端目录
cd "$FRONTEND_DIR"

# 设置最低限度的Vite内存配置
echo "正在启动前端服务(最小内存模式)..."
export NODE_OPTIONS="--max-old-space-size=256"
export VITE_MEMORY_LIMIT=true
npx --no-install vite --port 5173 --host localhost &> "$FRONTEND_LOG" &

# 记录PID
FRONTEND_PID=$!
echo "前端服务已启动，PID: $FRONTEND_PID"
echo "可在 http://localhost:5173 访问前端应用"
echo "查看日志: tail -f $FRONTEND_LOG"

# 稍等一下确认服务是否启动
sleep 3
echo "检查前端服务是否成功启动..."
if ps -p $FRONTEND_PID > /dev/null; then
    echo "前端服务正在运行"
    echo "最新日志内容:"
    tail -n 10 "$FRONTEND_LOG"
else
    echo "警告: 前端服务可能未成功启动"
    echo "日志内容:"
    cat "$FRONTEND_LOG"
fi

# 再次显示内存状态
echo "启动后内存状态:"
free -h 