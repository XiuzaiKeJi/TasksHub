#!/bin/bash

# 定义目录
BACKEND_DIR="/home/TasksHub/backend"
LOG_DIR="/home/TasksHub/logs"
BACKEND_LOG="$LOG_DIR/backend.log"

# 确保日志目录存在
mkdir -p "$LOG_DIR"

# 显示内存状态
echo "当前内存状态:"
free -h

# 停止可能运行的后端进程
echo "正在停止可能运行的Node.js进程..."
pkill -f "node.*backend" 2>/dev/null || true
sleep 1

# 切换到后端目录
cd "$BACKEND_DIR"

# 设置最低限度的Node.js内存配置
echo "正在启动后端服务(最小内存模式)..."
export NODE_OPTIONS="--max-old-space-size=256"
npx --no-install nodemon --exec "ts-node --transpile-only" src/index.ts &> "$BACKEND_LOG" &

# 记录PID
BACKEND_PID=$!
echo "后端服务已启动，PID: $BACKEND_PID"
echo "可在 http://localhost:3000 访问后端API"
echo "查看日志: tail -f $BACKEND_LOG"

# 稍等一下确认服务是否启动
sleep 3
echo "检查后端服务是否成功启动..."
if ps -p $BACKEND_PID > /dev/null; then
    echo "后端服务正在运行"
    echo "最新日志内容:"
    tail -n 10 "$BACKEND_LOG"
else
    echo "警告: 后端服务可能未成功启动"
    echo "日志内容:"
    cat "$BACKEND_LOG"
fi

# 再次显示内存状态
echo "启动后内存状态:"
free -h 