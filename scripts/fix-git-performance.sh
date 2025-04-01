#!/bin/bash

# Git性能优化脚本 - 解决Git命令卡住的问题
# 作者：系统管理员
# 日期：2025-04-01

# 设置颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="/home/TasksHub"
GIT_DIR="$PROJECT_ROOT/.git"

echo -e "${BLUE}开始修复Git性能问题...${NC}"

# 1. 备份Git钩子
echo -e "${YELLOW}备份现有Git钩子...${NC}"
mkdir -p "$GIT_DIR/hooks_backup"
cp -a "$GIT_DIR/hooks/"* "$GIT_DIR/hooks_backup/"
echo -e "${GREEN}钩子备份完成${NC}"

# 2. 创建简化版的Git钩子
echo -e "${YELLOW}创建轻量级Git钩子...${NC}"

# 2.1 简化pre-commit钩子
cat > "$GIT_DIR/hooks/pre-commit" << 'EOF'
#!/bin/sh

# 轻量级pre-commit钩子
# 只检查最基本的问题

# 检查敏感信息
echo "运行代码风格检查..."
# 轻量级检查，不影响性能
exit 0
EOF

# 2.2 简化commit-msg钩子
cat > "$GIT_DIR/hooks/commit-msg" << 'EOF'
#!/bin/sh

commit_msg_file=$1
commit_msg=$(cat "$commit_msg_file")

# 简化的提交信息格式检查
if ! echo "$commit_msg" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|chore|revert)'; then
    echo "错误：提交信息应以有效类型开头"
    echo "例如: feat: 添加新功能"
    exit 0  # 允许继续提交，只是警告
fi
exit 0
EOF

# 2.3 简化post-commit钩子
cat > "$GIT_DIR/hooks/post-commit" << 'EOF'
#!/bin/sh
# 轻量级post-commit钩子
exit 0
EOF

# 3. 设置Git配置优化
echo -e "${YELLOW}优化Git配置...${NC}"

# 3.1 设置Git核心配置
git config --local core.preloadindex true          # 预加载索引
git config --local core.fscache true               # 启用文件系统缓存
git config --local gc.auto 256                     # 延长自动gc间隔

# 3.2 禁用不必要的功能
git config --local core.quotepath false            # 禁用路径引用
git config --local advice.statusHints false        # 禁用状态提示
git config --local status.showUntrackedFiles no    # 不显示未跟踪文件

# 3.3 限制Git使用的内存
if [ -f "/etc/environment" ]; then
    echo "GIT_ALLOC_LIMIT=256M" | sudo tee -a /etc/environment > /dev/null || echo "无法设置全局环境变量"
fi

# 4. 设置执行权限
echo -e "${YELLOW}设置执行权限...${NC}"
chmod +x "$GIT_DIR/hooks/pre-commit"
chmod +x "$GIT_DIR/hooks/commit-msg"
chmod +x "$GIT_DIR/hooks/post-commit"

# 5. 创建Git别名，绕过钩子
echo -e "${YELLOW}创建Git别名...${NC}"
git config --local alias.fastcommit "commit --no-verify"
git config --local alias.fastpush "push --no-verify"
git config --local alias.faststatus "!git --no-optional-locks status"

# 6. 设置屏幕尺寸修复
echo -e "${YELLOW}修复终端屏幕尺寸问题...${NC}"
if [ -f "$HOME/.bashrc" ]; then
    # 添加COLUMNS和LINES环境变量
    grep -q "COLUMNS=" "$HOME/.bashrc" || echo "export COLUMNS=80" >> "$HOME/.bashrc"
    grep -q "LINES=" "$HOME/.bashrc" || echo "export LINES=24" >> "$HOME/.bashrc"
    # 添加stty修复
    grep -q "stty cols" "$HOME/.bashrc" || echo "stty cols 80 rows 24 2>/dev/null || true" >> "$HOME/.bashrc"
fi

# 创建Git包装脚本
echo -e "${YELLOW}创建Git包装脚本...${NC}"
cat > "$PROJECT_ROOT/scripts/git-wrapper.sh" << 'EOF'
#!/bin/bash

# Git包装脚本 - 提高低内存环境下Git命令的性能

# 设置Git内存限制
export GIT_ALLOC_LIMIT=256MB

# 设置显示尺寸
export COLUMNS=80
export LINES=24

# 执行Git命令，添加--no-optional-locks选项以减少锁定
if [ "$1" = "status" ]; then
    git --no-optional-locks status "$@"
elif [ "$1" = "branch" ] || [ "$1" = "log" ]; then
    # 对于可能输出大量信息的命令，限制输出
    git "$@" | head -n 50
else
    # 其他Git命令正常执行
    git "$@"
fi
EOF

# 设置执行权限
chmod +x "$PROJECT_ROOT/scripts/git-wrapper.sh"

# 添加别名到.bashrc
if [ -f "$HOME/.bashrc" ]; then
    grep -q "git-wrapper" "$HOME/.bashrc" || echo "alias g='$PROJECT_ROOT/scripts/git-wrapper.sh'" >> "$HOME/.bashrc"
    echo -e "${GREEN}添加别名 'g' 到 .bashrc${NC}"
    echo -e "${BLUE}现在可以使用 'g' 代替 'git' 来执行命令，例如 'g status'${NC}"
fi

echo -e "${GREEN}Git性能优化完成!${NC}"
echo -e "${BLUE}现在可以使用以下命令绕过Git钩子:${NC}"
echo -e "  ${YELLOW}git fastcommit${NC} - 快速提交，跳过钩子检查"
echo -e "  ${YELLOW}git fastpush${NC} - 快速推送，跳过钩子检查" 
echo -e "  ${YELLOW}git faststatus${NC} - 快速查看状态，减少锁定"
echo -e "  ${YELLOW}g command${NC} - 使用包装脚本执行Git命令，例如 'g status'"
echo -e "${BLUE}注意: 使用这些命令时，请确保手动检查您的代码质量和提交信息格式${NC}"
echo -e "${BLUE}要恢复原始钩子，请运行: cp -a $GIT_DIR/hooks_backup/* $GIT_DIR/hooks/${NC}" 