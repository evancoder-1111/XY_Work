<template>
  <div class="layout-container">
    <el-container>
      <el-header class="header">
        <div class="header-left">
          <button class="menu-toggle" @click="toggleSidebar" v-if="isMobile">
            <el-icon><Menu /></el-icon>
          </button>
          <h1 class="logo">星元空间</h1>
        </div>
        <div class="header-right">
          <el-dropdown @command="handleCommand">
            <span class="user-info">
              <el-avatar :size="32" :src="userInfo?.avatar">
                <el-icon><User /></el-icon>
              </el-avatar>
              <span class="username">{{ userInfo?.nickname || userInfo?.username }}</span>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="logout">退出登录</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>
      <el-container>
        <el-aside 
          class="sidebar" 
          :class="{ 'mobile-open': sidebarOpen }"
          :width="isCollapse ? '64px' : '200px'"
        >
          <div class="sidebar-overlay" v-if="isMobile && sidebarOpen" @click="closeSidebar"></div>
          <el-menu
            :default-active="activeMenu"
            :collapse="isCollapse"
            router
            class="sidebar-menu"
          >
            <el-menu-item index="/portal/workbench" @click="handleMenuClick">
              <el-icon><House /></el-icon>
              <span>工作台</span>
            </el-menu-item>
            <el-menu-item index="/entry-management" @click="handleMenuClick">
              <el-icon><Setting /></el-icon>
              <span>入口管理</span>
            </el-menu-item>
          </el-menu>
        </el-aside>
        <el-main class="main-content">
          <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { House, Setting, ArrowDown, Menu, User } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const isCollapse = ref(false)
const sidebarOpen = ref(false)
const isMobile = ref(false)
const activeMenu = computed(() => route.path)
const userInfo = computed(() => authStore.userInfo)

const checkMobile = () => {
  isMobile.value = window.innerWidth < 768
  if (!isMobile.value) {
    sidebarOpen.value = false
  }
}

const toggleSidebar = () => {
  sidebarOpen.value = !sidebarOpen.value
}

const closeSidebar = () => {
  sidebarOpen.value = false
}

const handleMenuClick = () => {
  if (isMobile.value) {
    closeSidebar()
  }
}

const handleCommand = async (command: string) => {
  if (command === 'logout') {
    await authStore.logout()
    router.push('/login')
  }
}

onMounted(() => {
  checkMobile()
  window.addEventListener('resize', checkMobile)
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
})
</script>

<style scoped>
.layout-container {
  width: 100%;
  height: 100vh;
}

.header {
  background: #fff;
  border-bottom: 1px solid #e4e7ed;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 24px;
}

.logo {
  font-size: 20px;
  font-weight: 600;
  color: #303133;
  margin: 0;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.username {
  font-size: 14px;
  color: #606266;
}

.sidebar {
  background: #fff;
  border-right: 1px solid #e4e7ed;
}

.sidebar-menu {
  border-right: none;
  height: 100%;
}

.main-content {
  background: #f5f7fa;
  padding: 24px;
}

.menu-toggle {
  display: none;
  width: 40px;
  height: 40px;
  border: none;
  background: transparent;
  cursor: pointer;
  color: #606266;
  font-size: 20px;
  margin-right: 12px;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
}

.menu-toggle:hover {
  background: #f5f7fa;
}

.sidebar-overlay {
  display: none;
  position: fixed;
  top: 60px;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 999;
}

@media (max-width: 768px) {
  .header {
    padding: 0 12px;
  }

  .menu-toggle {
    display: flex;
  }

  .logo {
    font-size: 18px;
  }

  .username {
    display: none;
  }

  .sidebar {
    position: fixed;
    left: 0;
    top: 60px;
    height: calc(100vh - 60px);
    z-index: 1000;
    transform: translateX(-100%);
    transition: transform 0.3s;
    box-shadow: 2px 0 8px rgba(0, 0, 0, 0.1);
  }

  .sidebar.mobile-open {
    transform: translateX(0);
  }

  .sidebar-overlay {
    display: block;
  }

  .main-content {
    padding: 12px;
  }
}
</style>

