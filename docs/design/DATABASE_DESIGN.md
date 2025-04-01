# 行政办公任务中心系统 - 数据库设计

*文档编号：SDD-003*  
*版本：v1.0*  
*更新日期：2024-03-31*  
*关联文档：[系统设计概述](./SYSTEM_DESIGN_OVERVIEW.md)*

## 目录

- [1. 引言](#1-引言)
- [2. 数据库选型](#2-数据库选型)
- [3. 数据模型设计](#3-数据模型设计)
- [4. 表结构设计](#4-表结构设计)
- [5. 索引设计](#5-索引设计)
- [6. 关系约束](#6-关系约束)
- [7. 数据访问策略](#7-数据访问策略)
- [8. 数据存储与备份](#8-数据存储与备份)

## 1. 引言

本文档详细描述了行政办公任务中心系统的数据库设计，包括数据模型、表结构、索引设计和关系约束等内容，为系统开发和数据库管理提供指导。

## 2. 数据库选型

### 2.1 主数据库

系统选用MySQL 8.x作为主要关系型数据库，主要考虑因素包括：

1. **成熟稳定**：MySQL是成熟的开源数据库，有广泛的社区支持和完善的文档
2. **功能完备**：支持事务、存储过程、触发器和复杂查询
3. **高性能**：良好的读写性能和优化能力
4. **可扩展性**：支持主从复制和读写分离

### 2.2 缓存数据库

系统选用Redis 6.x作为缓存数据库，主要用途包括：

1. **会话存储**：存储用户会话和认证信息
2. **热点数据缓存**：缓存频繁访问的数据
3. **任务队列**：配合消息队列实现任务处理
4. **计数器服务**：实现高性能计数器功能

## 3. 数据模型设计

### 3.1 实体关系图 (ER图)

```
+---------------+       +---------------+       +---------------+
|     User      |       |   Department  |       |     Role      |
+---------------+       +---------------+       +---------------+
| PK: id        |<----->| PK: id        |       | PK: id        |
| username      |       | name          |       | name          |
| password_hash |       | code          |       | description   |
| email         |       | parent_id     |       | permissions   |
| real_name     |       | leader_id     |       +-------^-------+
| phone         |       | created_at    |               |
| avatar        |       | updated_at    |               |
| status        |       +---------------+               |
| department_id |                                       |
| roles_ids     |---------------------------------------+
| created_at    |
| updated_at    |                   +---------------+
+-------^-------+                   |  Permission   |
        |                           +---------------+
        |                           | PK: id        |
        |                           | code          |
        |        +---------------+  | name          |
        |        |     Task      |  | module        |
        |        +---------------+  | description   |
        +------->| PK: id        |  +---------------+
                 | title         |
                 | description   |          +---------------+
                 | status        |          |   Comment     |
                 | priority      |          +---------------+
                 | creator_id    |          | PK: id        |
                 | assignee_id   |<---------| task_id       |
                 | reviewer_id   |          | user_id       |
                 | parent_id     |          | content       |
                 | due_date      |          | created_at    |
                 | created_at    |          +---------------+
                 | updated_at    |
                 +-------^-------+
                         |                 +---------------+
                         |                 |  Attachment   |
                         |                 +---------------+
                         |                 | PK: id        |
                         +-----------------| task_id       |
                                           | filename      |
                                           | file_path     |
                                           | file_size     |
                                           | mime_type     |
                                           | uploader_id   |
                                           | upload_time   |
                                           +---------------+
```

### 3.2 关键实体说明

1. **User**：系统用户，包含基本信息和认证信息
2. **Department**：部门信息，支持多级部门结构
3. **Role**：用户角色，与权限关联
4. **Permission**：系统权限点
5. **Task**：任务信息，核心业务实体
6. **Attachment**：任务附件
7. **Comment**：任务评论

## 4. 表结构设计

### 4.1 用户表 (users)

| 字段名 | 数据类型 | 约束 | 说明 |
|-------|---------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 用户ID |
| username | VARCHAR(50) | NOT NULL, UNIQUE | 用户名 |
| password_hash | VARCHAR(255) | NOT NULL | 密码哈希值 |
| email | VARCHAR(100) | UNIQUE | 电子邮箱 |
| real_name | VARCHAR(50) | NOT NULL | 真实姓名 |
| phone | VARCHAR(20) | | 电话号码 |
| avatar | VARCHAR(255) | | 头像URL |
| status | TINYINT | NOT NULL, DEFAULT 1 | 状态：1-启用，0-禁用 |
| department_id | BIGINT | FOREIGN KEY | 所属部门ID |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |
| last_login_at | DATETIME | | 最后登录时间 |
| last_login_ip | VARCHAR(50) | | 最后登录IP |

### 4.2 部门表 (departments)

| 字段名 | 数据类型 | 约束 | 说明 |
|-------|---------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 部门ID |
| name | VARCHAR(100) | NOT NULL | 部门名称 |
| code | VARCHAR(50) | NOT NULL, UNIQUE | 部门编码 |
| parent_id | BIGINT | FOREIGN KEY, NULL | 父部门ID |
| path | VARCHAR(255) | NOT NULL | 部门路径（用于查询） |
| leader_id | BIGINT | FOREIGN KEY | 部门负责人ID |
| description | TEXT | | 部门描述 |
| status | TINYINT | NOT NULL, DEFAULT 1 | 状态：1-启用，0-禁用 |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

### 4.3 角色表 (roles)

| 字段名 | 数据类型 | 约束 | 说明 |
|-------|---------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 角色ID |
| name | VARCHAR(50) | NOT NULL, UNIQUE | 角色名称 |
| code | VARCHAR(50) | NOT NULL, UNIQUE | 角色编码 |
| description | VARCHAR(255) | | 角色描述 |
| status | TINYINT | NOT NULL, DEFAULT 1 | 状态：1-启用，0-禁用 |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

### 4.4 用户角色关联表 (user_roles)

| 字段名 | 数据类型 | 约束 | 说明 |
|-------|---------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 记录ID |
| user_id | BIGINT | FOREIGN KEY, NOT NULL | 用户ID |
| role_id | BIGINT | FOREIGN KEY, NOT NULL | 角色ID |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |

### 4.5 权限表 (permissions)

| 字段名 | 数据类型 | 约束 | 说明 |
|-------|---------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 权限ID |
| code | VARCHAR(50) | NOT NULL, UNIQUE | 权限编码 |
| name | VARCHAR(50) | NOT NULL | 权限名称 |
| module | VARCHAR(50) | NOT NULL | 所属模块 |
| description | VARCHAR(255) | | 权限描述 |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

### 4.6 角色权限关联表 (role_permissions)

| 字段名 | 数据类型 | 约束 | 说明 |
|-------|---------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 记录ID |
| role_id | BIGINT | FOREIGN KEY, NOT NULL | 角色ID |
| permission_id | BIGINT | FOREIGN KEY, NOT NULL | 权限ID |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |

### 4.7 任务表 (tasks)

| 字段名 | 数据类型 | 约束 | 说明 |
|-------|---------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 任务ID |
| title | VARCHAR(200) | NOT NULL | 任务标题 |
| description | TEXT | | 任务描述 |
| status | VARCHAR(20) | NOT NULL, DEFAULT 'pending' | 任务状态：pending, in_progress, completed, rejected, deferred |
| priority | TINYINT | NOT NULL, DEFAULT 3 | 优先级：1-最高, 5-最低 |
| creator_id | BIGINT | FOREIGN KEY, NOT NULL | 创建者ID |
| assignee_id | BIGINT | FOREIGN KEY | 负责人ID |
| reviewer_id | BIGINT | FOREIGN KEY | 审核人ID |
| department_id | BIGINT | FOREIGN KEY | 所属部门ID |
| parent_id | BIGINT | FOREIGN KEY | 父任务ID |
| path | VARCHAR(255) | | 任务路径（用于查询） |
| level | TINYINT | NOT NULL, DEFAULT 1 | 任务层级 |
| start_date | DATE | | 计划开始日期 |
| due_date | DATE | | 截止日期 |
| completion_date | DATETIME | | 实际完成时间 |
| progress | TINYINT | NOT NULL, DEFAULT 0 | 进度百分比 |
| is_important | BOOLEAN | NOT NULL, DEFAULT 0 | 是否重要 |
| is_urgent | BOOLEAN | NOT NULL, DEFAULT 0 | 是否紧急 |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

### 4.8 任务附件表 (attachments)

| 字段名 | 数据类型 | 约束 | 说明 |
|-------|---------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 附件ID |
| task_id | BIGINT | FOREIGN KEY, NOT NULL | 关联任务ID |
| filename | VARCHAR(255) | NOT NULL | 文件名 |
| file_path | VARCHAR(255) | NOT NULL | 文件路径 |
| file_size | INT | NOT NULL | 文件大小(字节) |
| mime_type | VARCHAR(100) | NOT NULL | 文件类型 |
| uploader_id | BIGINT | FOREIGN KEY, NOT NULL | 上传者ID |
| upload_time | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 上传时间 |

### 4.9 任务评论表 (comments)

| 字段名 | 数据类型 | 约束 | 说明 |
|-------|---------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 评论ID |
| task_id | BIGINT | FOREIGN KEY, NOT NULL | 关联任务ID |
| user_id | BIGINT | FOREIGN KEY, NOT NULL | 评论者ID |
| content | TEXT | NOT NULL | 评论内容 |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

### 4.10 任务协作者表 (task_collaborators)

| 字段名 | 数据类型 | 约束 | 说明 |
|-------|---------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 记录ID |
| task_id | BIGINT | FOREIGN KEY, NOT NULL | 任务ID |
| user_id | BIGINT | FOREIGN KEY, NOT NULL | 协作者ID |
| role | VARCHAR(20) | NOT NULL, DEFAULT 'member' | 角色：member, viewer |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |

### 4.11 通知表 (notifications)

| 字段名 | 数据类型 | 约束 | 说明 |
|-------|---------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 通知ID |
| user_id | BIGINT | FOREIGN KEY, NOT NULL | 接收者ID |
| title | VARCHAR(100) | NOT NULL | 通知标题 |
| content | TEXT | NOT NULL | 通知内容 |
| type | VARCHAR(20) | NOT NULL | 通知类型：system, task, reminder |
| related_id | BIGINT | | 关联ID（如任务ID） |
| is_read | BOOLEAN | NOT NULL, DEFAULT 0 | 是否已读 |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |

## 5. 索引设计

### 5.1 用户表索引

| 索引名 | 类型 | 包含字段 | 说明 |
|--------|------|---------|------|
| PRIMARY | 主键 | id | 主键索引 |
| idx_username | 唯一索引 | username | 用户名索引，加速登录查询 |
| idx_email | 唯一索引 | email | 邮箱索引，加速登录查询 |
| idx_department | 普通索引 | department_id | 加速部门用户查询 |
| idx_status | 普通索引 | status | 加速状态筛选 |

### 5.2 部门表索引

| 索引名 | 类型 | 包含字段 | 说明 |
|--------|------|---------|------|
| PRIMARY | 主键 | id | 主键索引 |
| idx_code | 唯一索引 | code | 部门编码索引 |
| idx_parent | 普通索引 | parent_id | 加速父子部门查询 |
| idx_path | 普通索引 | path | 加速部门层级查询 |
| idx_leader | 普通索引 | leader_id | 加速部门负责人查询 |

### 5.3 任务表索引

| 索引名 | 类型 | 包含字段 | 说明 |
|--------|------|---------|------|
| PRIMARY | 主键 | id | 主键索引 |
| idx_creator | 普通索引 | creator_id | 加速创建者任务查询 |
| idx_assignee | 普通索引 | assignee_id | 加速负责人任务查询 |
| idx_department | 普通索引 | department_id | 加速部门任务查询 |
| idx_status | 普通索引 | status | 加速状态筛选 |
| idx_priority | 普通索引 | priority | 加速优先级筛选 |
| idx_due_date | 普通索引 | due_date | 加速到期任务查询 |
| idx_parent | 普通索引 | parent_id | 加速父子任务查询 |
| idx_path | 普通索引 | path | 加速任务层级查询 |
| idx_created | 普通索引 | created_at | 加速创建时间排序 |
| composite_idx_status_priority | 复合索引 | status, priority | 加速状态和优先级联合筛选 |

## 6. 关系约束

### 6.1 外键约束

| 表名 | 外键字段 | 关联表 | 关联字段 | 更新行为 | 删除行为 |
|------|---------|-------|---------|----------|---------|
| users | department_id | departments | id | CASCADE | SET NULL |
| departments | parent_id | departments | id | CASCADE | SET NULL |
| departments | leader_id | users | id | CASCADE | SET NULL |
| user_roles | user_id | users | id | CASCADE | CASCADE |
| user_roles | role_id | roles | id | CASCADE | CASCADE |
| role_permissions | role_id | roles | id | CASCADE | CASCADE |
| role_permissions | permission_id | permissions | id | CASCADE | CASCADE |
| tasks | creator_id | users | id | CASCADE | RESTRICT |
| tasks | assignee_id | users | id | CASCADE | SET NULL |
| tasks | reviewer_id | users | id | CASCADE | SET NULL |
| tasks | department_id | departments | id | CASCADE | SET NULL |
| tasks | parent_id | tasks | id | CASCADE | CASCADE |
| attachments | task_id | tasks | id | CASCADE | CASCADE |
| attachments | uploader_id | users | id | CASCADE | RESTRICT |
| comments | task_id | tasks | id | CASCADE | CASCADE |
| comments | user_id | users | id | CASCADE | CASCADE |
| task_collaborators | task_id | tasks | id | CASCADE | CASCADE |
| task_collaborators | user_id | users | id | CASCADE | CASCADE |
| notifications | user_id | users | id | CASCADE | CASCADE |

### 6.2 唯一约束

| 表名 | 约束字段 | 说明 |
|------|---------|------|
| users | username | 用户名唯一 |
| users | email | 邮箱唯一 |
| departments | code | 部门编码唯一 |
| roles | name | 角色名称唯一 |
| roles | code | 角色编码唯一 |
| permissions | code | 权限编码唯一 |
| user_roles | [user_id, role_id] | 用户角色唯一组合 |
| role_permissions | [role_id, permission_id] | 角色权限唯一组合 |
| task_collaborators | [task_id, user_id] | 任务协作者唯一组合 |

## 7. 数据访问策略

### 7.1 ORM配置

系统使用Sequelize作为ORM框架，主要配置如下：

```javascript
// 数据库连接配置
const sequelize = new Sequelize({
  dialect: 'mysql',
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  pool: {
    max: 10,
    min: 0,
    acquire: 30000,
    idle: 10000
  },
  logging: process.env.NODE_ENV === 'development' ? console.log : false,
  define: {
    timestamps: true,
    underscored: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at'
  }
});
```

### 7.2 数据库连接池配置

| 配置项 | 值 | 说明 |
|-------|-----|------|
| 最大连接数 | 10 | 单实例最大维持10个数据库连接 |
| 最小连接数 | 0 | 空闲时连接数可降为0 |
| 连接获取超时 | 30秒 | 获取连接的最大等待时间 |
| 空闲超时 | 10秒 | 空闲连接保持的最长时间 |

### 7.3 读写分离策略

对于生产环境，系统采用读写分离策略：

1. **写操作**：路由到主数据库
   - INSERT、UPDATE、DELETE语句
   - 事务性操作
   
2. **读操作**：路由到只读副本
   - SELECT查询
   - 报表和统计分析

配置示例：

```javascript
const replicaConfig = {
  read: [
    { host: 'read-replica-1', username: '...', password: '...' },
    { host: 'read-replica-2', username: '...', password: '...' }
  ],
  write: { host: 'master', username: '...', password: '...' }
};
```

### 7.4 缓存策略

系统采用多级缓存策略提升性能：

1. **一级缓存**：应用内存缓存
   - 用户会话和权限信息
   - 系统配置和常量数据
   
2. **二级缓存**：Redis分布式缓存
   - 热点数据（常用任务列表、仪表板数据）
   - 用户会话
   - 计数器和统计数据

缓存失效策略：

| 数据类型 | 缓存时间 | 失效方式 |
|----------|---------|---------|
| 用户会话 | 2小时 | 过期自动失效+手动登出清除 |
| 权限数据 | 1小时 | 过期自动失效+权限变更主动清除 |
| 任务列表 | 5分钟 | 过期自动失效+数据变更主动清除 |
| 统计数据 | 30分钟 | 过期自动失效+定时任务更新 |

## 8. 数据存储与备份

### 8.1 数据备份策略

| 备份类型 | 频率 | 保留时间 | 说明 |
|---------|------|---------|------|
| 全量备份 | 每日 | 30天 | 每天凌晨进行一次全量数据备份 |
| 增量备份 | 每小时 | 24小时 | 每小时进行增量备份，保留24个小时的增量备份 |
| 事务日志 | 实时 | 7天 | 实时备份事务日志，用于时间点恢复 |

### 8.2 文件存储策略

任务附件文件存储策略：

1. **存储位置**：对象存储服务（如AWS S3、阿里云OSS）
2. **目录结构**：`/tasks/[task_id]/[file_id].[extension]`
3. **访问控制**：签名URL方式临时授权访问
4. **生命周期**：与关联任务生命周期一致
5. **备份策略**：冗余存储，定期校验

---

*文档结束* 