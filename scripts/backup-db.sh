#!/bin/bash

# 数据库备份脚本
# 作者：数据库工程师
# 创建日期：2024-04-06

# 配置变量
BACKUP_DIR="/backup/database"
MYSQL_USER="taskshub_user"
MYSQL_PASSWORD="taskshub_password"
MYSQL_HOST="localhost"
MYSQL_PORT="3306"
DATABASE_NAME="taskshub_dev"
RETENTION_DAYS=7

# 创建备份目录
mkdir -p "$BACKUP_DIR"

# 生成备份文件名（使用时间戳）
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DATABASE_NAME}_${TIMESTAMP}.sql"

# 执行数据库备份
echo "开始备份数据库 $DATABASE_NAME..."
mysqldump -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" \
    --single-transaction \
    --routines \
    --triggers \
    --events \
    "$DATABASE_NAME" > "$BACKUP_FILE"

# 检查备份是否成功
if [ $? -eq 0 ]; then
    echo "数据库备份成功：$BACKUP_FILE"
    
    # 压缩备份文件
    gzip "$BACKUP_FILE"
    echo "备份文件已压缩：${BACKUP_FILE}.gz"
    
    # 清理旧备份文件
    find "$BACKUP_DIR" -name "${DATABASE_NAME}_*.sql.gz" -type f -mtime +$RETENTION_DAYS -delete
    echo "已清理 $RETENTION_DAYS 天前的备份文件"
else
    echo "数据库备份失败"
    exit 1
fi 