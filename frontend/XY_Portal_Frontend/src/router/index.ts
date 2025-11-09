import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    redirect: '/portal'
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/Login.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/portal',
    name: 'Portal',
    component: () => import('@/components/Layout.vue'),
    redirect: '/portal/workbench',
    meta: { requiresAuth: true },
    children: [
      {
        path: 'workbench',
        name: 'Workbench',
        component: () => import('@/views/Portal.vue')
      }
    ]
  },
  {
    path: '/entry-management',
    name: 'EntryManagement',
    component: () => import('@/components/Layout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'EntryManagementPage',
        component: () => import('@/views/EntryManagement.vue')
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach(async (to, _from, next) => {
  const token = localStorage.getItem('token')
  const authStore = useAuthStore()
  
  if (to.meta.requiresAuth && !token) {
    next('/login')
  } else if (to.path === '/login' && token) {
    next('/portal')
  } else if (token && !authStore.userInfo) {
    try {
      await authStore.fetchUserInfo()
      next()
    } catch (error) {
      localStorage.removeItem('token')
      next('/login')
    }
  } else {
    next()
  }
})

export default router

