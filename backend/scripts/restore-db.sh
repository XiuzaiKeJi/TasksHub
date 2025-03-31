#!/bin/bash

# 设置错误时退出
set -e

# 配置参数
DB_HOST="localhost"
DB_PORT="3306"
BACKUP_DIR="../backups"

# 检查环境变量
if [ -z "$NODE_ENV" ]; then
  export NODE_ENV=development
  echo "未设置NODE_ENV，默认使用development环境"
fi

# 根据环境选择数据库
if [ "$NODE_ENV" = "production" ]; then
  DB_NAME="taskshub"
  ENV_FILE="../.env.production"
elif [ "$NODE_ENV" = "testing" ]; then
  DB_NAME="taskshub_test"
  ENV_FILE="../.env.testing"
else
  DB_NAME="taskshub_dev"
  ENV_FILE="../.env"
fi

# 从环境文件中读取数据库连接信息
if [ -f "$ENV_FILE" ]; then
  # 尝试从环境文件中读取用户名和密码
  DB_USER=$(grep "DB_USERNAME" $ENV_FILE | cut -d= -f2)
  DB_PASSWORD=$(grep "DB_PASSWORD" $ENV_FILE | cut -d= -f2)
  
  # 如果未找到，使用默认值
  if [ -z "$DB_USER" ]; then DB_USER="root"; fi
  if [ -z "$DB_PASSWORD" ]; then DB_PASSWORD="password"; fi
else
  echo "警告: 未找到环境文件 $ENV_FILE，使用默认连接信息"
  DB_USER="root"
  DB_PASSWORD="password"
fi

# 检查备份目录是否存在
if [ ! -d "$BACKUP_DIR" ]; then
  echo "错误: 备份目录 $BACKUP_DIR 不存在"
  exit 1
fi

# 显示可用备份
echo "可用备份文件:"
ls -lt $BACKUP_DIR/${DB_NAME}_backup_*.sql.gz 2>/dev/null || echo "没有找到备份文件"

# 如果指定了备份文件，使用该文件
if [ -n "$1" ]; then
  BACKUP_FILE="$BACKUP_DIR/$1"
  
  # 检查文件是否存在
  if [ ! -f "$BACKUP_FILE" ]; then
    echo "错误: 备份文件 $BACKUP_FILE 不存在"
    exit 1
  fi
else
  # 使用最新的备份文件
  BACKUP_FILE=$(ls -t $BACKUP_DIR/${DB_NAME}_backup_*.sql.gz | head -n 1)
  
  if [ -z "$BACKUP_FILE" ]; then
    echo "错误: 未找到备份文件"
    exit 1
  fi
fi

echo "===== 开始恢复数据库 $DB_NAME 从 $BACKUP_FILE ====="

# 确认恢复操作
read -p "警告: 这将覆盖 $DB_NAME 数据库中的所有数据。是否继续? [y/N] " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
  echo "操作已取消"
  exit 0
fi

# 解压备份文件
echo "解压备份文件..."
TEMP_SQL_FILE="${BACKUP_FILE%.gz}"
gunzip -c $BACKUP_FILE > $TEMP_SQL_FILE

# 恢复数据库
echo "恢复数据库 $DB_NAME..."
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME < $TEMP_SQL_FILE

# 清理临时文件
echo "清理临时文件..."
rm $TEMP_SQL_FILE

echo "===== 数据库恢复完成 =====" 