#!/bin/bash

# 设置错误时退出
set -e

# 获取当前日期作为备份文件名
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# 配置参数
DB_HOST="localhost"
DB_PORT="3306"
BACKUP_DIR="../backups"
RETENTION_DAYS=7

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

echo "===== 开始备份数据库 $DB_NAME ====="

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

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份文件名
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_${TIMESTAMP}.sql"

# 执行备份
echo "备份数据库 $DB_NAME 到 $BACKUP_FILE"
mysqldump -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_FILE

# 压缩备份文件
echo "压缩备份文件..."
gzip $BACKUP_FILE
BACKUP_FILE="${BACKUP_FILE}.gz"

# 检查备份是否成功
if [ -f "$BACKUP_FILE" ]; then
  echo "备份成功: $BACKUP_FILE"
else
  echo "备份失败!"
  exit 1
fi

# 删除过期备份
echo "清理过期备份..."
find $BACKUP_DIR -name "${DB_NAME}_backup_*.sql.gz" -type f -mtime +$RETENTION_DAYS -delete

echo "===== 数据库备份完成 ====="

# 输出备份统计信息
BACKUP_COUNT=$(find $BACKUP_DIR -name "${DB_NAME}_backup_*.sql.gz" | wc -l)
LATEST_BACKUP=$(ls -lt $BACKUP_DIR/${DB_NAME}_backup_*.sql.gz | head -n 1)
BACKUP_SIZE=$(du -h $BACKUP_FILE | cut -f1)

echo "备份数: $BACKUP_COUNT"
echo "最新备份: $LATEST_BACKUP"
echo "备份大小: $BACKUP_SIZE" 