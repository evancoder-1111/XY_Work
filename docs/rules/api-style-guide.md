# API 设计规范（REST）

## 1. 基本约定（Basics）
- 前缀与版本：`/api/v1`
- 资源路径：名词复数（例：/users, /portal-entries）
- 嵌套资源：`/projects/{id}/members`
- **HTTP 方法**：
  - `GET`：获取资源（幂等）
  - `POST`：创建资源（非幂等）
  - `PUT`：更新资源（幂等）
  - `DELETE`：删除资源（幂等）
  - `PATCH`：部分更新资源（幂等）
- **命名规则**：
  - 路径使用小写字母和连字符（kebab-case）
  - 避免使用动词在 URL 中
  - 嵌套资源使用层次结构

## 2. 分页/排序/筛选（Pagination/Sorting/Filtering）
- 请求参数：`?page=1&pageSize=20&sort=createdAt,desc&status=active`
- 返回体：
```json
{ "data": [], "page": 1, "pageSize": 20, "total": 0 }
```

## 3. 响应与错误（Response & Errors）
- 成功：`200/201`，返回 data 或资源
- 错误统一结构：
```json
{ "code": "INVALID_PARAM", "message": "参数错误", "requestId": "2025-11-06-xxx" }
```
- 常见错误码：INVALID_PARAM / UNAUTHORIZED / FORBIDDEN / NOT_FOUND / CONFLICT / INTERNAL_ERROR

## 4. 鉴权（Auth）
- JWT：`Authorization: Bearer <token>`
- SSO：OAuth2/SAML 对接；后端统一校验

## 5. 幂等（Idempotency）
- 写操作支持 `Idempotency-Key` 请求头

## 6. 约束（Validation）
- 请求体字段校验（长度/格式/范围）；拒绝未知字段（strict）
- 返回体字段稳定；新增字段向后兼容

## 7. 可观测性（Observability）
- 响应头包含 `X-Request-Id`；日志关联 requestId、用户、URI、耗时

## 8. 文档（Docs）
- OpenAPI（Swagger）自动生成；示例覆盖常见场景

## 9. API 版本管理（Version Management）

### 9.1 版本策略
- **URI 路径版本**：使用 `/api/v1/` 形式的版本标识（推荐）
- **头部版本**：`Accept-Version: v1` 或 `API-Version: v1`
- **内容协商版本**：`Accept: application/vnd.example.v1+json`

### 9.2 版本兼容性
- **向下兼容**：新版本 API 必须兼容旧版本的客户端
- **废弃机制**：标记废弃的 API 必须提供替代方案
- **废弃通知**：废弃 API 提前 3 个月通知用户
- **版本生命周期**：主版本至少维护 12 个月

## 10. 批量操作（Bulk Operations）

### 10.1 批量创建
- **路径**：`POST /api/v1/resource/batch`
- **请求体**：包含 items 数组和 validateOnly 标志
- **响应**：返回创建的资源列表和错误信息

### 10.2 批量更新
- **路径**：`PUT /api/v1/resource/batch`
- **请求体**：包含 items 数组，每个项目必须有 ID

### 10.3 批量删除
- **路径**：`DELETE /api/v1/resource/batch`
- **请求体**：包含 ids 数组
- 或使用查询参数：`DELETE /api/v1/resource?ids=1,2,3`

### 10.4 批量限制
- 单次批量操作最多支持 1000 条记录
- 超出限制时返回 413 Payload Too Large 错误

## 11. 安全性（Security）

### 11.1 认证授权
- **JWT 最佳实践**：
  - Token 过期时间设置合理（如 15-30 分钟）
  - 使用刷新令牌机制
  - 敏感操作重新验证身份
- **权限控制**：
  - 基于角色的访问控制（RBAC）
  - 细粒度的权限检查
  - 最小权限原则

### 11.2 数据安全
- **输入验证**：所有输入必须经过严格验证
- **数据脱敏**：返回敏感数据时进行脱敏处理
- **传输安全**：强制使用 HTTPS
- **数据加密**：敏感数据在数据库中加密存储

### 11.3 防护措施
- **CSRF 防护**：使用 CSRF Token
- **XSS 防护**：对输出数据进行转义
- **SQL 注入防护**：使用参数化查询
- **速率限制**：防止暴力攻击和 DoS 攻击

## 12. 性能优化（Performance）

### 12.1 响应优化
- **数据压缩**：支持 GZIP/Brotli 压缩
- **响应缓存**：使用 HTTP 缓存头（ETag, Last-Modified）
- **字段筛选**：支持 `fields` 参数选择返回字段
- **响应大小**：单次响应数据量不宜过大（建议 < 1MB）

### 12.2 查询优化
- **索引优化**：合理设计数据库索引
- **查询优化**：避免 N+1 查询问题
- **预加载**：支持 `include` 参数预加载关联数据
- **数据分页**：强制使用分页查询大数据集

## 13. 状态管理（State Management）

### 13.1 资源状态
- **状态表示**：使用明确的状态码或枚举值
- **状态转换**：提供状态机定义，明确状态转换规则
- **状态查询**：提供按状态筛选和统计的能力

### 13.2 乐观锁
- **版本控制**：使用 `version` 字段或 `ETag` 实现乐观锁
- **并发控制**：检测并发更新冲突并返回适当的错误

## 14. API 示例（API Examples）

### 14.1 标准 CRUD 操作

**获取用户列表**
```
GET /api/v1/users?page=1&pageSize=20&status=active&sort=createdAt,desc

响应：
{ "data": [...], "page": 1, "pageSize": 20, "total": 100 }
```

**创建用户**
```
POST /api/v1/users
Content-Type: application/json

请求体：
{ "name": "李四", "email": "lisi@example.com", "phone": "13900139000" }
```

### 14.2 批量操作示例

**批量创建用户**
```
POST /api/v1/users/batch
Content-Type: application/json

请求体：
{ "items": [{ "name": "王五", "email": "wangwu@example.com" }] }
```

