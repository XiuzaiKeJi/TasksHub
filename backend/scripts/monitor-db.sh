#!/bin/bash

# 设置错误时退出
set -e

# 配置参数
DB_HOST="localhost"
DB_PORT="3306"
LOG_DIR="../logs"
LOG_FILE="$LOG_DIR/db_monitor_$(date +"%Y%m%d").log"

# 检查环境变量
if [ -z "$NODE_ENV" ]; then
  export NODE_ENV=development
  echo "未设置NODE_ENV，默认使用development环境" | tee -a $LOG_FILE
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
  echo "警告: 未找到环境文件 $ENV_FILE，使用默认连接信息" | tee -a $LOG_FILE
  DB_USER="root"
  DB_PASSWORD="password"
fi

# 创建日志目录
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p $LOG_DIR
  echo "创建日志目录: $LOG_DIR" | tee -a $LOG_FILE
fi

# 输出时间戳
echo "===== 数据库监控开始 $(date) =====" | tee -a $LOG_FILE

# 检查数据库连接
echo "检查数据库连接..." | tee -a $LOG_FILE
if mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "SELECT 1" &>/dev/null; then
  echo "✓ 数据库连接正常" | tee -a $LOG_FILE
else
  echo "✗ 数据库连接失败" | tee -a $LOG_FILE
  exit 1
fi

# 获取数据库状态
echo "获取数据库状态..." | tee -a $LOG_FILE
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "SHOW STATUS LIKE 'Threads_%';" | tee -a $LOG_FILE
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "SHOW STATUS LIKE 'Connections';" | tee -a $LOG_FILE
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "SHOW STATUS LIKE 'Queries';" | tee -a $LOG_FILE

# 获取数据库进程列表
echo "获取数据库进程列表..." | tee -a $LOG_FILE
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "SHOW PROCESSLIST;" | tee -a $LOG_FILE

# 获取数据库表信息
echo "获取数据库表信息..." | tee -a $LOG_FILE
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "SELECT table_name, table_rows, data_length/1024/1024 AS 'Data Size (MB)', index_length/1024/1024 AS 'Index Size (MB)' FROM information_schema.tables WHERE table_schema='$DB_NAME' ORDER BY data_length DESC LIMIT 10;" | tee -a $LOG_FILE

# 检查慢查询
echo "检查慢查询..." | tee -a $LOG_FILE
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "SHOW VARIABLES LIKE 'slow_query%';" | tee -a $LOG_FILE
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "SHOW VARIABLES LIKE 'long_query_time';" | tee -a $LOG_FILE

# 检查InnoDB状态
echo "检查InnoDB状态..." | tee -a $LOG_FILE
mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASSWORD -e "SHOW ENGINE INNODB STATUS\G" | grep -A 20 "TRANSACTIONS" | tee -a $LOG_FILE

echo "===== 数据库监控完成 $(date) =====" | tee -a $LOG_FILE

# 统计信息
echo "日志文件位置: $LOG_FILE"
echo "日志总大小: $(du -h $LOG_FILE | cut -f1)" 