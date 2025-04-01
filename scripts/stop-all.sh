#!/bin/bash

echo "正在停止项目相关的Node.js进程..."

# 停止前端相关进程，但排除Cursor
pkill -f "vite" 2>/dev/null || true

# 停止后端相关进程，但排除Cursor
pkill -f "node.*backend" 2>/dev/null || true
pkill -f "ts-node" 2>/dev/null || true
pkill -f "nodemon" 2>/dev/null || true

# 只停止项目相关的Node进程，避免终止Cursor IDE
# 列出可能的项目进程并单独终止，而不是使用通用的pkill -f "node"
ps aux | grep -E 'node.*TasksHub' | grep -v grep | awk '{print $2}' | xargs kill 2>/dev/null || true

echo "项目相关的Node.js进程已停止"

# 显示内存状态
echo "当前内存状态:"
free -h 