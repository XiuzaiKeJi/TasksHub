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

### 低内存环境优化方案（推荐）

对于内存限制较低的服务器（2GB或更低），我们提供了内存优化的服务管理脚本：

```bash
# 赋予脚本执行权限
chmod +x /home/TasksHub/scripts/manage-services.sh

# 查看帮助信息
/home/TasksHub/scripts/manage-services.sh help

# 单独启动前端服务（优化内存使用）
/home/TasksHub/scripts/manage-services.sh start-frontend

# 单独启动后端服务（优化内存使用）
/home/TasksHub/scripts/manage-services.sh start-backend

# 检查服务状态与资源使用
/home/TasksHub/scripts/manage-services.sh status

# 安全停止所有服务（不影响IDE）
/home/TasksHub/scripts/manage-services.sh stop-safe

# 查看前端或后端日志
/home/TasksHub/scripts/manage-services.sh logs-frontend
/home/TasksHub/scripts/manage-services.sh logs-backend

# 查看内存状态
/home/TasksHub/scripts/manage-services.sh memory
```

内存优化配置说明：
- 前端服务：限制Node.js内存为256MB，禁用生成sourcemap
- 后端服务：限制Node.js内存为256MB，使用transpile-only模式减少类型检查开销
- 分离启动：推荐根据需要单独启动前端或后端，不要同时运行
- 服务监控：通过status命令监控服务运行状态和内存使用情况

### 使用便捷脚本（常规环境）

我们提供了一个便捷脚本来管理项目的各种操作：

```bash
# 赋予脚本执行权限
chmod +x /home/TasksHub/scripts/run-project.sh

# 查看帮助信息
/home/TasksHub/scripts/run-project.sh --help

# 初始化数据库
/home/TasksHub/scripts/run-project.sh --init

# 启动所有服务
/home/TasksHub/scripts/run-project.sh --start-all

# 仅启动后端服务
/home/TasksHub/scripts/run-project.sh --start-backend

# 仅启动前端服务
/home/TasksHub/scripts/run-project.sh --start-frontend

# 数据库维护操作
/home/TasksHub/scripts/run-project.sh --backup-db
/home/TasksHub/scripts/run-project.sh --restore-db
/home/TasksHub/scripts/run-project.sh --monitor-db
```

### 手动启动（开发模式）

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

## 性能优化建议

### 资源限制环境下的优化策略

对于资源受限的开发或生产环境（如内存小于2GB的服务器），我们建议采取以下策略：

1. **分离服务运行**
   - 使用`manage-services.sh`脚本分别启动前端和后端
   - 在不需要前端开发时，只启动后端服务
   - 在不需要后端开发时，只启动前端服务

2. **数据库优化**
   - 按需启动MySQL服务：`systemctl start mysql`
   - 减少MySQL内存占用：优化`my.cnf`配置（见`docs/db-optimization.md`）
   - 考虑使用连接池限制并发连接数量
   - 利用MySQL 8.0的缓冲池预热功能加快重启后的性能

3. **IDE与开发工具**
   - 限制代码编辑器使用的扩展/插件数量
   - 关闭自动类型检查，改为手动触发
   - 关闭即时语法检查和代码建议功能

4. **前端开发优化**
   - 使用`VITE_MEMORY_LIMIT=true`环境变量以激活内存节约模式
   - 禁用source map生成：`sourcemap: false`
   - 减少热重载监听文件范围
   - 对大型列表和表格使用虚拟滚动技术
   - 使用React.memo和useMemo减少不必要的重渲染

5. **后端开发优化**
   - 使用`--transpile-only`模式以减少类型检查开销
   - 设置`NODE_OPTIONS="--max-old-space-size=256"`限制Node.js内存使用
   - 减少中间件和不必要的依赖项
   - 实现API响应缓存减少重复计算

6. **监控与维护**
   - 定期使用`manage-services.sh status`检查服务状态
   - 监控内存使用：`free -h`和`ps aux --sort=-%mem | head -10`
   - 出现内存不足时，使用`manage-services.sh stop-safe`安全停止服务

7. **前端构建优化**
   - 使用代码分割减小初始加载包的大小
   - 实现懒加载非关键组件
   - 优化图片和静态资源
   - 使用Gzip或Brotli压缩静态资源

通过合理的资源管理和优化配置，本项目能够在资源受限的环境中稳定运行。 

## 开发环境使用指南

为确保项目开发环境稳定运行，请遵循以下指南：

### 服务管理

使用项目提供的脚本管理服务，避免直接使用npm或node命令：

```bash
# 查看服务状态
./scripts/manage-services.sh status

# 启动服务
./scripts/manage-services.sh start-db       # 启动数据库
./scripts/manage-services.sh start-backend  # 启动后端
./scripts/manage-services.sh start-frontend # 启动前端

# 安全停止服务（不影响IDE）
./scripts/manage-services.sh stop-safe

# 查看服务日志
./scripts/manage-services.sh logs-backend
./scripts/manage-services.sh logs-frontend

# 内存优化模式（仅启动一个服务）
./scripts/start-optimized.sh --backend-only
./scripts/start-optimized.sh --frontend-only
```

### Git操作

为避免Git操作卡顿，请使用以下命令：

```bash
# 使用Git包装脚本
./scripts/git-wrapper.sh status
./scripts/git-wrapper.sh branch

# 或使用快速Git命令
git faststatus    # 快速查看状态
git fastcommit    # 快速提交（跳过钩子检查）
git fastpush      # 快速推送
```

### 分支管理规范

- 遵循功能分支→开发分支→主分支流程
- 分支命名格式：`feature/TASK-ID-description`
- 完成功能后及时合并并删除功能分支

### 注意事项

- 系统内存有限，避免同时运行多个服务
- 不要使用可能导致IDE断链的命令（如kill -9）
- 始终使用项目脚本停止服务，而非直接终止进程

更多详细信息，请参考 `.cursor/agent-instructions.md` 

## 简化开发流程

为了提高开发效率，我们提供了简化的开发流程：

```bash
# 初始化开发环境
./scripts/quick-dev.sh setup

# 快速更新、提交和推送
./scripts/quick-dev.sh update "更新描述"

# 快速修复并推送
./scripts/quick-dev.sh fix "修复描述"

# 快速启动服务
./scripts/quick-dev.sh start

# 快速停止服务
./scripts/quick-dev.sh stop
```

详细说明请参考 [简化开发指南](docs/SIMPLIFIED_GUIDE.md)。 