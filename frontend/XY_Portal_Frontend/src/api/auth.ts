import request from '@/utils/request'

export interface LoginRequest {
  username: string
  password: string
}

export interface SSOLoginResponse {
  token: string
  user: {
    id: number
    username: string
    email: string
    nickname: string
    avatar: string
    role: string
  }
}

export interface UserInfo {
  id: number
  username: string
  email: string
  nickname: string
  avatar: string
  role: string
}

export const ssoLogin = (data: LoginRequest) => {
  return request.post<SSOLoginResponse>('/api/v1/auth/sso/login', data)
}

export const getUserInfo = () => {
  return request.get<UserInfo>('/api/v1/auth/user/info')
}

export const logout = () => {
  return request.post('/api/v1/auth/logout')
}

