import { defineStore } from 'pinia'
import { ref } from 'vue'
import { getUserInfo, logout as apiLogout } from '@/api/auth'

export interface UserInfo {
  id: number
  username: string
  email: string
  nickname: string
  avatar: string
  role: string
}

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(localStorage.getItem('token'))
  const userInfo = ref<UserInfo | null>(null)

  const fetchUserInfo = async () => {
    try {
      const response = await getUserInfo()
      userInfo.value = response.data
      return response
    } catch (error) {
      throw error
    }
  }

  const logout = async () => {
    try {
      await apiLogout()
      token.value = null
      userInfo.value = null
      localStorage.removeItem('token')
    } catch (error) {
      throw error
    }
  }

  return {
    token,
    userInfo,
    fetchUserInfo,
    logout
  }
})

