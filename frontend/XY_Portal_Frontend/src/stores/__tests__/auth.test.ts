import { describe, it, expect, beforeEach, vi } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { useAuthStore } from '../auth'
import * as authApi from '@/api/auth'

vi.mock('@/api/auth')

describe('AuthStore', () => {
  beforeEach(() => {
    setActivePinia(createPinia())
    localStorage.clear()
  })

  it('应该初始化时从 localStorage 读取 token', () => {
    localStorage.setItem('token', 'test-token')
    const store = useAuthStore()
    expect(store.token).toBe('test-token')
  })

  it('应该能够获取用户信息', async () => {
    const mockUserInfo = {
      id: 1,
      username: 'admin',
      email: 'admin@xy.com',
      nickname: '管理员',
      avatar: '',
      role: 'ADMIN'
    }

    vi.mocked(authApi.getUserInfo).mockResolvedValue({
      data: mockUserInfo,
      code: 200,
      message: '成功'
    } as any)

    const store = useAuthStore()
    await store.fetchUserInfo()

    expect(store.userInfo).toEqual(mockUserInfo)
  })

  it('应该能够退出登录', async () => {
    vi.mocked(authApi.logout).mockResolvedValue({
      data: null,
      code: 200,
      message: '成功'
    } as any)

    const store = useAuthStore()
    store.token = 'test-token'
    store.userInfo = {
      id: 1,
      username: 'admin',
      email: 'admin@xy.com',
      nickname: '管理员',
      avatar: '',
      role: 'ADMIN'
    }

    await store.logout()

    expect(store.token).toBeNull()
    expect(store.userInfo).toBeNull()
    expect(localStorage.getItem('token')).toBeNull()
  })
})

