#!/bin/bash

# TasksHub项目 - IDE会话初始化脚本
# 用于在IDE启动时初始化环境，设置别名和环境变量

# 设置颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 定义项目根目录
PROJECT_ROOT="/home/TasksHub"
INSTRUCTIONS_FILE="$PROJECT_ROOT/.cursor/agent-instructions.md"
PITFALLS_FILE="$PROJECT_ROOT/docs/common-pitfalls.md"

# 显示欢迎信息
echo -e "${BLUE}=================================${NC}"
echo -e "${GREEN}TasksHub 项目环境初始化${NC}"
echo -e "${BLUE}=================================${NC}"

# 设置环境变量
export TASKSHUB_ENV="development"
export CURSOR_SAFE_COMMANDS=true
export NODE_OPTIONS="--max-old-space-size=256"
export GIT_ALLOC_LIMIT=256M

# 添加命令别名
alias start-db="$PROJECT_ROOT/scripts/manage-services.sh start-db"
alias start-backend="$PROJECT_ROOT/scripts/manage-services.sh start-backend"
alias start-frontend="$PROJECT_ROOT/scripts/manage-services.sh start-frontend"
alias stop-safe="$PROJECT_ROOT/scripts/manage-services.sh stop-safe"
alias status="$PROJECT_ROOT/scripts/manage-services.sh status"
alias memory="$PROJECT_ROOT/scripts/manage-services.sh memory"
alias logs-backend="$PROJECT_ROOT/scripts/manage-services.sh logs-backend"
alias logs-frontend="$PROJECT_ROOT/scripts/manage-services.sh logs-frontend"

alias g="$PROJECT_ROOT/scripts/git-wrapper.sh"
alias gst="$PROJECT_ROOT/scripts/git-wrapper.sh status"
alias gbr="$PROJECT_ROOT/scripts/git-wrapper.sh branch"

alias ct="$PROJECT_ROOT/scripts/cursor-tool.sh"

# 检查服务状态
echo -e "\n${YELLOW}检查服务状态...${NC}"
$PROJECT_ROOT/scripts/manage-services.sh status > /dev/null 2>&1

# 检查内存状态
echo -e "\n${YELLOW}检查内存状态...${NC}"
free -h | grep 'Mem:'
available_mem=$(free -m | awk 'NR==2{print $7}')

if [ $available_mem -lt 200 ]; then
    echo -e "${RED}警告: 可用内存不足 ($available_mem MB)${NC}"
    echo -e "建议停止不必要的服务释放内存"
    echo -e "例如: ./scripts/manage-services.sh stop-db"
else
    echo -e "${GREEN}内存状态良好 (可用: $available_mem MB)${NC}"
fi

# 检查Git状态
echo -e "\n${YELLOW}检查Git状态...${NC}"
current_branch=$($PROJECT_ROOT/scripts/git-wrapper.sh branch 2> /dev/null | grep '\*' | sed 's/\* //')

if [ -n "$current_branch" ]; then
    echo -e "当前分支: ${GREEN}$current_branch${NC}"
else
    echo -e "${RED}无法获取当前分支信息${NC}"
fi

# 显示可用命令和别名
echo -e "\n${BLUE}已设置以下别名:${NC}"
echo -e "  ${GREEN}start-db${NC}        - 启动数据库"
echo -e "  ${GREEN}start-backend${NC}   - 启动后端服务"
echo -e "  ${GREEN}start-frontend${NC}  - 启动前端服务"
echo -e "  ${GREEN}stop-safe${NC}       - 安全停止所有服务"
echo -e "  ${GREEN}status${NC}          - 查看服务状态"
echo -e "  ${GREEN}memory${NC}          - 查看内存状态"
echo -e "  ${GREEN}logs-backend${NC}    - 查看后端日志"
echo -e "  ${GREEN}logs-frontend${NC}   - 查看前端日志"
echo -e "  ${GREEN}g${NC}               - Git包装命令 (例如: g status)"
echo -e "  ${GREEN}gst${NC}             - Git状态"
echo -e "  ${GREEN}gbr${NC}             - Git分支列表"
echo -e "  ${GREEN}ct${NC}              - Cursor工具 (例如: ct help)"

# 显示Agent指令文件位置
if [ -f "$INSTRUCTIONS_FILE" ]; then
    echo -e "\n${BLUE}Agent指令文件:${NC} ${GREEN}$INSTRUCTIONS_FILE${NC}"
    echo -e "建议AI Agent在每次会话开始时阅读此文件"
fi

# 显示常见问题文件位置
if [ -f "$PITFALLS_FILE" ]; then
    echo -e "${BLUE}常见问题文档:${NC} ${GREEN}$PITFALLS_FILE${NC}"
    echo -e "遇到问题时可以参考此文档"
fi

echo -e "\n${GREEN}环境初始化完成!${NC}"
echo -e "推荐使用 ${YELLOW}./scripts/cursor-tool.sh init-session${NC} 获取详细项目状态"
echo -e "${BLUE}=================================${NC}"

# 添加这些别名到当前会话
echo "以上别名已在当前会话设置。要在未来会话中使用，请将此脚本添加到您的~/.bashrc" 