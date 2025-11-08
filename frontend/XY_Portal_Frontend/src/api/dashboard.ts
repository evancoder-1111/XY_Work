import request from '@/utils/request'

export interface DashboardStats {
  totalEntries: number
  todayVisits: number
  pendingTasks: number
  activeUsers: number
  recentActivities: RecentActivity[]
  tasks: Task[]
}

export interface RecentActivity {
  type: string
  description: string
  time: string
}

export interface Task {
  id: number
  title: string
  status: string
  priority: string
  dueDate: string
}

export const getDashboardStats = () => {
  return request.get<DashboardStats>('/api/v1/dashboard/stats')
}

