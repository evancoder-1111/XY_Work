<template>
  <div class="portal-container">
    <!-- 统计卡片 -->
    <el-row
      :gutter="20"
      class="stats-row"
    >
      <el-col
        v-for="stat in stats"
        :key="stat.label"
        :xs="12"
        :sm="6"
      >
        <el-card class="stat-card">
          <div class="stat-content">
            <div
              class="stat-icon"
              :style="{ background: stat.color }"
            >
              <el-icon :size="24">
                <component :is="stat.icon" />
              </el-icon>
            </div>
            <div class="stat-info">
              <div class="stat-value">
                {{ stat.value }}
              </div>
              <div class="stat-label">
                {{ stat.label }}
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 应用入口网格 -->
    <el-card
      v-loading="loading"
      class="entries-card"
      header="应用入口"
    >
      <div
        ref="entriesGridRef"
        class="entries-grid"
      >
        <div
          v-for="entry in entries"
          :key="entry.id"
          class="entry-item"
          @click="handleEntryClick(entry)"
        >
          <div class="entry-icon">
            {{ entry.icon || '📦' }}
          </div>
          <div class="entry-name">
            {{ entry.name }}
          </div>
        </div>
      </div>
    </el-card>

    <!-- 待办任务和活动记录 -->
    <el-row
      :gutter="20"
      class="bottom-row"
    >
      <el-col
        :xs="24"
        :sm="12"
      >
        <el-card header="待办任务">
          <el-empty
            v-if="tasks.length === 0"
            description="暂无待办任务"
          />
          <div
            v-else
            class="task-list"
          >
            <div
              v-for="task in tasks"
              :key="task.id"
              class="task-item"
            >
              <el-tag
                :type="getTaskTagType(task.status)"
                size="small"
              >
                {{ task.status }}
              </el-tag>
              <span class="task-title">{{ task.title }}</span>
              <span class="task-date">{{ task.dueDate }}</span>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col
        :xs="24"
        :sm="12"
      >
        <el-card header="最近活动">
          <el-empty
            v-if="activities.length === 0"
            description="暂无活动记录"
          />
          <div
            v-else
            class="activity-list"
          >
            <div
              v-for="(activity, index) in activities"
              :key="index"
              class="activity-item"
            >
              <div class="activity-type">
                {{ activity.type }}
              </div>
              <div class="activity-desc">
                {{ activity.description }}
              </div>
              <div class="activity-time">
                {{ activity.time }}
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, nextTick } from 'vue'
import { getDashboardStats } from '@/api/dashboard'
import { getEntries, updateSortOrder } from '@/api/portal'
import type { Task, RecentActivity } from '@/api/dashboard'
import type { PortalEntry } from '@/api/portal'
import { Document, User, Clock, List } from '@element-plus/icons-vue'
import { ElMessage } from 'element-plus'
import Sortable, { type SortableEvent } from 'sortablejs'

const stats = ref([
  { label: '总入口数', value: 0, icon: Document, color: '#409EFF' },
  { label: '今日访问', value: 0, icon: Clock, color: '#67C23A' },
  { label: '待办任务', value: 0, icon: List, color: '#E6A23C' },
  { label: '活跃用户', value: 0, icon: User, color: '#F56C6C' }
])

const entries = ref<PortalEntry[]>([])
const tasks = ref<Task[]>([])
const activities = ref<RecentActivity[]>([])
const entriesGridRef = ref<HTMLElement>()
const loading = ref(false)
let sortableInstance: Sortable | null = null

const loadDashboardData = async () => {
  loading.value = true
  try {
    const [statsRes, entriesRes] = await Promise.all([
      getDashboardStats(),
      getEntries({ status: 'ACTIVE' })
    ])

    const dashboardData = statsRes.data
    stats.value[0].value = dashboardData.totalEntries
    stats.value[1].value = dashboardData.todayVisits
    stats.value[2].value = dashboardData.pendingTasks
    stats.value[3].value = dashboardData.activeUsers

    entries.value = entriesRes.data
    tasks.value = dashboardData.tasks
    activities.value = dashboardData.recentActivities
  } catch (error) {
    // 错误已在 request.ts 中处理
    console.error('加载数据失败:', error)
  } finally {
    loading.value = false
  }
}

const handleEntryClick = (entry: PortalEntry) => {
  if (entry.url) {
    window.open(entry.url, '_blank')
  }
}

const getTaskTagType = (status: string) => {
  const statusMap: Record<string, any> = {
    '进行中': 'warning',
    '已完成': 'success',
    '待处理': 'info'
  }
  return statusMap[status] || 'info'
}

const initSortable = () => {
  nextTick(() => {
    if (!entriesGridRef.value || sortableInstance) return

    sortableInstance = Sortable.create(entriesGridRef.value, {
      animation: 150,
      handle: '.entry-item',
      onEnd: async (evt: SortableEvent) => {
        const { oldIndex, newIndex } = evt
        if (oldIndex === null || oldIndex === undefined || newIndex === null || newIndex === undefined || oldIndex === newIndex) return

        // 更新本地数组顺序
        const movedItem = entries.value.splice(oldIndex, 1)[0]
        entries.value.splice(newIndex, 0, movedItem)

        // 保存排序到后端
        try {
          const entryIds = entries.value.map(entry => entry.id).filter((id): id is number => id !== undefined)
          await updateSortOrder(entryIds)
          ElMessage.success('排序已保存')
        } catch (error) {
          // 恢复原顺序
          entries.value.splice(newIndex, 1)
          entries.value.splice(oldIndex, 0, movedItem)
          ElMessage.error('保存排序失败')
        }
      }
    })
  })
}

onMounted(() => {
  loadDashboardData().then(() => {
    initSortable()
  })
})

onBeforeUnmount(() => {
  if (sortableInstance) {
    sortableInstance.destroy()
    sortableInstance = null
  }
})
</script>

<style scoped>
.portal-container {
  padding: 0;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-card {
  height: 100%;
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 48px;
  height: 48px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 24px;
  font-weight: 600;
  color: #303133;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #909399;
}

.entries-card {
  margin-bottom: 20px;
}

.entries-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 16px;
}

.entry-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 16px;
  border: 1px solid #e4e7ed;
  border-radius: 8px;
  cursor: move;
  transition: all 0.3s;
  user-select: none;
}

.entry-item:hover {
  border-color: #409EFF;
  box-shadow: 0 2px 12px rgba(64, 158, 255, 0.2);
  transform: translateY(-2px);
}

.entry-item.sortable-ghost {
  opacity: 0.4;
  background: #f0f0f0;
}

.entry-item.sortable-drag {
  cursor: grabbing;
}

.entry-icon {
  font-size: 32px;
  margin-bottom: 8px;
}

.entry-name {
  font-size: 14px;
  color: #606266;
  text-align: center;
}

.bottom-row {
  margin-top: 20px;
}

.task-list,
.activity-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.task-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #f5f7fa;
  border-radius: 4px;
}

.task-title {
  flex: 1;
  font-size: 14px;
  color: #606266;
}

.task-date {
  font-size: 12px;
  color: #909399;
}

.activity-item {
  padding: 12px;
  background: #f5f7fa;
  border-radius: 4px;
  border-left: 3px solid #409EFF;
}

.activity-type {
  font-size: 12px;
  color: #909399;
  margin-bottom: 4px;
}

.activity-desc {
  font-size: 14px;
  color: #606266;
  margin-bottom: 4px;
}

.activity-time {
  font-size: 12px;
  color: #909399;
}

@media (max-width: 768px) {
  .entries-grid {
    grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
    gap: 12px;
  }

  .entry-item {
    padding: 12px;
  }

  .entry-icon {
    font-size: 24px;
  }
}
</style>
