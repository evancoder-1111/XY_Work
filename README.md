# AI数字门户项目

## 项目简介

这是一个基于AI技术的统一数字门户系统，包含以下核心功能：

1. **统一数字门户**：支持自定义系统入口和SSO单点登录，提供角色化工作台
2. **AI编码助手**：提供代码补全、自动注释和定制化提示词库功能

## 项目结构

```
.
├── README.md              # 项目说明文档（本文件）
├── CONTRIBUTING.md        # 贡献指南
├── workspace.code-workspace  # VS Code 工作区配置
├── design/                # UI/UX 设计产物
│   ├── ui/                # UI 规范、组件、图标
│   │   ├── README.md
│   │   ├── 设计规范.md
│   │   ├── 组件库规则.md
│   │   └── 图标与图片资源规范.md
│   ├── ux/                # 流程、线框、原型
│   │   ├── README.md
│   │   ├── 信息架构.md
│   │   ├── 用户角色与任务分析.md
│   │   ├── 用户体验设计方案.md
│   │   ├── 用户流程图.md
│   │   ├── 低保真线框图.md
│   │   └── 用户测试与评估计划.md
│   └── ue/                # 交互设计文档
│       ├── README.md
│       ├── XY_Work_移动端和Web端用户体验设计.md
│       ├── 交互设计/      # 交互流程图和规范
│       ├── 用户流程/      # 用户操作流程文档
│       └── 原型文件/      # 交互原型文件
│           ├── README.md
│           ├── prototype-guide.md
│           ├── login-prototype.html
│           ├── portal-prototype.html
│           └── entry-management-prototype.html
├── frontend/              # Vue 3 前端项目
│   └── XY_Portal_Frontend/  # 前端子项目目录
├── backend/               # Spring Boot 后端项目
│   └── XY_Portal/         # 后端子项目目录
├── docs/                  # 规范与需求文档
│   ├── requirements/      # 需求文档
│   │   └── 一阶段_前后端功能.md
│   ├── rules/             # 各类规范文档
│   │   ├── coding-standards.md      # 编码规范
│   │   ├── api-style-guide.md       # API 设计规范
│   │   ├── ui-ux-guidelines.md       # UI/UX 规范
│   │   ├── security-compliance.md    # 安全与合规
│   │   ├── testing-guidelines.md     # 测试规范
│   │   ├── documentation-style.md   # 文档规范
│   │   └── project_rules.md         # 项目规则
│   └── architecture/      # 架构与技术文档
│       ├── 技术架构.md
│       └── 开发规范.md
├── testing/               # 测试相关文件
│   ├── 单元测试/          # 前后端单元测试
│   │   ├── 前端单元测试/
│   │   └── 后端单元测试/
│   ├── 集成测试/          # 集成测试用例
│   ├── 端到端测试/        # E2E测试
│   └── 测试报告/          # 测试报告存放
└── scripts/               # 脚本文件
```

## 技术栈

### 前端
- **框架**：Vue 3 + TypeScript
- **构建工具**：Vite
- **UI组件库**：Element Plus
- **状态管理**：Pinia
- **路由**：Vue Router
- **代码编辑器**：Monaco Editor
- **HTTP客户端**：Axios

### 后端
- **框架**：Spring Boot
- **安全**：Spring Security + JWT
- **数据访问**：Spring Data JPA
- **数据库**：MySQL
- **API文档**：Swagger/OpenAPI

### 测试
- **前端测试**：Vitest + Vue Test Utils
- **后端测试**：JUnit 5 + Mockito
- **E2E测试**：Playwright / Cypress

### 统一数字门户
- SSO单点登录（OAuth2/SAML）
- 自定义系统入口管理
- 角色化工作台（管理层、产品经理、开发者、测试人员）
- 待办任务与通知聚合

## Git 仓库

项目已配置 Git 版本控制。如需提交到远程仓库，请参考 [Git 提交指南](./docs/Git提交指南.md)。

快速初始化 Git 仓库：
```bash
# 使用 PowerShell 脚本（推荐）
.\scripts\git-setup.ps1

# 或手动执行
git init
git add .
git commit -m "初始提交：星元空间统一数字门户项目"
```

## 快速开始

### 环境要求
- Node.js >= 18.0.0
- Java >= 17
- MySQL >= 8.0
- Maven >= 3.8

### 前端启动
```bash
cd frontend/XY_Portal_Frontend
npm install
npm run dev
```
前端服务将运行在 `http://localhost:8081`

### 后端启动
```bash
cd backend/XY_Portal
mvn clean install
mvn spring-boot:run
```
后端服务将运行在 `http://localhost:8080`

### 数据库初始化
1. 创建 MySQL 数据库：
```sql
CREATE DATABASE IF NOT EXISTS `xy_portal` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. 执行初始化脚本：
```bash
# 执行表结构脚本
mysql -u root -p xy_portal < backend/XY_Portal/src/main/resources/db/schema.sql

# 执行初始数据脚本
mysql -u root -p xy_portal < backend/XY_Portal/src/main/resources/db/data.sql
```

3. 配置数据库连接（修改 `backend/XY_Portal/src/main/resources/application.yml`）：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/xy_portal?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: your_password
```

### 测试账号
- 用户名：`admin`
- 密码：`admin123`

### 常见问题

#### 前端启动问题
1. **npm install 失败（证书错误）**
   - 使用国内镜像：`npm config set registry https://registry.npmmirror.com`
   - 或关闭严格SSL：`npm config set strict-ssl false`

2. **端口被占用**
   - 修改 `vite.config.ts` 中的 `server.port` 配置

#### 后端启动问题
1. **数据库连接失败**
   - 检查 MySQL 服务是否运行
   - 检查 `application.yml` 中的数据库配置
   - 确认数据库 `xy_portal` 已创建

2. **端口被占用**
   - 修改 `application.yml` 中的 `server.port` 配置

#### 功能使用说明
1. **拖拽排序**：在工作台页面，可以直接拖拽应用入口卡片调整顺序
2. **入口管理**：登录后访问"入口管理"页面，可以添加、编辑、删除系统入口
3. **搜索筛选**：在入口管理页面，支持按分类和关键词搜索

## 开发指南

详细的开发指南请参考各子模块的README文档：
- [前端开发指南](./frontend/XY_Portal_Frontend/README.md)
- [后端开发指南](./backend/XY_Portal/README.md)
- [API接口文档](./docs/api/API接口文档.md)
- [数据库设计文档](./docs/database/数据库设计文档.md)
- [设计规范](./design/ui/README.md)
- [需求文档](./docs/requirements/一阶段_前后端功能.md)

## 贡献指南

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

[待定]

