#!/bin/bash

# Git包装脚本 - 提高低内存环境下Git命令的性能

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
