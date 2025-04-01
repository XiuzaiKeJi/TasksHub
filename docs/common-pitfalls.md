# TasksHub 项目常见问题及解决方案

## 开发环境问题

### 1. IDE断链问题

**问题描述**：
执行某些命令后，Cursor IDE与服务器断开连接，需要重新连接。

**常见原因**：
- 使用`kill -9`等命令终止进程，影响了IDE进程
- 使用`killall node`等无差别终止Node进程的命令
- 内存不足导致IDE进程被系统终止

**解决方案**：
- 始终使用安全的服务停止命令：`./scripts/manage-services.sh stop-safe`
- 避免直接终止进程，而是通过专用脚本管理服务
- 监控内存使用，确保有足够内存供IDE使用
- 如需释放内存，优先关闭数据库：`./scripts/manage-services.sh stop-db`

### 2. Git操作卡住

**问题描述**：
执行git命令时，终端长时间无响应或卡住。

**常见原因**：
- Git钩子执行复杂检查消耗大量资源
- `git status`等命令在大型仓库中执行慢
- 终端屏幕尺寸问题导致输出异常

**解决方案**：
- 使用Git包装脚本：`./scripts/git-wrapper.sh status`
- 使用快速Git命令：`git faststatus`, `git fastcommit`等
- 这些命令已经过优化，能够避免Git钩子相关的性能问题

### 3. 服务启动失败

**问题描述**：
尝试启动前端或后端服务但失败，没有明显错误消息。

**常见原因**：
- 内存不足
- 端口被占用
- 依赖问题

**解决方案**：
- 检查内存：`./scripts/manage-services.sh memory`
- 检查服务日志：`./scripts/manage-services.sh logs-backend|logs-frontend`
- 确保MySQL已启动：`./scripts/manage-services.sh start-db`
- 尝试使用优化脚本：`./scripts/start-optimized.sh --backend-only`

## 资源管理问题

### 1. 内存不足

**问题描述**：
系统报告内存不足，或服务表现异常缓慢。

**常见原因**：
- 同时运行多个服务（MySQL, 前端, 后端）
- MySQL占用大量内存（约400MB）

**解决方案**：
- 一次只运行一个服务
- 在不需要时停止MySQL：`./scripts/manage-services.sh stop-db`
- 使用优化的启动脚本，限制内存使用：
  ```bash
  ./scripts/start-optimized.sh --backend-only
  # 或者仅启动前端
  ./scripts/start-optimized.sh --frontend-only
  ```

### 2. 服务响应缓慢

**问题描述**：
前端或后端服务响应缓慢，或经常无响应。

**常见原因**：
- 内存资源紧张
- 数据库连接问题
- 开发模式下的实时编译消耗资源

**解决方案**：
- 停止不需要的服务释放资源
- 确保服务以优化模式启动，限制内存使用
- 减少监视的文件数量，在前端配置中排除node_modules

## 版本控制问题

### 1. 合并冲突处理

**问题描述**：
合并分支时出现大量冲突，难以解决。

**常见原因**：
- 长时间未同步的分支
- 多人同时修改相同文件
- 基础文件（如配置文件）被修改

**解决方案**：
- 遵循Git Flow，确保定期从develop分支同步到feature分支
- 使用以下命令解决合并冲突：
  ```bash
  # 从develop同步到你的feature分支
  git checkout feature/your-branch
  git pull origin develop
  # 解决冲突后
  git add .
  git fastcommit -m "Merge develop into feature branch"
  ```

### 2. 分支管理问题

**问题描述**：
功能分支过多，难以管理，或分支未正确清理。

**常见原因**：
- 完成的功能分支未被删除
- 分支命名不规范
- 分支管理流程不清晰

**解决方案**：
- 严格遵循分支命名规范：`feature/TASK-ID-description`
- 功能完成后，确保正确合并到develop并删除feature分支：
  ```bash
  # 合并feature分支到develop
  git checkout develop
  git merge feature/your-branch
  
  # 删除已合并的feature分支
  git branch -d feature/your-branch
  git push origin --delete feature/your-branch
  ```

## 前端开发问题

### 1. 热重载性能问题

**问题描述**：
前端开发时，热重载过程非常缓慢，严重影响开发效率。

**常见原因**：
- Vite的文件监视模式占用过多资源
- 项目中有大量文件被监视
- 系统内存不足

**解决方案**：
- 使用优化的前端启动命令：`./scripts/start-optimized.sh --frontend-only`
- 在`vite.config.ts`中排除不必要的监视目录：
  ```typescript
  // 在vite.config.ts中
  {
    server: {
      watch: {
        ignored: ['**/node_modules/**', '**/dist/**', '**/.git/**']
      }
    }
  }
  ```
- 关闭不需要的浏览器标签和应用程序释放内存

### 2. 组件渲染性能问题

**问题描述**：
用户界面响应缓慢，尤其是在数据量大的表格或列表中。

**常见原因**：
- 未使用虚拟滚动处理大数据集
- 组件重渲染过于频繁
- 未对复杂计算结果进行缓存

**解决方案**：
- 使用`react-window`或`react-virtualized`处理大型列表
- 使用`React.memo`和`useMemo`减少不必要的重渲染
- 对API响应进行本地缓存减少请求次数
- 使用Chrome DevTools的Performance面板分析渲染瓶颈

## 调试与故障排除

### 如何分析服务日志

**查看运行中的服务日志**：
```bash
# 查看后端日志
./scripts/manage-services.sh logs-backend

# 查看前端日志
./scripts/manage-services.sh logs-frontend
```

### 如何调试内存问题

**检查内存使用情况**：
```bash
./scripts/manage-services.sh memory
# 或者
./cursor-tool.sh check-memory
```

**找出内存消耗大的进程**：
```bash
ps aux --sort=-%mem | head -10
```

### 如何安全地重启所有服务

```bash
# 安全停止所有服务
./scripts/manage-services.sh stop-safe

# 然后逐一启动服务
./scripts/manage-services.sh start-db
./scripts/manage-services.sh start-backend
./scripts/manage-services.sh start-frontend

# 或者使用优化模式只启动一个服务
./scripts/start-optimized.sh --backend-only
``` 