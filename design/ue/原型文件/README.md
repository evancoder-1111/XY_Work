# 原型文件

本目录存放交互原型文件，包括：

## 文件说明

- **HTML 静态原型**：可直接在浏览器中打开查看的交互原型
  - `index.html` - 原型导航页面（推荐从此开始）
  - `login-prototype.html` - 登录页原型
  - `portal-prototype.html` - 工作台原型
  - `entry-management-prototype.html` - 入口管理原型

- **公共资源**：
  - `assets/css/common.css` - 公共样式文件
  - `assets/js/common.js` - 公共脚本文件

- **原型说明文档**：原型的详细说明和使用指南
  - `prototype-guide.md` - 原型使用指南
  - `Figma设计规范.md` - Figma 设计规范文档
  - `Figma设计反馈与建议.md` - Figma 设计分析反馈

## 使用方式

### 方式一：实时预览（推荐）

1. 启动本地服务器：
   ```bash
   cd design/ue/原型文件
   python -m http.server 8080
   ```

2. 在浏览器中访问：
   - 导航页：http://localhost:8080/index.html
   - 登录页：http://localhost:8080/login-prototype.html
   - 工作台：http://localhost:8080/portal-prototype.html
   - 入口管理：http://localhost:8080/entry-management-prototype.html

### 方式二：直接打开

直接在浏览器中打开 HTML 文件（部分功能可能受限）

## 原型功能

### 登录页原型
- ✅ SSO 登录 / 企业账号登录切换
- ✅ 表单验证和错误提示
- ✅ 记住密码功能
- ✅ 响应式设计（Web + 移动端）

### 工作台原型
- ✅ 统计卡片展示
- ✅ 考勤打卡快速入口
- ✅ 系统入口卡片（支持拖拽排序）
- ✅ 待办任务列表
- ✅ 最近活动记录
- ✅ 网格/列表视图切换

### 入口管理原型
- ✅ 搜索和分类筛选
- ✅ 网格/列表视图切换
- ✅ 统计信息展示
- ✅ 添加/编辑/删除入口
- ✅ 模态对话框交互

## 技术说明

- **样式**：使用 CSS Variables 定义设计 token
- **交互**：原生 JavaScript 实现
- **拖拽**：使用 SortableJS 库
- **响应式**：移动端 < 768px，桌面端 ≥ 768px

## 设计规范

所有原型遵循项目设计规范：
- 颜色：主色 #1890ff，成功 #52c41a，警告 #faad14，错误 #f5222d
- 字体：PingFang SC, 微软雅黑, Microsoft YaHei
- 间距：4px 基础单位
- 圆角：按钮 4px，卡片 6px，弹窗 8px

