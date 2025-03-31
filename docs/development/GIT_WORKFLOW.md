# Git 工作流程规范

## 分支策略

### 主要分支
- `main`: 主分支，用于生产环境
- `develop`: 开发分支，用于开发环境

### 功能分支
- 命名规范：`feature/任务ID-简短描述`
- 从 `develop` 分支创建
- 完成后合并回 `develop` 分支

### 修复分支
- 命名规范：`hotfix/任务ID-简短描述`
- 从 `main` 分支创建
- 完成后合并回 `main` 和 `develop` 分支

### 发布分支
- 命名规范：`release/版本号`
- 从 `develop` 分支创建
- 完成后合并回 `main` 和 `develop` 分支

## 提交规范

### 提交信息格式
```
<type>(<scope>): <subject>

<body>

<footer>
```

### 类型（type）
- feat: 新功能
- fix: 修复bug
- docs: 文档更新
- style: 代码格式（不影响代码运行的变动）
- refactor: 重构
- test: 测试相关
- chore: 构建过程或辅助工具的变动

### 范围（scope）
- 可选，表示影响范围
- 例如：user, task, auth 等

### 主题（subject）
- 简短描述，不超过50个字符
- 使用现在时态
- 首字母不大写
- 结尾不加句号

### 正文（body）
- 可选，详细描述
- 使用现在时态
- 说明改动原因和改动前后的行为对比

### 页脚（footer）
- 可选，关闭 Issue
- 例如：Closes #123, #456

## 示例

```
feat(user): add user profile page

- Add user profile component
- Implement profile editing
- Add avatar upload functionality

Closes #123
```

## 工作流程

1. 创建功能分支
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/TASK-001-add-user-profile
   ```

2. 开发功能
   ```bash
   git add .
   git commit -m "feat(user): add user profile page"
   ```

3. 推送到远程
   ```bash
   git push origin feature/TASK-001-add-user-profile
   ```

4. 创建合并请求
   - 从功能分支合并到 develop 分支
   - 填写合并请求描述
   - 等待代码审查

5. 合并到 develop
   - 通过代码审查后合并
   - 删除功能分支

## 注意事项

1. 保持分支同步
   - 定期从 develop 拉取更新
   - 解决冲突后再提交

2. 代码审查
   - 所有合并请求必须经过审查
   - 确保代码符合规范
   - 确保测试通过

3. 提交前检查
   - 运行代码格式化
   - 运行代码检查
   - 运行类型检查
   - 运行测试 