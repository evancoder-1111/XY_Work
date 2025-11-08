<template>
  <div class="entry-management-container">
    <!-- 工具栏 -->
    <el-card class="toolbar-card">
      <div class="toolbar">
        <el-input
          v-model="searchKeyword"
          placeholder="搜索入口名称或描述"
          style="width: 300px"
          clearable
          @input="handleSearch"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-select
          v-model="selectedCategory"
          placeholder="选择分类"
          style="width: 150px"
          clearable
          @change="handleSearch"
        >
          <el-option label="全部" value="" />
          <el-option label="业务系统" value="业务系统" />
          <el-option label="协作工具" value="协作工具" />
          <el-option label="管理系统" value="管理系统" />
        </el-select>
        <el-button type="primary" @click="handleAdd">
          <el-icon><Plus /></el-icon>
          添加入口
        </el-button>
      </div>
    </el-card>

    <!-- 入口列表 -->
    <el-card>
      <el-table :data="filteredEntries" style="width: 100%" v-loading="loading">
        <el-table-column prop="name" label="名称" width="200" />
        <el-table-column prop="description" label="描述" />
        <el-table-column prop="icon" label="图标" width="80">
          <template #default="{ row }">
            <span style="font-size: 24px">{{ row.icon || '📦' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="url" label="访问地址" />
        <el-table-column prop="category" label="分类" width="120" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'ACTIVE' ? 'success' : 'info'">
              {{ row.status === 'ACTIVE' ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">
              编辑
            </el-button>
            <el-button type="danger" link @click="handleDelete(row)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 添加/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogTitle"
      width="600px"
      @close="handleDialogClose"
    >
      <el-form :model="formData" :rules="formRules" ref="formRef" label-width="100px">
        <el-form-item label="系统名称" prop="name">
          <el-input v-model="formData.name" placeholder="请输入系统名称" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="formData.description"
            type="textarea"
            :rows="3"
            placeholder="请输入描述"
          />
        </el-form-item>
        <el-form-item label="图标" prop="icon">
          <el-input v-model="formData.icon" placeholder="请输入图标（emoji或URL）" />
        </el-form-item>
        <el-form-item label="访问地址" prop="url">
          <el-input v-model="formData.url" placeholder="请输入访问地址" />
        </el-form-item>
        <el-form-item label="分类" prop="category">
          <el-select v-model="formData.category" placeholder="请选择分类" style="width: 100%">
            <el-option label="业务系统" value="业务系统" />
            <el-option label="协作工具" value="协作工具" />
            <el-option label="管理系统" value="管理系统" />
          </el-select>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="formData.status">
            <el-radio label="ACTIVE">启用</el-radio>
            <el-radio label="INACTIVE">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="排序" prop="sortOrder">
          <el-input-number v-model="formData.sortOrder" :min="0" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitting">
          确定
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { getEntries, createEntry, updateEntry, deleteEntry, type PortalEntry } from '@/api/portal'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import { Search, Plus } from '@element-plus/icons-vue'

const entries = ref<PortalEntry[]>([])
const searchKeyword = ref('')
const selectedCategory = ref('')
const dialogVisible = ref(false)
const dialogTitle = ref('添加入口')
const submitting = ref(false)
const formRef = ref<FormInstance>()

const formData = reactive<PortalEntry>({
  name: '',
  description: '',
  icon: '',
  url: '',
  category: '',
  status: 'ACTIVE',
  sortOrder: 0
})

const formRules: FormRules = {
  name: [{ required: true, message: '请输入系统名称', trigger: 'blur' }],
  url: [{ required: true, message: '请输入访问地址', trigger: 'blur' }]
}

const filteredEntries = computed(() => {
  let result = entries.value

  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase()
    result = result.filter(
      (entry) =>
        entry.name.toLowerCase().includes(keyword) ||
        entry.description?.toLowerCase().includes(keyword)
    )
  }

  if (selectedCategory.value) {
    result = result.filter((entry) => entry.category === selectedCategory.value)
  }

  return result
})

const loading = ref(false)

const loadEntries = async () => {
  loading.value = true
  try {
    const response = await getEntries({ status: 'ACTIVE' })
    entries.value = response.data
  } catch (error) {
    // 错误已在 request.ts 中处理
    console.error('加载入口列表失败:', error)
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  // 搜索逻辑已在 computed 中实现
}

const handleAdd = () => {
  dialogTitle.value = '添加入口'
  resetForm()
  dialogVisible.value = true
}

const handleEdit = (row: PortalEntry) => {
  dialogTitle.value = '编辑入口'
  Object.assign(formData, { ...row })
  dialogVisible.value = true
}

const handleDelete = async (row: PortalEntry) => {
  try {
    await ElMessageBox.confirm('确定要删除该入口吗？', '提示', {
      type: 'warning'
    })
      await deleteEntry(row.id!)
      ElMessage.success('删除成功')
      await loadEntries()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

const handleSubmit = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (valid) {
      submitting.value = true
      try {
        if (formData.id) {
          await updateEntry(formData.id, formData)
          ElMessage.success('更新成功')
        } else {
          await createEntry(formData)
          ElMessage.success('添加成功')
        }
        dialogVisible.value = false
        await loadEntries()
      } catch (error) {
        ElMessage.error(formData.id ? '更新失败' : '添加失败')
      } finally {
        submitting.value = false
      }
    }
  })
}

const handleDialogClose = () => {
  resetForm()
}

const resetForm = () => {
  Object.assign(formData, {
    id: undefined,
    name: '',
    description: '',
    icon: '',
    url: '',
    category: '',
    status: 'ACTIVE',
    sortOrder: 0
  })
  formRef.value?.clearValidate()
}

onMounted(() => {
  loadEntries()
})
</script>

<style scoped>
.entry-management-container {
  padding: 0;
}

.toolbar-card {
  margin-bottom: 20px;
}

.toolbar {
  display: flex;
  gap: 12px;
  align-items: center;
}

@media (max-width: 768px) {
  .toolbar {
    flex-direction: column;
    align-items: stretch;
  }

  .toolbar > * {
    width: 100%;
  }
}
</style>
