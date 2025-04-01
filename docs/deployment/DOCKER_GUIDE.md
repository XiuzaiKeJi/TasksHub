# Docker使用指南

## Docker环境要求
- Docker v26.1.3
- Docker Compose v2.24.5

## Docker配置

### 1. 镜像加速配置
```bash
# 创建或编辑daemon.json文件
sudo mkdir -p /etc/docker
sudo vim /etc/docker/daemon.json

# 添加以下内容
{
  "registry-mirrors": ["https://mirror.ccs.tencentyun.com"]
}

# 重启Docker服务
sudo systemctl restart docker
```

### 2. 常用Docker命令
```bash
# 查看Docker版本
docker --version

# 查看Docker服务状态
systemctl status docker

# 查看本地镜像
docker images

# 查看运行中的容器
docker ps

# 查看所有容器（包括已停止的）
docker ps -a

# 拉取镜像
docker pull <image-name>:<tag>

# 运行容器
docker run -d --name <container-name> <image-name>

# 停止容器
docker stop <container-name>

# 启动容器
docker start <container-name>

# 删除容器
docker rm <container-name>

# 删除镜像
docker rmi <image-name>

# 查看容器日志
docker logs <container-name>

# 进入容器
docker exec -it <container-name> /bin/bash
```

## Docker Compose使用

### 1. 基本命令
```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 查看服务状态
docker-compose ps

# 查看服务日志
docker-compose logs -f

# 重新构建服务
docker-compose up -d --build
```

### 2. 开发环境配置
```yaml
# docker-compose.yml示例
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - DATABASE_URL=mysql://taskshub_user:taskshub_password@db:3306/taskshub_dev
    depends_on:
      - db

  db:
    image: mysql:8.0
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=root_password
      - MYSQL_DATABASE=taskshub_dev
      - MYSQL_USER=taskshub_user
      - MYSQL_PASSWORD=taskshub_password
    volumes:
      - mysql_data:/var/lib/mysql

volumes:
  mysql_data:
```

## 开发流程

### 1. 首次设置
```bash
# 克隆项目
git clone <repository-url>
cd taskshub

# 构建镜像
docker-compose build

# 启动服务
docker-compose up -d
```

### 2. 日常开发
```bash
# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f app

# 进入容器
docker-compose exec app sh

# 运行测试
docker-compose exec app pnpm test

# 停止服务
docker-compose down
```

### 3. 数据库操作
```bash
# 进入数据库容器
docker-compose exec db mysql -u taskshub_user -p

# 备份数据库
docker-compose exec db mysqldump -u taskshub_user -p taskshub_dev > backup.sql

# 恢复数据库
docker-compose exec -T db mysql -u taskshub_user -p taskshub_dev < backup.sql
```

## 常见问题

### 1. 容器无法启动
- 检查端口是否被占用
- 查看容器日志：`docker-compose logs <service-name>`
- 检查环境变量配置
- 验证数据卷权限

### 2. 数据库连接问题
- 确认数据库服务是否正常运行
- 检查数据库连接字符串
- 验证数据库用户权限
- 检查网络连接

### 3. 性能问题
- 监控容器资源使用：`docker stats`
- 检查日志大小：`docker system df`
- 清理未使用的资源：`docker system prune`

## 最佳实践
1. 使用多阶段构建优化镜像大小
2. 合理使用数据卷管理持久化数据
3. 定期清理未使用的镜像和容器
4. 使用.dockerignore排除不必要的文件
5. 遵循最小权限原则配置容器
6. 定期更新基础镜像
7. 使用健康检查确保服务可用性 