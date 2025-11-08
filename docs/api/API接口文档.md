# API 接口文档

## 基础信息

- **Base URL**: `http://localhost:8080`
- **API 版本**: `v1`
- **API 前缀**: `/api/v1`
- **认证方式**: JWT Token（Bearer Token）
- **数据格式**: JSON

## 统一响应格式

### 成功响应

```json
{
  "code": 200,
  "message": "操作成功",
  "data": {}
}
```

### 错误响应

```json
{
  "code": 400,
  "message": "错误信息",
  "requestId": "2025-01-15-xxx"
}
```

### 错误码说明

| 错误码 | 说明 |
|--------|------|
| 200 | 操作成功 |
| 400 | 请求参数错误 |
| 401 | 未授权，Token 无效或过期 |
| 403 | 无权限访问 |
| 404 | 资源不存在 |
| 409 | 资源冲突 |
| 500 | 服务器内部错误 |

## 认证接口

### 1. SSO 登录

**接口地址**: `POST /api/v1/auth/sso/login`

**请求头**:
```
Content-Type: application/json
```

**请求体**:
```json
{
  "username": "admin",
  "password": "123456"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "登录成功",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "username": "admin",
      "nickname": "管理员",
      "email": "admin@example.com",
      "role": "ADMIN",
      "avatar": "https://example.com/avatar.jpg"
    }
  }
}
```

**错误响应**:
```json
{
  "code": 401,
  "message": "用户名或密码错误",
  "requestId": "2025-01-15-xxx"
}
```

### 2. 获取当前用户信息

**接口地址**: `GET /api/v1/auth/user`

**请求头**:
```
Authorization: Bearer {token}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "id": 1,
    "username": "admin",
    "nickname": "管理员",
    "email": "admin@example.com",
    "role": "ADMIN",
    "avatar": "https://example.com/avatar.jpg",
    "permissions": ["portal:read", "portal:write"]
  }
}
```

### 3. 退出登录

**接口地址**: `POST /api/v1/auth/logout`

**请求头**:
```
Authorization: Bearer {token}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "退出成功",
  "data": null
}
```

## 门户入口接口

### 1. 获取入口列表

**接口地址**: `GET /api/v1/portal/entries`

**请求头**:
```
Authorization: Bearer {token}
```

**查询参数**:
- `category` (可选): 分类筛选，如 `业务系统`、`协作工具`、`管理系统`
- `keyword` (可选): 关键词搜索，搜索名称和描述
- `status` (可选): 状态筛选，`active` 或 `inactive`
- `page` (可选): 页码，默认 1
- `pageSize` (可选): 每页数量，默认 20

**请求示例**:
```
GET /api/v1/portal/entries?category=业务系统&keyword=ERP&page=1&pageSize=20
```

**响应示例**:
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "list": [
      {
        "id": 1,
        "name": "ERP系统",
        "description": "企业资源规划系统",
        "icon": "📊",
        "url": "https://erp.example.com",
        "category": "业务系统",
        "status": "active",
        "createdAt": "2025-01-15T10:00:00",
        "updatedAt": "2025-01-15T10:00:00"
      }
    ],
    "total": 10,
    "page": 1,
    "pageSize": 20
  }
}
```

### 2. 创建入口

**接口地址**: `POST /api/v1/portal/entries`

**请求头**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**请求体**:
```json
{
  "name": "CRM系统",
  "description": "客户关系管理系统",
  "icon": "👥",
  "url": "https://crm.example.com",
  "category": "业务系统",
  "status": "active"
}
```

**字段说明**:
- `name` (必填): 系统名称，最大长度 255
- `description` (可选): 系统描述，最大长度 512
- `icon` (可选): 图标，支持 Emoji 或图标 URL
- `url` (必填): 访问地址，必须是有效的 URL
- `category` (可选): 分类，如 `业务系统`、`协作工具`、`管理系统`
- `status` (可选): 状态，`active` 或 `inactive`，默认 `active`

**响应示例**:
```json
{
  "code": 200,
  "message": "创建成功",
  "data": {
    "id": 2,
    "name": "CRM系统",
    "description": "客户关系管理系统",
    "icon": "👥",
    "url": "https://crm.example.com",
    "category": "业务系统",
    "status": "active",
    "createdAt": "2025-01-15T10:30:00",
    "updatedAt": "2025-01-15T10:30:00"
  }
}
```

**错误响应**:
```json
{
  "code": 400,
  "message": "参数验证失败：name 不能为空",
  "requestId": "2025-01-15-xxx"
}
```

### 3. 更新入口

**接口地址**: `PUT /api/v1/portal/entries/{id}`

**请求头**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**路径参数**:
- `id`: 入口 ID

**请求体**:
```json
{
  "name": "CRM系统（更新）",
  "description": "客户关系管理系统 - 已更新",
  "icon": "👥",
  "url": "https://crm-new.example.com",
  "category": "业务系统",
  "status": "active"
}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "更新成功",
  "data": {
    "id": 2,
    "name": "CRM系统（更新）",
    "description": "客户关系管理系统 - 已更新",
    "icon": "👥",
    "url": "https://crm-new.example.com",
    "category": "业务系统",
    "status": "active",
    "createdAt": "2025-01-15T10:30:00",
    "updatedAt": "2025-01-15T11:00:00"
  }
}
```

**错误响应**:
```json
{
  "code": 404,
  "message": "入口不存在",
  "requestId": "2025-01-15-xxx"
}
```

### 4. 删除入口

**接口地址**: `DELETE /api/v1/portal/entries/{id}`

**请求头**:
```
Authorization: Bearer {token}
```

**路径参数**:
- `id`: 入口 ID

**响应示例**:
```json
{
  "code": 200,
  "message": "删除成功",
  "data": null
}
```

**错误响应**:
```json
{
  "code": 404,
  "message": "入口不存在",
  "requestId": "2025-01-15-xxx"
}
```

### 5. 更新入口排序

**接口地址**: `PUT /api/v1/portal/entries/sort`

**请求头**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**请求体**:
```json
[1, 2, 3, 4, 5]
```
入口ID数组，按新顺序排列

**响应示例**:
```json
{
  "code": 200,
  "message": "操作成功",
  "data": null
}
```

**错误响应**:
```json
{
  "code": 400,
  "message": "入口不存在: 999",
  "requestId": "2025-01-15-xxx"
}
```

## 工作台接口

### 1. 获取统计信息

**接口地址**: `GET /api/v1/dashboard/stats`

**请求头**:
```
Authorization: Bearer {token}
```

**响应示例**:
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "todoTasks": {
      "count": 12,
      "trend": "+3",
      "trendType": "up"
    },
    "todayVisits": {
      "count": 48,
      "trend": "+12%",
      "trendType": "up"
    },
    "pendingApprovals": {
      "count": 5,
      "trend": "-2",
      "trendType": "down"
    },
    "notifications": {
      "count": 23,
      "trend": "+8",
      "trendType": "up"
    }
  }
}
```

### 2. 获取待办任务

**接口地址**: `GET /api/v1/dashboard/tasks`

**请求头**:
```
Authorization: Bearer {token}
```

**查询参数**:
- `page` (可选): 页码，默认 1
- `pageSize` (可选): 每页数量，默认 10
- `priority` (可选): 优先级筛选，`high`、`medium`、`low`

**响应示例**:
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "list": [
      {
        "id": 1,
        "title": "审批采购申请 #2024001",
        "priority": "high",
        "dueDate": "2025-01-15T18:00:00",
        "source": "ERP系统",
        "status": "pending"
      },
      {
        "id": 2,
        "title": "完成月度总结报告",
        "priority": "medium",
        "dueDate": "2025-01-16T12:00:00",
        "source": "OA系统",
        "status": "pending"
      }
    ],
    "total": 12,
    "page": 1,
    "pageSize": 10
  }
}
```

### 3. 获取最近活动

**接口地址**: `GET /api/v1/dashboard/activities`

**请求头**:
```
Authorization: Bearer {token}
```

**查询参数**:
- `page` (可选): 页码，默认 1
- `pageSize` (可选): 每页数量，默认 10

**响应示例**:
```json
{
  "code": 200,
  "message": "获取成功",
  "data": {
    "list": [
      {
        "id": 1,
        "title": "登录ERP系统",
        "type": "login",
        "source": "ERP系统",
        "timestamp": "2025-01-15T14:30:00"
      },
      {
        "id": 2,
        "title": "审批完成采购申请 #2024000",
        "type": "approval",
        "source": "ERP系统",
        "timestamp": "2025-01-15T13:00:00"
      }
    ],
    "total": 20,
    "page": 1,
    "pageSize": 10
  }
}
```

## 请求示例

### cURL 示例

```bash
# SSO 登录
curl -X POST http://localhost:8080/api/v1/auth/sso/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "123456"
  }'

# 获取入口列表
curl -X GET http://localhost:8080/api/v1/portal/entries \
  -H "Authorization: Bearer {token}"

# 创建入口
curl -X POST http://localhost:8080/api/v1/portal/entries \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "CRM系统",
    "description": "客户关系管理系统",
    "icon": "👥",
    "url": "https://crm.example.com",
    "category": "业务系统"
  }'
```

### JavaScript 示例

```javascript
// 使用 Axios
import axios from 'axios'

const api = axios.create({
  baseURL: 'http://localhost:8080/api/v1',
  headers: {
    'Content-Type': 'application/json'
  }
})

// 登录
const login = async (username, password) => {
  const response = await api.post('/auth/sso/login', {
    username,
    password
  })
  const token = response.data.data.token
  // 存储 token
  localStorage.setItem('token', token)
  return response.data
}

// 获取入口列表
const getEntries = async (category, keyword) => {
  const token = localStorage.getItem('token')
  const response = await api.get('/portal/entries', {
    params: { category, keyword },
    headers: {
      Authorization: `Bearer ${token}`
    }
  })
  return response.data
}
```

## 注意事项

1. 所有需要认证的接口必须在请求头中携带 `Authorization: Bearer {token}`
2. Token 过期时间为 24 小时，过期后需要重新登录
3. 所有时间字段使用 ISO 8601 格式：`YYYY-MM-DDTHH:mm:ss`
4. 分页参数 `page` 从 1 开始
5. 所有字符串字段支持 UTF-8 编码
6. URL 字段必须是有效的 HTTP/HTTPS 地址

