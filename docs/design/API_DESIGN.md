# 行政办公任务中心系统 - API设计

*文档编号：SDD-004*  
*版本：v1.0*  
*更新日期：2024-03-31*  
*关联文档：[系统设计概述](./SYSTEM_DESIGN_OVERVIEW.md)*

## 目录

- [1. 引言](#1-引言)
- [2. API设计原则](#2-api设计原则)
- [3. API认证与安全](#3-api认证与安全)
- [4. API版本控制](#4-api版本控制)
- [5. 通用响应格式](#5-通用响应格式)
- [6. 错误处理](#6-错误处理)
- [7. API端点设计](#7-api端点设计)
- [8. 接口文档与测试](#8-接口文档与测试)

## 1. 引言

本文档详细描述了行政办公任务中心系统的API设计，包括API架构、认证机制、端点定义和数据格式等，为前后端交互提供规范和指导。

## 2. API设计原则

系统API设计遵循以下原则：

1. **RESTful设计**：遵循REST原则，使用标准HTTP方法表达操作语义
2. **资源导向**：API围绕资源设计，而非操作
3. **一致性**：保持命名、参数和响应格式的一致性
4. **无状态**：API请求之间无状态依赖，便于伸缩
5. **分层设计**：API逻辑分层，便于维护和扩展

## 3. API认证与安全

### 3.1 认证方式

系统采用JWT（JSON Web Token）实现API认证：

1. **登录流程**：用户提供凭证后，服务端生成JWT令牌并返回
2. **请求认证**：客户端在请求头中携带令牌：`Authorization: Bearer <token>`
3. **令牌刷新**：提供刷新令牌API，避免频繁登录

### 3.2 安全措施

API安全保障措施：

1. **HTTPS加密**：所有API通信采用HTTPS加密传输
2. **CSRF防护**：实施CSRF令牌机制防御跨站请求伪造
3. **请求限流**：针对IP和用户的API访问频率限制
4. **参数验证**：严格校验所有输入参数，防止注入攻击
5. **权限控制**：基于RBAC的细粒度API权限控制

## 4. API版本控制

系统API版本控制采用URL路径方式：

```
https://api.example.com/v1/resources
```

版本更新策略：

1. **兼容性更新**：修复bug、新增字段等向后兼容的更改，在当前版本内进行
2. **不兼容更新**：更改数据结构、移除字段等不兼容更改，发布新版本API
3. **版本共存**：新版本发布后，旧版本保持可用状态一段时间（至少6个月）
4. **版本废弃**：提前3个月通知用户版本废弃计划

## 5. 通用响应格式

### 5.1 成功响应格式

```json
{
  "success": true,
  "code": 200,
  "message": "操作成功",
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 10,
    "totalItems": 100,
    "totalPages": 10
  }
}
```

### 5.2 错误响应格式

```json
{
  "success": false,
  "code": 400,
  "message": "请求参数错误",
  "errors": [
    {
      "field": "username",
      "message": "用户名不能为空"
    }
  ],
  "requestId": "req-123456"
}
```

## 6. 错误处理

### 6.1 HTTP状态码使用

| 状态码 | 使用场景 |
|-------|---------|
| 200 OK | 请求成功完成 |
| 201 Created | 资源创建成功 |
| 204 No Content | 请求成功但无返回内容（如删除操作） |
| 400 Bad Request | 请求参数错误或无效 |
| 401 Unauthorized | 用户未认证或认证失败 |
| 403 Forbidden | 用户已认证但权限不足 |
| 404 Not Found | 请求的资源不存在 |
| 409 Conflict | 请求冲突（如创建已存在资源） |
| 422 Unprocessable Entity | 请求格式正确但语义错误 |
| 429 Too Many Requests | 请求频率超限 |
| 500 Internal Server Error | 服务器内部错误 |

### 6.2 错误码设计

错误码格式：`A-BB-CCC`

- A：错误类型（1-客户端错误，2-服务端错误）
- BB：模块编号（01-用户，02-任务，03-部门等）
- CCC：具体错误编号

示例：

| 错误码 | 描述 | HTTP状态码 |
|-------|------|----------|
| 1-01-001 | 用户名或密码错误 | 401 |
| 1-01-002 | 用户账号已被锁定 | 403 |
| 1-02-001 | 任务不存在 | 404 |
| 1-02-002 | 无权操作此任务 | 403 |
| 2-01-001 | 用户服务内部错误 | 500 |
| 2-02-001 | 任务服务内部错误 | 500 |

## 7. API端点设计

### 7.1 认证API

#### 7.1.1 用户登录

- **URL**: `/v1/auth/login`
- **方法**: POST
- **描述**: 用户登录并获取访问令牌
- **请求参数**:

```json
{
  "username": "admin",
  "password": "password123",
  "rememberMe": true
}
```

- **响应**:

```json
{
  "success": true,
  "code": 200,
  "message": "登录成功",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600,
    "user": {
      "id": 1,
      "username": "admin",
      "realName": "管理员",
      "avatar": "https://example.com/avatar.jpg",
      "roles": ["admin"]
    }
  }
}
```

#### 7.1.2 刷新令牌

- **URL**: `/v1/auth/refresh-token`
- **方法**: POST
- **描述**: 使用刷新令牌获取新的访问令牌
- **请求参数**:

```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

- **响应**: 与登录响应相同

#### 7.1.3 退出登录

- **URL**: `/v1/auth/logout`
- **方法**: POST
- **描述**: 用户退出登录，使当前令牌失效
- **请求参数**: 无
- **响应**:

```json
{
  "success": true,
  "code": 200,
  "message": "退出成功"
}
```

### 7.2 用户API

#### 7.2.1 获取用户信息

- **URL**: `/v1/users/me`
- **方法**: GET
- **描述**: 获取当前登录用户信息
- **响应**:

```json
{
  "success": true,
  "code": 200,
  "data": {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com",
    "realName": "管理员",
    "phone": "13800138000",
    "avatar": "https://example.com/avatar.jpg",
    "department": {
      "id": 1,
      "name": "管理部"
    },
    "roles": [
      {
        "id": 1,
        "name": "系统管理员",
        "code": "admin"
      }
    ],
    "permissions": [
      "user:create",
      "user:read",
      "user:update",
      "user:delete"
    ],
    "lastLoginAt": "2024-03-30T10:30:00Z"
  }
}
```

#### 7.2.2 获取用户列表

- **URL**: `/v1/users`
- **方法**: GET
- **描述**: 分页获取用户列表
- **查询参数**:
  - `page`: 页码，默认1
  - `limit`: 每页数量，默认10
  - `keyword`: 搜索关键词
  - `departmentId`: 部门ID
  - `status`: 状态筛选
- **响应**:

```json
{
  "success": true,
  "code": 200,
  "data": [
    {
      "id": 1,
      "username": "admin",
      "realName": "管理员",
      "email": "admin@example.com",
      "department": {
        "id": 1,
        "name": "管理部"
      },
      "status": 1,
      "createdAt": "2024-01-01T00:00:00Z"
    }
    // 更多用户...
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "totalItems": 25,
    "totalPages": 3
  }
}
```

#### 7.2.3 创建用户

- **URL**: `/v1/users`
- **方法**: POST
- **描述**: 创建新用户
- **请求参数**:

```json
{
  "username": "newuser",
  "password": "password123",
  "email": "user@example.com",
  "realName": "新用户",
  "phone": "13900139000",
  "departmentId": 2,
  "roleIds": [2, 3]
}
```

- **响应**:

```json
{
  "success": true,
  "code": 201,
  "message": "用户创建成功",
  "data": {
    "id": 10,
    "username": "newuser",
    "realName": "新用户",
    "email": "user@example.com",
    "createdAt": "2024-03-31T08:30:00Z"
  }
}
```

#### 7.2.4 更新用户

- **URL**: `/v1/users/{id}`
- **方法**: PUT
- **描述**: 更新用户信息
- **请求参数**: 与创建用户类似，但密码字段可选

#### 7.2.5 删除用户

- **URL**: `/v1/users/{id}`
- **方法**: DELETE
- **描述**: 删除用户
- **响应**: 204 No Content

### 7.3 任务API

#### 7.3.1 获取任务列表

- **URL**: `/v1/tasks`
- **方法**: GET
- **描述**: 分页获取任务列表
- **查询参数**:
  - `page`: 页码，默认1
  - `limit`: 每页数量，默认10
  - `keyword`: 搜索关键词
  - `status`: 任务状态
  - `priority`: 优先级
  - `assigneeId`: 负责人ID
  - `departmentId`: 部门ID
  - `creatorId`: 创建者ID
  - `startDate`: 开始日期范围起始
  - `endDate`: 开始日期范围结束
  - `dueStartDate`: 截止日期范围起始
  - `dueEndDate`: 截止日期范围结束
  - `sort`: 排序字段，如`createdAt`
  - `order`: 排序方向，`asc`或`desc`
- **响应**:

```json
{
  "success": true,
  "code": 200,
  "data": [
    {
      "id": 1,
      "title": "编写需求文档",
      "description": "为新系统编写需求规格说明书",
      "status": "in_progress",
      "priority": 2,
      "progress": 60,
      "startDate": "2024-03-15",
      "dueDate": "2024-04-10",
      "creator": {
        "id": 1,
        "realName": "管理员"
      },
      "assignee": {
        "id": 2,
        "realName": "项目经理"
      },
      "department": {
        "id": 3,
        "name": "研发部"
      },
      "hasSubtasks": true,
      "subtaskCount": 5,
      "completedSubtaskCount": 3,
      "createdAt": "2024-03-15T09:30:00Z",
      "updatedAt": "2024-03-30T14:20:00Z"
    }
    // 更多任务...
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "totalItems": 42,
    "totalPages": 5
  }
}
```

#### 7.3.2 获取任务详情

- **URL**: `/v1/tasks/{id}`
- **方法**: GET
- **描述**: 获取单个任务的详细信息
- **响应**:

```json
{
  "success": true,
  "code": 200,
  "data": {
    "id": 1,
    "title": "编写需求文档",
    "description": "为新系统编写需求规格说明书",
    "status": "in_progress",
    "priority": 2,
    "progress": 60,
    "isImportant": true,
    "isUrgent": false,
    "startDate": "2024-03-15",
    "dueDate": "2024-04-10",
    "creator": {
      "id": 1,
      "realName": "管理员",
      "avatar": "https://example.com/avatar1.jpg"
    },
    "assignee": {
      "id": 2,
      "realName": "项目经理",
      "avatar": "https://example.com/avatar2.jpg"
    },
    "reviewer": {
      "id": 3,
      "realName": "技术总监",
      "avatar": "https://example.com/avatar3.jpg"
    },
    "department": {
      "id": 3,
      "name": "研发部"
    },
    "parent": null,
    "attachments": [
      {
        "id": 1,
        "filename": "需求模板.docx",
        "mimeType": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        "fileSize": 25600,
        "uploader": {
          "id": 1,
          "realName": "管理员"
        },
        "uploadTime": "2024-03-15T10:00:00Z"
      }
    ],
    "collaborators": [
      {
        "id": 4,
        "realName": "产品经理",
        "avatar": "https://example.com/avatar4.jpg",
        "role": "member"
      }
    ],
    "comments": [
      {
        "id": 1,
        "content": "请按照公司模板编写",
        "user": {
          "id": 3,
          "realName": "技术总监",
          "avatar": "https://example.com/avatar3.jpg"
        },
        "createdAt": "2024-03-16T08:30:00Z"
      }
    ],
    "subtasks": [
      {
        "id": 5,
        "title": "收集用户需求",
        "status": "completed",
        "assignee": {
          "id": 4,
          "realName": "产品经理"
        },
        "dueDate": "2024-03-20"
      },
      {
        "id": 6,
        "title": "编写功能规格",
        "status": "in_progress",
        "assignee": {
          "id": 2,
          "realName": "项目经理"
        },
        "dueDate": "2024-03-30"
      }
      // 更多子任务...
    ],
    "createdAt": "2024-03-15T09:30:00Z",
    "updatedAt": "2024-03-30T14:20:00Z"
  }
}
```

#### 7.3.3 创建任务

- **URL**: `/v1/tasks`
- **方法**: POST
- **描述**: 创建新任务
- **请求参数**:

```json
{
  "title": "开发登录功能",
  "description": "实现用户登录和认证功能",
  "priority": 2,
  "startDate": "2024-04-01",
  "dueDate": "2024-04-10",
  "assigneeId": 5,
  "reviewerId": 3,
  "departmentId": 3,
  "parentId": null,
  "isImportant": true,
  "isUrgent": false,
  "collaboratorIds": [6, 7]
}
```

- **响应**:

```json
{
  "success": true,
  "code": 201,
  "message": "任务创建成功",
  "data": {
    "id": 10,
    "title": "开发登录功能",
    "createdAt": "2024-03-31T09:30:00Z"
  }
}
```

#### 7.3.4 更新任务

- **URL**: `/v1/tasks/{id}`
- **方法**: PUT
- **描述**: 更新任务信息
- **请求参数**: 与创建任务类似

#### 7.3.5 更新任务状态

- **URL**: `/v1/tasks/{id}/status`
- **方法**: PATCH
- **描述**: 更新任务状态
- **请求参数**:

```json
{
  "status": "completed",
  "comment": "功能已完成并测试通过"
}
```

#### 7.3.6 删除任务

- **URL**: `/v1/tasks/{id}`
- **方法**: DELETE
- **描述**: 删除任务
- **响应**: 204 No Content

#### 7.3.7 上传任务附件

- **URL**: `/v1/tasks/{id}/attachments`
- **方法**: POST
- **描述**: 上传任务附件
- **请求参数**: multipart/form-data
- **响应**:

```json
{
  "success": true,
  "code": 201,
  "message": "附件上传成功",
  "data": {
    "id": 5,
    "filename": "设计图.png",
    "fileSize": 1024000,
    "mimeType": "image/png",
    "uploadTime": "2024-03-31T10:30:00Z"
  }
}
```

### 7.4 部门API

#### 7.4.1 获取部门树

- **URL**: `/v1/departments/tree`
- **方法**: GET
- **描述**: 获取部门层级树
- **响应**:

```json
{
  "success": true,
  "code": 200,
  "data": [
    {
      "id": 1,
      "name": "总公司",
      "code": "HQ",
      "leader": {
        "id": 1,
        "realName": "总经理"
      },
      "children": [
        {
          "id": 2,
          "name": "行政部",
          "code": "ADM",
          "leader": {
            "id": 3,
            "realName": "行政总监"
          },
          "children": []
        },
        {
          "id": 3,
          "name": "研发部",
          "code": "DEV",
          "leader": {
            "id": 2,
            "realName": "技术总监"
          },
          "children": [
            {
              "id": 5,
              "name": "前端组",
              "code": "DEV-FE",
              "leader": {
                "id": 6,
                "realName": "前端负责人"
              },
              "children": []
            },
            {
              "id": 6,
              "name": "后端组",
              "code": "DEV-BE",
              "leader": {
                "id": 7,
                "realName": "后端负责人"
              },
              "children": []
            }
          ]
        }
        // 更多部门...
      ]
    }
  ]
}
```

#### 7.4.2 创建部门

- **URL**: `/v1/departments`
- **方法**: POST
- **描述**: 创建新部门
- **请求参数**:

```json
{
  "name": "测试部",
  "code": "TEST",
  "parentId": 3,
  "leaderId": 8,
  "description": "负责系统测试工作"
}
```

### 7.5 统计API

#### 7.5.1 任务统计概览

- **URL**: `/v1/stats/tasks/overview`
- **方法**: GET
- **描述**: 获取任务统计概览数据
- **查询参数**:
  - `departmentId`: 部门ID，可选
  - `startDate`: 开始日期，可选
  - `endDate`: 结束日期，可选
- **响应**:

```json
{
  "success": true,
  "code": 200,
  "data": {
    "total": 120,
    "byStatus": {
      "pending": 30,
      "in_progress": 45,
      "completed": 35,
      "rejected": 5,
      "deferred": 5
    },
    "byPriority": {
      "1": 15,
      "2": 35,
      "3": 40,
      "4": 20,
      "5": 10
    },
    "byDepartment": [
      {
        "department": {
          "id": 2,
          "name": "行政部"
        },
        "count": 25
      },
      {
        "department": {
          "id": 3,
          "name": "研发部"
        },
        "count": 65
      },
      {
        "department": {
          "id": 4,
          "name": "市场部"
        },
        "count": 30
      }
    ],
    "completionRate": 0.75,
    "onTimeRate": 0.8,
    "overdue": 15
  }
}
```

#### 7.5.2 用户任务完成率

- **URL**: `/v1/stats/users/completion-rate`
- **方法**: GET
- **描述**: 获取用户任务完成率数据
- **查询参数**:
  - `departmentId`: 部门ID，可选
  - `startDate`: 开始日期，可选
  - `endDate`: 结束日期，可选
  - `limit`: 结果数量限制，默认10
- **响应**:

```json
{
  "success": true,
  "code": 200,
  "data": [
    {
      "user": {
        "id": 5,
        "realName": "张工程师"
      },
      "total": 20,
      "completed": 18,
      "rate": 0.9,
      "onTimeRate": 0.85
    },
    {
      "user": {
        "id": 6,
        "realName": "李工程师"
      },
      "total": 15,
      "completed": 12,
      "rate": 0.8,
      "onTimeRate": 0.75
    }
    // 更多用户...
  ]
}
```

## 8. 接口文档与测试

### 8.1 API文档

系统API文档使用Swagger/OpenAPI规范自动生成，并提供以下功能：

1. **接口可视化**：直观展示所有API端点和参数
2. **在线测试**：提供接口在线测试功能
3. **示例代码**：生成多种语言的调用示例
4. **模型定义**：展示数据模型定义和关系

文档访问地址：`/api/docs`

### 8.2 API测试

API测试策略：

1. **单元测试**：针对API处理逻辑的单元测试
2. **集成测试**：针对API端点的端到端测试
3. **性能测试**：模拟高并发场景下的API性能测试
4. **安全测试**：包括认证、授权和常见漏洞测试

测试工具：

- Jest：单元测试和集成测试
- Supertest：API请求测试
- k6：性能测试
- OWASP ZAP：安全测试

---

*文档结束* 