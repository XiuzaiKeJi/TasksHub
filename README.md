# 行政办公任务中心系统

这是一个用于行政办公室的任务管理系统，旨在提高行政工作效率，优化任务分配和跟踪流程。

## 功能特点

- 用户和部门管理
- 任务创建与分配
- 任务状态跟踪
- 多级子任务支持
- 权限控制

## 技术栈

### 前端
- React
- TypeScript
- Ant Design
- Vite

### 后端
- Node.js
- Express
- TypeScript
- Prisma ORM

### 数据库
- MySQL

## 安装指南

### 前提条件

- Node.js v18+
- MySQL v8.0+
- Git

### 克隆仓库

```bash
git clone https://github.com/XiuzaiKeJi/TasksHub.git
cd TasksHub
```

### 安装依赖

```bash
# 后端依赖安装
cd backend
npm install

# 前端依赖安装
cd ../frontend
npm install
```

### 配置环境变量

1. 在后端目录创建 `.env` 文件：

```
DATABASE_URL="mysql://用户名:密码@localhost:3306/taskshub_dev"
JWT_SECRET="你的JWT密钥"
PORT=3000
```

2. 在前端目录创建 `.env` 文件：

```
VITE_API_URL=http://localhost:3000/api
```

### 初始化数据库

```bash
cd backend/scripts
chmod +x init-db.sh
./init-db.sh --seed
```

## 启动应用

### 开发模式

```bash
# 启动后端服务
cd backend
npm run dev

# 启动前端服务
cd frontend
npm run dev
```

后端服务将在 http://localhost:3000 启动
前端服务将在 http://localhost:5173 启动

### 生产模式

```bash
# 构建前端
cd frontend
npm run build

# 启动后端服务
cd backend
npm run build
npm start
```

## 数据库维护

系统提供了数据库维护脚本：

```bash
cd backend/scripts

# 备份数据库
./backup-db.sh

# 恢复数据库
./restore-db.sh

# 监控数据库
./monitor-db.sh
```

详细的数据库维护计划请参考 [数据库维护计划](backend/docs/db-maintenance-plan.md)。

## 项目文档

- [任务跟踪](docs/project/TASK_TRACKING.md)
- [实施计划](docs/design/IMPLEMENTATION_PLAN.md)
- [技术架构设计](docs/design/TECHNICAL_ARCHITECTURE.md)
- [数据库设计](docs/design/DATABASE_DESIGN.md)
- [API设计](docs/design/API_DESIGN.md)

## 贡献指南

1. Fork仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'feat: add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建Pull Request

## 许可证

本项目采用 MIT 许可证 