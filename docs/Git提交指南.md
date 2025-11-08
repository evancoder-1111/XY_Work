# Git 提交指南

## 项目已准备提交到 Git

### 已完成的准备工作

1. ✅ 创建了根目录 `.gitignore` 文件
2. ✅ 已初始化 Git 仓库（如果尚未初始化）
3. ✅ 配置了忽略规则，排除不必要的文件

### 手动提交步骤

如果 Git 命令在终端中无法执行，您可以按照以下步骤手动操作：

#### 1. 初始化 Git 仓库（如果尚未初始化）

```bash
cd D:\work\XY_Work
git init
```

#### 2. 添加所有文件到暂存区

```bash
git add .
```

#### 3. 创建初始提交

```bash
git commit -m "初始提交：星元空间统一数字门户项目

- 完成前后端核心功能开发
- 实现 SSO 登录认证
- 实现门户入口管理（CRUD）
- 实现工作台拖拽排序功能
- 完善错误处理和响应式设计
- 更新项目文档和 API 接口文档"
```

#### 4. 查看提交历史

```bash
git log --oneline
```

### 连接到远程仓库（可选）

如果您已经有远程仓库（如 GitHub、GitLab），可以添加远程地址：

```bash
# 添加远程仓库
git remote add origin <您的仓库地址>

# 推送到远程仓库
git branch -M main
git push -u origin main
```

### 常用 Git 命令

```bash
# 查看状态
git status

# 查看提交历史
git log --oneline

# 查看文件变更
git diff

# 创建新分支
git checkout -b feature/新功能

# 切换分支
git checkout main

# 合并分支
git merge feature/新功能
```

### 提交规范建议

建议使用以下提交信息格式：

```
<类型>(<范围>): <主题>

<详细描述>

<相关Issue>
```

**类型**：
- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式调整
- `refactor`: 代码重构
- `test`: 测试相关
- `chore`: 构建/工具相关

**示例**：
```
feat(portal): 实现拖拽排序功能

- 添加 SortableJS 依赖
- 实现前端拖拽交互
- 添加后端排序接口
- 更新 API 文档

Closes #123
```

### 注意事项

1. **敏感信息**：确保 `.gitignore` 已正确配置，不要提交：
   - 数据库密码
   - API 密钥
   - 个人配置信息
   - `node_modules/` 目录
   - 构建输出文件

2. **大文件**：如果项目中有大文件，考虑使用 Git LFS

3. **分支策略**：建议使用以下分支策略：
   - `main`: 主分支，稳定版本
   - `develop`: 开发分支
   - `feature/*`: 功能分支
   - `hotfix/*`: 紧急修复分支

### 已配置的 .gitignore 规则

项目根目录的 `.gitignore` 已配置忽略：
- 操作系统文件（.DS_Store, Thumbs.db 等）
- IDE 配置文件（.idea/, .vscode/ 等）
- 依赖目录（node_modules/, target/ 等）
- 构建输出（dist/, build/ 等）
- 日志文件（*.log）
- 环境变量文件（.env）
- 敏感配置文件（application-*.yml，除了示例文件）

### 验证提交

提交后，可以使用以下命令验证：

```bash
# 查看提交的文件列表
git ls-files

# 查看提交统计
git log --stat

# 查看特定文件的提交历史
git log -- <文件路径>
```

