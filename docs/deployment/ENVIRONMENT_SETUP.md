# 行政办公任务中心系统 - 环境搭建说明

*文档编号：DEP-002*  
*版本：v1.0*  
*更新日期：2024-03-31*  
*关联文档：[部署指南](./DEPLOYMENT_GUIDE.md)、[实施计划](../design/IMPLEMENTATION_PLAN.md)*

## 目录

- [1. 概述](#1-概述)
- [2. 开发环境搭建](#2-开发环境搭建)
- [3. 测试环境搭建](#3-测试环境搭建)
- [4. 预生产环境搭建](#4-预生产环境搭建)
- [5. 生产环境搭建](#5-生产环境搭建)
- [6. 环境配置管理](#6-环境配置管理)
- [7. 环境验证](#7-环境验证)
- [8. 常见问题与解决方案](#8-常见问题与解决方案)

## 1. 概述

本文档详细描述了行政办公任务中心系统各环境的搭建流程和配置说明，包括开发环境、测试环境、预生产环境和生产环境。各环境的搭建遵循统一的技术标准，但在资源配置、安全策略等方面有所区别。

### 1.1 环境说明

| 环境类型 | 用途 | 访问权限 | 数据特点 |
|---------|------|---------|---------|
| 开发环境 | 用于日常开发和单元测试 | 仅开发人员 | 开发测试数据，可随时重置 |
| 测试环境 | 用于集成测试和功能验证 | 开发人员和测试人员 | 模拟数据，定期刷新 |
| 预生产环境 | 用于系统验收和演示 | 项目相关人员 | 近似生产数据，受保护 |
| 生产环境 | 系统正式运行环境 | 严格控制访问权限 | 真实业务数据，严格保护 |

## 2. 开发环境搭建

### 2.1 混合开发环境架构

本项目采用混合开发环境架构，开发人员在本地Mac OS系统上使用Cursor IDE进行开发，通过SSH连接远程开发服务器进行构建和测试。这种架构结合了本地开发的灵活性和服务器环境的一致性。

#### 2.1.1 环境组成

- **本地环境**：
  - Mac OS 12或更高版本
  - Cursor IDE及其Agent
  - SSH客户端
  - Git客户端
  - Node.js v18.x（用于本地开发测试）

- **远程服务器环境**：
  - Linux服务器（推荐Ubuntu 20.04 LTS）
  - Node.js v18.x
  - MySQL 8.0
  - Docker和Docker Compose
  - Git

#### 2.1.2 环境架构图

```
  ┌─────────────────┐                 ┌─────────────────┐
  │                 │                 │                 │
  │   本地环境       │       SSH       │   远程服务器     │
  │   Mac OS 12     │◄───连接/同步────►│   Ubuntu 20.04  │
  │   Cursor IDE    │                 │   Node.js       │
  │                 │                 │   MySQL         │
  └─────────────────┘                 └─────────────────┘
```

### 2.2 本地环境配置

1. **安装/更新Cursor IDE**
   - 从[官方网站](https://cursor.sh/)下载最新版Cursor IDE
   - 安装并完成基础配置

2. **配置Cursor Agent**
   - 启动Cursor IDE
   - 在设置中启用Cursor Agent
   - 配置API密钥

3. **配置SSH客户端**
   - 生成SSH密钥对（如未生成）
     ```bash
     ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
     ```
   - 配置SSH配置文件 `~/.ssh/config`
     ```
     Host dev-server
       HostName dev-server.example.com
       User deploy
       IdentityFile ~/.ssh/id_rsa
       Port 22
     ```

### 2.3 远程服务器配置

1. **服务器基础配置**
   - 安装必要的系统软件包
     ```bash
     sudo apt update
     sudo apt install -y build-essential curl git
     ```
   - 配置防火墙
   - 设置SSH密钥认证

2. **安装Node.js**
   - 使用NVM安装
     ```bash
     curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
     source ~/.bashrc
     nvm install 18
     nvm use 18
     ```

3. **安装MySQL**
   - 安装MySQL服务器
     ```bash
     sudo apt install -y mysql-server
     ```
   - 配置MySQL安全设置
     ```bash
     sudo mysql_secure_installation
     ```
   - 创建应用需要的数据库和用户

4. **安装Docker**
   - 安装Docker
     ```bash
     curl -fsSL https://get.docker.com -o get-docker.sh
     sudo sh get-docker.sh
     ```
   - 安装Docker Compose
     ```bash
     sudo curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
     sudo chmod +x /usr/local/bin/docker-compose
     ```

### 2.4 文档同步配置

1. **配置同步脚本**
   - 将`scripts/sync_docs.sh`脚本复制到本地环境
   - 根据实际情况修改脚本中的配置参数：
     - `LOCAL_DOCS_PATH`：本地文档目录路径
     - `REMOTE_USER`：远程服务器用户名
     - `REMOTE_HOST`：远程服务器地址
     - `REMOTE_DOCS_PATH`：远程服务器上的文档目录路径
     - `SSH_KEY_PATH`：SSH密钥路径

2. **设置执行权限**
   ```bash
   chmod +x scripts/sync_docs.sh
   ```

3. **配置定时同步（可选）**
   - 添加到crontab定时执行
     ```bash
     (crontab -l 2>/dev/null; echo "0 * * * * $PWD/scripts/sync_docs.sh") | crontab -
     ```
   - 或手动执行同步
     ```bash
     ./scripts/sync_docs.sh
     ```

### 2.5 项目初始化

1. **在远程服务器上克隆项目仓库**
   ```bash
   ssh dev-server
   git clone <项目仓库URL> /var/www/eduhub
   cd /var/www/eduhub
   ```

2. **安装项目依赖**
   ```bash
   npm install
   ```

3. **配置环境变量**
   - 创建并配置`.env`文件，包含必要的环境变量

4. **初始化数据库**
   ```bash
   npm run db:init
   ```

### 2.6 环境验证

1. **验证SSH连接**
   ```bash
   ssh dev-server echo "连接成功"
   ```

2. **验证Node.js安装**
   ```bash
   ssh dev-server "node -v && npm -v"
   ```

3. **验证MySQL连接**
   ```bash
   ssh dev-server "mysql -u<用户名> -p<密码> -e 'SHOW DATABASES;'"
   ```

4. **验证Docker运行状态**
   ```bash
   ssh dev-server "docker -v && docker ps"
   ```

5. **验证文档同步**
   ```bash
   ./scripts/sync_docs.sh
   ```

### 2.7 开发工作流

1. **本地编辑代码**：在Cursor IDE中编辑项目文件
2. **自动或手动同步**：文档通过同步脚本同步到远程服务器
3. **远程构建和测试**：
   ```bash
   ssh dev-server "cd /var/www/eduhub && npm run build && npm test"
   ```
4. **远程运行应用**：
   ```bash
   ssh dev-server "cd /var/www/eduhub && npm start"
   ```

## 3. 测试环境搭建

[测试环境搭建的详细内容将在此处补充]

## 4. 预生产环境搭建

[预生产环境搭建的详细内容将在此处补充]

## 5. 生产环境搭建

[生产环境搭建的详细内容将在此处补充]

## 6. 环境配置管理

[环境配置管理的详细内容将在此处补充]

## 7. 环境验证

[环境验证的详细内容将在此处补充]

## 8. 常见问题与解决方案

[常见问题与解决方案的详细内容将在此处补充]

---

*文档结束* 