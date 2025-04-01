#!/bin/bash

# Cursor工具脚本 - 提供安全执行命令的包装
# 用法: ./cursor-tool.sh [command] [args]

# 设置颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 定义项目根目录
PROJECT_ROOT="/home/TasksHub"
CONFIG_FILE="$PROJECT_ROOT/.cursor-agent-config.json"

# 显示帮助信息
show_help() {
    echo -e "${BLUE}Cursor 安全命令执行工具${NC}"
    echo "用法: $0 [命令]"
    echo ""
    echo "命令:"
    echo "  run [cmd]       安全执行命令，阻止危险操作"
    echo "  service [cmd]   服务管理命令简写 (启动、停止等)"
    echo "  git [cmd]       Git安全操作命令"
    echo "  check-memory    检查内存状态"
    echo "  init-session    初始化新的开发会话"
    echo "  help            显示此帮助信息"
    echo ""
    echo "示例: $0 run 'git status'"
    echo "      $0 service start-backend"
    echo "      $0 git status"
}

# 检查危险命令
is_dangerous_command() {
    local cmd="$1"
    local dangerous_patterns=(
        "kill -9"
        "killall"
        "pkill"
        "rm -rf"
        "tail -f"
        "top\$"
    )

    for pattern in "${dangerous_patterns[@]}"; do
        if [[ "$cmd" =~ $pattern ]]; then
            return 0 # 是危险命令
        fi
    done
    return 1 # 不是危险命令
}

# 安全执行命令
safe_run() {
    if [ -z "$1" ]; then
        echo -e "${RED}错误: 未提供要执行的命令${NC}"
        show_help
        return 1
    fi

    local cmd="$1"
    
    # 检查危险命令
    if is_dangerous_command "$cmd"; then
        echo -e "${RED}警告: 检测到危险命令: '$cmd'${NC}"
        echo -e "${YELLOW}这可能会导致IDE断链或其他问题${NC}"
        echo -e "建议使用项目提供的安全脚本替代此命令"
        echo -e "例如:"
        echo -e " - 使用 './scripts/manage-services.sh stop-safe' 停止服务"
        echo -e " - 使用 './scripts/git-wrapper.sh' 进行Git操作"
        
        read -p "是否仍要执行此命令? (y/N) " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}已取消执行${NC}"
            return 0
        fi
        
        echo -e "${YELLOW}将执行危险命令，请注意可能的后果...${NC}"
    else
        echo -e "${GREEN}执行命令: $cmd${NC}"
    fi
    
    # 执行命令
    eval "$cmd"
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        echo -e "${RED}命令执行失败，退出代码: $exit_code${NC}"
    else
        echo -e "${GREEN}命令执行成功${NC}"
    fi
    
    return $exit_code
}

# 服务管理命令简写
service_command() {
    if [ -z "$1" ]; then
        echo -e "${RED}错误: 未提供服务命令${NC}"
        echo -e "可用选项: start-frontend, start-backend, start-db, stop-safe, status, logs-frontend, logs-backend"
        return 1
    fi
    
    local cmd="$1"
    echo -e "${BLUE}执行服务命令: $cmd${NC}"
    
    # 检查内存使用情况
    if [[ "$cmd" == start-* ]]; then
        echo -e "${YELLOW}检查内存状态:${NC}"
        free -h | grep 'Mem:'
        local free_mem=$(free -m | awk 'NR==2{print $7}')
        if [ $free_mem -lt 200 ]; then
            echo -e "${RED}警告: 可用内存不足 ($free_mem MB)${NC}"
            echo -e "建议先停止其他服务或释放内存"
            read -p "是否仍要继续? (y/N) " confirm
            if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
                echo -e "${BLUE}已取消操作${NC}"
                return 0
            fi
        fi
    fi
    
    # 执行服务管理脚本
    "$PROJECT_ROOT/scripts/manage-services.sh" "$cmd"
}

# Git安全操作
git_command() {
    if [ -z "$1" ]; then
        echo -e "${RED}错误: 未提供Git命令${NC}"
        echo -e "示例: $0 git status"
        return 1
    fi
    
    local cmd="$1"
    shift
    local args="$@"
    
    echo -e "${BLUE}执行Git命令: $cmd $args${NC}"
    
    # 使用Git包装脚本
    if [ -f "$PROJECT_ROOT/scripts/git-wrapper.sh" ]; then
        "$PROJECT_ROOT/scripts/git-wrapper.sh" "$cmd" "$@"
    else
        # 或使用快速Git命令
        case "$cmd" in
            status)
                git faststatus
                ;;
            commit)
                git fastcommit "$@"
                ;;
            push)
                git fastpush "$@"
                ;;
            *)
                git "$cmd" "$@"
                ;;
        esac
    fi
}

# 检查内存状态
check_memory() {
    echo -e "${BLUE}内存使用状态:${NC}"
    free -h
    
    echo -e "\n${BLUE}内存占用最多的进程:${NC}"
    ps aux --sort=-%mem | head -6
    
    # 额外内存建议
    local free_mem=$(free -m | awk 'NR==2{print $7}')
    if [ $free_mem -lt 200 ]; then
        echo -e "\n${YELLOW}内存状态紧张 (可用: $free_mem MB)${NC}"
        echo -e "建议采取的措施:"
        echo -e " - 使用 './scripts/manage-services.sh stop-db' 停止不需要的数据库"
        echo -e " - 使用 './scripts/manage-services.sh stop-safe' 停止所有服务"
        echo -e " - 一次只运行一个服务 (前端或后端)"
    else
        echo -e "\n${GREEN}内存状态良好 (可用: $free_mem MB)${NC}"
    fi
}

# 初始化会话
init_session() {
    echo -e "${BLUE}初始化开发会话...${NC}"
    
    # 检查服务状态
    echo -e "\n${YELLOW}当前服务状态:${NC}"
    "$PROJECT_ROOT/scripts/manage-services.sh" status
    
    # 检查Git状态
    echo -e "\n${YELLOW}当前Git分支:${NC}"
    if [ -f "$PROJECT_ROOT/scripts/git-wrapper.sh" ]; then
        "$PROJECT_ROOT/scripts/git-wrapper.sh" branch
    else
        git branch
    fi
    
    # 显示可用命令
    echo -e "\n${GREEN}开发环境就绪${NC}"
    echo -e "推荐使用以下命令:"
    echo -e " - ./scripts/manage-services.sh [命令]  管理服务"
    echo -e " - ./scripts/git-wrapper.sh [命令]      安全Git操作"
    echo -e " - ./cursor-tool.sh [命令]              Cursor助手工具"
}

# 主函数
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

command="$1"
shift

case "$command" in
    run)
        safe_run "$*"
        ;;
    service)
        service_command "$1"
        ;;
    git)
        git_command "$@"
        ;;
    check-memory)
        check_memory
        ;;
    init-session)
        init_session
        ;;
    help)
        show_help
        ;;
    *)
        echo -e "${RED}错误: 未知命令 $command${NC}"
        show_help
        exit 1
        ;;
esac 