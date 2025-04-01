#!/bin/bash

# 设置错误时退出
set -e

echo "===== 开始数据库初始化 ====="

# 检查环境变量
if [ -z "$NODE_ENV" ]; then
  export NODE_ENV=development
  echo "未设置NODE_ENV，默认使用development环境"
fi

# 获取当前脚本路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# 根据环境选择对应的Prisma schema文件
if [ "$NODE_ENV" = "production" ]; then
  SCHEMA_FILE="$BASE_DIR/prisma/schema.prisma"
  echo "生产环境: 使用 $SCHEMA_FILE"
elif [ "$NODE_ENV" = "testing" ]; then
  SCHEMA_FILE="$BASE_DIR/prisma/test.prisma"
  echo "测试环境: 使用 $SCHEMA_FILE"
else
  SCHEMA_FILE="$BASE_DIR/prisma/schema.prisma"
  echo "开发环境: 使用 $SCHEMA_FILE"
fi

# 检查schema文件是否存在
if [ ! -f "$SCHEMA_FILE" ]; then
  echo "错误：找不到Prisma Schema文件: $SCHEMA_FILE"
  exit 1
fi

# 检查必要的工具和依赖
command -v npx >/dev/null 2>&1 || { echo "需要 npx 但未安装。请先安装 Node.js。"; exit 1; }

# 显示数据库连接信息
echo "数据库连接信息:"
if [ "$NODE_ENV" = "testing" ]; then
  grep "TEST_DATABASE_URL" $BASE_DIR/.env.testing | sed 's/^TEST_DATABASE_URL=//' || echo "无法获取数据库连接信息"
else
  grep "DATABASE_URL" $BASE_DIR/.env.${NODE_ENV} | sed 's/^DATABASE_URL=//' || echo "无法获取数据库连接信息"
fi

# 生成Prisma客户端
echo "生成Prisma客户端..."
cd $BASE_DIR && npx prisma generate --schema=${SCHEMA_FILE}

# 运行数据库迁移
echo "运行数据库迁移..."
cd $BASE_DIR && npx prisma migrate deploy --schema=${SCHEMA_FILE}

# 检查是否需要导入测试数据
if [ "$1" = "--seed" ] || [ "$NODE_ENV" = "testing" ]; then
  echo "导入种子数据..."
  if [ "$NODE_ENV" = "testing" ]; then
    cd $BASE_DIR && npx ts-node prisma/seed-test.ts
  else
    cd $BASE_DIR && npx ts-node prisma/seed.ts
  fi
fi

echo "===== 数据库初始化完成 =====" 