# TasksHub 简化开发指南

## 简介

本指南提供了TasksHub项目的简化开发流程，旨在提高开发效率，减少不必要的复杂性。

## 快速开始

### 环境设置

```bash
# 初始化开发环境
./scripts/quick-dev.sh setup
```

### 常用操作

#### 代码管理

```bash
# 快速更新、提交和推送
./scripts/quick-dev.sh update "更新描述"

# 快速修复并推送
./scripts/quick-dev.sh fix "修复描述"

# 快速切换分支并同步
./scripts/quick-dev.sh switch branch-name
```

#### 服务管理

```bash
# 快速启动服务
./scripts/quick-dev.sh start

# 快速停止服务
./scripts/quick-dev.sh stop
```

## 简化的分支策略

我们采用简化的分支策略：

1. 主要在`main`分支上进行开发
2. 仅对重大功能或风险高的修改创建临时功能分支
3. 完成后立即合并回`main`并删除临时分支

## 常见问题解决

### 命令执行卡住

如果命令执行卡住，请使用以下方法：

```bash
# 使用Ctrl+C中断当前命令
# 然后使用git包装器脚本
./scripts/git-wrapper.sh [命令]
```

### IDE断链问题

如果IDE断开连接：

```bash
# 安全停止所有服务
./scripts/quick-dev.sh stop

# 重新连接后，重新设置环境
./scripts/quick-dev.sh setup
```

### 内存不足问题

如果系统内存不足：

```bash
# 停止所有服务
./scripts/quick-dev.sh stop

# 只启动必要服务
./scripts/manage-services.sh start-backend
```

## 简化CI/CD流程

我们使用简化的CI/CD流程，它会：

1. 基本的代码检查
2. 简单的构建验证
3. 跳过复杂的测试和部署步骤

推送到`main`分支的代码会自动触发此简化流程。 