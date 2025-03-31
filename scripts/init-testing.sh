#!/bin/bash

# 设置错误时退出
set -e

echo "开始初始化测试环境..."

# 检查必要的工具
command -v docker >/dev/null 2>&1 || { echo "需要 Docker 但未安装。请先安装 Docker。"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "需要 Docker Compose 但未安装。请先安装 Docker Compose。"; exit 1; }

# 创建必要的目录
echo "创建必要的目录..."
mkdir -p prometheus/rules
mkdir -p prometheus/data

# 创建测试数据库
echo "创建测试数据库..."
docker-compose -f docker-compose.testing.yml up -d mysql
sleep 10

# 运行数据库迁移
echo "运行数据库迁移..."
npm run test:db:migrate

# 导入测试数据
echo "导入测试数据..."
npm run test:db:seed

# 启动测试环境
echo "启动测试环境..."
docker-compose -f docker-compose.testing.yml up -d

# 等待服务启动
echo "等待服务启动..."
sleep 10

# 检查服务状态
echo "检查服务状态..."
docker-compose -f docker-compose.testing.yml ps

# 检查监控系统
echo "检查监控系统..."
curl -s http://localhost:9090/-/healthy || echo "Prometheus 健康检查失败"
curl -s http://localhost:9100/metrics || echo "Node Exporter 健康检查失败"

echo "测试环境初始化完成！"
echo "应用地址: http://localhost:3000"
echo "Prometheus 地址: http://localhost:9090"
echo "Node Exporter 地址: http://localhost:9100"
echo "Prisma Studio 地址: http://localhost:5555"
echo "监控规则已配置完成"
echo "测试数据已导入完成" 