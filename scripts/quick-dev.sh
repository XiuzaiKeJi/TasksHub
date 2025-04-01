#!/bin/bash

# TasksHub项目 - 快速开发脚本
# 用于简化开发流程，提高开发效率

# 设置颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 快速更新和提交
function quick-update() {
  echo -e "${BLUE}执行快速更新和提交...${NC}"
  if [ -z "$1" ]; then
    echo -e "${RED}错误: 请提供提交信息${NC}"
    echo -e "用法: quick-update \"提交信息\""
    return 1
  fi
  
  git pull
  git add .
  git commit -m "update: $1"
  git push
  echo -e "${GREEN}更新完成!${NC}"
}

# 快速切换分支并同步
function quick-switch() {
  echo -e "${BLUE}执行快速分支切换...${NC}"
  if [ -z "$1" ]; then
    echo -e "${RED}错误: 请提供分支名称${NC}"
    echo -e "用法: quick-switch branch-name"
    return 1
  fi
  
  git checkout $1
  git pull origin $1
  echo -e "${GREEN}已切换到分支 $1 并更新!${NC}"
}

# 快速修复并推送
function quick-fix() {
  echo -e "${BLUE}执行快速修复...${NC}"
  if [ -z "$1" ]; then
    echo -e "${RED}错误: 请提供修复描述${NC}"
    echo -e "用法: quick-fix \"修复描述\""
    return 1
  fi
  
  git add .
  git commit -m "fix: $1"
  git push
  echo -e "${GREEN}修复已提交并推送!${NC}"
}

# 快速环境设置
function quick-setup() {
  echo -e "${BLUE}执行快速环境设置...${NC}"
  ./scripts/init-session.sh
  echo -e "${GREEN}环境设置完成!${NC}"
}

# 快速启动服务
function quick-start() {
  echo -e "${BLUE}执行快速服务启动...${NC}"
  ./scripts/manage-services.sh start-db
  ./scripts/manage-services.sh start-backend
  echo -e "${GREEN}服务已启动!${NC}"
}

# 快速停止服务
function quick-stop() {
  echo -e "${BLUE}执行快速服务停止...${NC}"
  ./scripts/manage-services.sh stop-safe
  echo -e "${GREEN}服务已安全停止!${NC}"
}

# 显示帮助信息
function show-help() {
  echo -e "${BLUE}TasksHub 快速开发脚本 - 帮助${NC}"
  echo -e "可用命令:"
  echo -e "  ${GREEN}quick-update \"提交信息\"${NC} - 快速更新、提交和推送"
  echo -e "  ${GREEN}quick-switch branch-name${NC} - 快速切换分支并同步"
  echo -e "  ${GREEN}quick-fix \"修复描述\"${NC} - 快速修复并推送"
  echo -e "  ${GREEN}quick-setup${NC} - 快速环境设置"
  echo -e "  ${GREEN}quick-start${NC} - 快速启动服务"
  echo -e "  ${GREEN}quick-stop${NC} - 快速停止服务"
}

# 根据参数执行相应功能
case "$1" in
  update)
    quick-update "$2"
    ;;
  switch)
    quick-switch "$2"
    ;;
  fix)
    quick-fix "$2"
    ;;
  setup)
    quick-setup
    ;;
  start)
    quick-start
    ;;
  stop)
    quick-stop
    ;;
  *)
    show-help
    ;;
esac 