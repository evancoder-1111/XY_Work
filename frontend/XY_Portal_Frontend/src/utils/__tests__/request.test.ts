import { describe, it, expect, beforeEach, vi } from 'vitest'
import axios from 'axios'
import request from '../request'

vi.mock('axios')
vi.mock('element-plus', () => ({
  ElMessage: {
    error: vi.fn()
  }
}))

describe('Request Utils', () => {
  beforeEach(() => {
    localStorage.clear()
  })

  it('应该在请求头中添加 token', async () => {
    localStorage.setItem('token', 'test-token')
    const mockAxios = vi.mocked(axios.create)
    const mockInstance = {
      interceptors: {
        request: { use: vi.fn() },
        response: { use: vi.fn() }
      }
    }
    mockAxios.mockReturnValue(mockInstance as any)

    request.get('/test')

    expect(mockInstance.interceptors.request.use).toHaveBeenCalled()
  })
})

