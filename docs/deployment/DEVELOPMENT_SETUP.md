# 开发环境配置指南

## 基础环境要求
- Node.js v18.20.6
- Git v2.43.0
- Docker v26.1.3
- MySQL v8.0.41
- pnpm v10.6.5

## 环境配置步骤

### 1. 包管理器配置
```bash
# 配置pnpm
pnpm config set registry https://registry.npmmirror.com
pnpm config set store-dir ~/.pnpm-store

# 配置Docker镜像加速
sudo mkdir -p /etc/docker
echo '{"registry-mirrors": ["https://mirror.ccs.tencentyun.com"]}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
```

### 2. Git配置
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global core.editor "vim"
```

### 3. 数据库配置
```bash
# 创建数据库和用户
mysql -u root -p
CREATE DATABASE taskshub_dev;
CREATE USER 'taskshub_user'@'localhost' IDENTIFIED BY 'taskshub_password';
GRANT ALL PRIVILEGES ON taskshub_dev.* TO 'taskshub_user'@'localhost';
FLUSH PRIVILEGES;
```

### 4. 项目配置
1. 克隆项目仓库
```bash
git clone <repository-url>
cd taskshub
```

2. 安装依赖
```bash
pnpm install
```

3. 配置环境变量
```bash
cp .env.example .env
# 编辑.env文件，配置必要的环境变量
```

4. 初始化数据库
```bash
pnpm prisma generate
pnpm prisma migrate dev
```

## 开发工具配置

### 1. 编辑器配置
- 推荐使用VSCode
- 安装必要的插件：
  - ESLint
  - Prettier
  - GitLens
  - Docker
  - MySQL

### 2. 终端配置
- 推荐使用iTerm2（Mac）或Windows Terminal（Windows）
- 配置zsh或bash的别名和提示符

## 开发流程

### 1. 启动开发服务器
```bash
pnpm dev
```

### 2. 运行测试
```bash
pnpm test
```

### 3. 代码提交
```bash
git add .
git commit -m "feat: your commit message"
git push
```

## 常见问题

### 1. 数据库连接问题
- 检查MySQL服务是否运行
- 验证数据库用户名和密码
- 确认数据库名称正确

### 2. 依赖安装问题
- 清除pnpm缓存：`pnpm store prune`
- 删除node_modules：`rm -rf node_modules`
- 重新安装依赖：`pnpm install`

### 3. Docker相关问题
- 检查Docker服务状态：`systemctl status docker`
- 验证Docker镜像：`docker images`
- 清理Docker缓存：`docker system prune`

## 注意事项
1. 确保所有环境变量正确配置
2. 定期更新依赖包
3. 遵循代码规范
4. 保持开发环境整洁
5. 定期备份数据库 