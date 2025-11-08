# 星元空间统一数字门户 - 前端项目

## 项目简介

星元空间统一数字门户前端项目，基于 Vue 3 + TypeScript + Element Plus 构建，提供统一的企业应用访问入口和个性化工作台。

## 技术栈

| 技术/框架 | 版本 | 用途 |
|---------|------|------|
| Vue | 3.x | 前端框架 |
| TypeScript | 5.x | 编程语言 |
| Vite | 5.x | 构建工具 |
| Vue Router | 4.x | 路由管理 |
| Pinia | 2.x | 状态管理 |
| Element Plus | 2.x | UI组件库 |
| Axios | 1.x | HTTP客户端 |

## 项目结构

```
XY_Portal_Frontend/
├── public/                 # 静态资源
│   └── favicon.ico
├── src/
│   ├── api/               # API 服务封装
│   │   ├── auth.ts        # 认证相关接口
│   │   ├── portal.ts      # 门户入口接口
│   │   └── index.ts       # Axios 实例配置
│   ├── assets/            # 资源文件
│   │   ├── css/          # 样式文件
│   │   └── images/       # 图片资源
│   ├── components/        # 公共组件
│   │   ├── Layout/       # 布局组件
│   │   │   ├── MainLayout.vue
│   │   │   ├── TopNav.vue
│   │   │   └── Sidebar.vue
│   │   └── common/       # 通用组件
│   ├── views/            # 页面组件
│   │   ├── Login/        # 登录页
│   │   │   └── LoginView.vue
│   │   ├── Portal/       # 工作台
│   │   │   └── PortalView.vue
│   │   └── EntryManagement/  # 入口管理
│   │       └── EntryManagementView.vue
│   ├── stores/           # Pinia 状态管理
│   │   ├── auth.ts       # 用户认证状态
│   │   └── portal.ts     # 门户数据状态
│   ├── router/           # 路由配置
│   │   └── index.ts
│   ├── utils/            # 工具函数
│   │   ├── request.ts    # 请求工具
│   │   ├── storage.ts    # 本地存储
│   │   └── validate.ts   # 表单验证
│   ├── types/            # TypeScript 类型定义
│   │   ├── api.ts        # API 类型
│   │   └── user.ts       # 用户类型
│   ├── App.vue           # 根组件
│   └── main.ts           # 入口文件
├── .eslintrc.cjs         # ESLint 配置
├── .prettierrc           # Prettier 配置
├── index.html            # HTML 模板
├── package.json          # 依赖配置
├── tsconfig.json         # TypeScript 配置
├── vite.config.ts        # Vite 配置
└── README.md             # 项目说明（本文件）
```

## 开发规范

### 代码风格

- 使用 TypeScript 严格模式
- 遵循 ESLint 和 Prettier 规则
- 组件使用 Composition API（`<script setup>`）
- 使用 Pinia 进行状态管理
- 遵循 Vue 3 官方风格指南

### 命名规范

- **组件名**：PascalCase（如 `UserProfile.vue`）
- **文件名**：kebab-case（如 `user-profile.vue`）
- **变量/函数**：camelCase（如 `getUserInfo`）
- **常量**：UPPER_SNAKE_CASE（如 `API_BASE_URL`）
- **类型/接口**：PascalCase（如 `UserInfo`）

### 组件开发

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'
import type { UserInfo } from '@/types/user'

// Props 定义
interface Props {
  userId: number
}
const props = defineProps<Props>()

// Emits 定义
const emit = defineEmits<{
  update: [value: string]
}>()

// 响应式数据
const loading = ref(false)

// 计算属性
const displayName = computed(() => {
  return `用户 ${props.userId}`
})

// 方法
const handleClick = () => {
  emit('update', 'new value')
}
</script>

<template>
  <div class="user-profile">
    <p>{{ displayName }}</p>
    <el-button @click="handleClick">更新</el-button>
  </div>
</template>

<style scoped>
.user-profile {
  padding: 16px;
}
</style>
```

### API 调用规范

```typescript
// api/auth.ts
import request from '@/api'
import type { LoginRequest, LoginResponse } from '@/types/api'

export const login = (data: LoginRequest): Promise<LoginResponse> => {
  return request.post('/api/v1/auth/sso/login', data)
}

// 在组件中使用
import { login } from '@/api/auth'

const handleLogin = async () => {
  try {
    const response = await login({ username: 'admin', password: '123456' })
    // 处理响应
  } catch (error) {
    // 处理错误
  }
}
```

### 状态管理规范

```typescript
// stores/auth.ts
import { defineStore } from 'pinia'
import type { UserInfo } from '@/types/user'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as UserInfo | null,
    token: '',
  }),
  
  getters: {
    isAuthenticated: (state) => !!state.token,
  },
  
  actions: {
    setUser(user: UserInfo) {
      this.user = user
    },
    setToken(token: string) {
      this.token = token
    },
    logout() {
      this.user = null
      this.token = ''
    },
  },
})
```

## 路由配置

```typescript
// router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login/LoginView.vue'),
    meta: { requiresAuth: false },
  },
  {
    path: '/',
    component: () => import('@/components/Layout/MainLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'Portal',
        component: () => import('@/views/Portal/PortalView.vue'),
      },
      {
        path: 'entries',
        name: 'EntryManagement',
        component: () => import('@/views/EntryManagement/EntryManagementView.vue'),
      },
    ],
  },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
  } else {
    next()
  }
})

export default router
```

## 环境配置

### 开发环境

```bash
# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 构建生产版本
npm run build

# 预览生产构建
npm run preview

# 代码检查
npm run lint

# 类型检查
npm run type-check
```

### 环境变量

创建 `.env.development` 和 `.env.production` 文件：

```env
# .env.development
VITE_API_BASE_URL=http://localhost:8080
VITE_APP_TITLE=星元空间统一数字门户

# .env.production
VITE_API_BASE_URL=https://api.example.com
VITE_APP_TITLE=星元空间统一数字门户
```

## 页面说明

### 登录页（LoginView）

- 基于 `design/ue/原型文件/login-prototype.html` 实现
- 支持 SSO 单点登录
- 表单验证和错误提示
- 响应式设计，支持移动端

### 工作台（PortalView）

- 基于 `design/ue/原型文件/portal-prototype.html` 实现
- 统计卡片展示（待办任务、今日访问、待审批、消息通知）
- 考勤打卡快速入口
- 系统入口卡片（支持拖拽排序）
- 待办任务列表
- 最近活动记录

### 入口管理（EntryManagementView）

- 基于 `design/ue/原型文件/entry-management-prototype.html` 实现
- 入口列表展示（网格/列表视图切换）
- 搜索和分类筛选
- 添加/编辑/删除入口
- 统计信息展示

## 响应式设计

- **移动端**：< 768px，单列布局，触摸友好
- **平板**：768px - 1024px，两列布局
- **桌面端**：> 1024px，多列布局

所有页面均支持响应式设计，自动适配不同屏幕尺寸。

## 新功能说明

### 拖拽排序功能
- 在工作台页面，应用入口卡片支持拖拽排序
- 拖拽后自动保存排序到后端
- 刷新页面后排序保持
- 移动端支持触摸拖拽

### 响应式设计优化
- 移动端（< 768px）：侧边栏自动隐藏，通过菜单按钮展开
- 平板端（768px - 1024px）：两列布局
- 桌面端（> 1024px）：多列布局
- 所有交互元素针对触摸设备优化

### 错误处理优化
- 完善的网络错误提示
- 统一的错误消息格式
- 加载状态视觉反馈
- 操作成功确认提示

## 参考文档

- [Vue 3 官方文档](https://cn.vuejs.org/)
- [Element Plus 文档](https://element-plus.org/zh-CN/)
- [Pinia 文档](https://pinia.vuejs.org/zh/)
- [Vue Router 文档](https://router.vuejs.org/zh/)
- [SortableJS 文档](https://sortablejs.github.io/Sortable/)
- [原型文件](../design/ue/原型文件/)
- [API 接口文档](../../docs/api/API接口文档.md)

## 开发注意事项

1. 所有 API 调用必须使用封装的 `request` 方法
2. 用户认证状态存储在 Pinia store 中
3. 路由守卫会自动检查登录状态
4. 组件样式使用 scoped，避免样式污染
5. 使用 TypeScript 类型定义，提升代码质量
6. 遵循 Element Plus 组件使用规范

