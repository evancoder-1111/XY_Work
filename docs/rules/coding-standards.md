# 编码规范（Coding Standards）

## 0. 总体原则（General Principles）

### 0.1 可维护性优先
- **代码自解释**：通过清晰的命名和结构使代码易于理解
- **单一职责**：每个类/函数只负责一个功能
- **低耦合高内聚**：模块间依赖最小化，内部逻辑紧密相关
- **可测试性**：设计易于测试的代码结构

### 0.2 一致性
- 遵循项目已有的代码风格和命名约定
- 团队成员间保持一致的编码习惯
- 使用工具确保格式统一（如ESLint、Prettier）

### 0.3 渐进增强
- 基础功能稳定可靠
- 逐步添加高级特性
- 向后兼容优先

## 1. 命名约定（Naming Conventions）
- 目录/文件：小写中划线（kebab-case），如 `user-management`
- 变量/函数：驼峰命名（camelCase），如 `getUserData()`
- 类/接口：帕斯卡命名（PascalCase），如 `UserService`
- 常量：全大写下划线分隔，如 `MAX_RETRY_COUNT`
- 私有成员：下划线前缀，如 `_privateMethod()`
- 枚举值：帕斯卡命名，如 `StatusEnum.Active`

## 2. 目录与模块（Directory & Module）
- 按功能模块组织代码，避免按文件类型组织
- 目录结构清晰，层级不宜过深（建议 ≤ 4层）
- 模块间依赖单向流动，避免循环依赖
- 公共组件/工具单独提取，便于复用

## 3. 代码风格（Code Style）
- **缩进**：2个空格，不使用Tab
- **行长度**：单行不超过100个字符
- **括号**：使用花括号，即使单行语句也不省略
- **分号**：语句结束必须加分号
- **空行**：函数间使用1个空行，代码块间使用空行分隔
- **空格**：运算符前后、逗号后加空格，括号内侧不加空格

## 4. 注释与文档（Comments & Documentation）
- **类/函数注释**：使用JSDoc/JavaDoc格式，描述功能、参数、返回值
- **复杂逻辑**：关键算法或复杂业务逻辑必须添加注释
- **TODO注释**：使用TODO标记待完成工作，附带负责人
- **废弃功能**：使用@deprecated标记，并说明替代方案
- **注释语言**：使用中文进行注释

## 5. API调用（API Calls）
- **错误处理**：所有API调用必须处理错误情况
- **超时设置**：设置合理的请求超时时间
- **重试机制**：对不稳定的API添加重试逻辑
- **缓存策略**：合理使用缓存减少重复请求
- **参数校验**：调用前验证参数有效性

## 6. 异常处理（Exception Handling）
- **精确捕获**：捕获具体的异常类型，避免捕获所有异常
- **日志记录**：异常必须记录日志，包含上下文信息
- **用户反馈**：对用户可见的错误提供友好提示
- **恢复机制**：设计合理的异常恢复策略
- **不吞异常**：避免捕获异常后不处理或不向上抛出

## 7. 安全（Security）
- **输入验证**：所有用户输入必须验证和过滤
- **SQL注入**：使用参数化查询，避免字符串拼接SQL
- **XSS防护**：对输出到页面的内容进行转义
- **CSRF防护**：实现CSRF Token机制
- **敏感信息**：不在日志中记录敏感信息（密码、token等）

## 8. 性能（Performance）
- **惰性加载**：对大型组件或资源使用惰性加载
- **避免阻塞**：耗时操作使用异步处理
- **内存管理**：避免内存泄漏，及时清理不再使用的资源
- **缓存使用**：合理使用缓存提升性能
- **算法效率**：选择合适的数据结构和算法

## 9. 测试（Testing）
- **单元测试**：核心功能必须有单元测试覆盖
- **测试覆盖率**：代码覆盖率目标≥70%
- **测试命名**：测试用例命名清晰，反映测试场景
- **测试数据**：使用模拟数据，避免依赖真实环境
- **CI集成**：测试必须集成到CI流程

## 10. Git提交与PR（Git Commits & PR）
- **提交信息**：遵循`类型: 描述`格式，如 `feat: 添加用户管理功能`
- **提交粒度**：一个提交一个功能或一个修复
- **PR描述**：详细描述变更内容、测试情况、影响范围
- **代码审查**：PR必须经过至少一名同事审查
- **分支管理**：定期清理过期分支

## 11. 代码重构（Code Refactoring）

### 11.1 重构原则
- **小步重构**：每次只改变一小部分代码
- **保持功能不变**：重构不改变原有功能行为
- **测试先行**：确保有足够的测试用例支持重构
- **持续集成**：每次重构后运行测试确保安全

### 11.2 重构模式
- **提取重复代码**：将重复的代码块提取为函数
- **简化条件表达式**：使用卫语句、策略模式等简化复杂条件
- **拆分大型类/函数**：将大的类或函数拆分为更小的单元
- **替换继承为组合**：遵循组合优于继承原则
- **引入设计模式**：合理使用设计模式提高代码质量

### 11.3 代码异味识别
- 过长的函数或方法
- 过大的类
- 重复代码
- 复杂的条件判断
- 紧耦合的模块
- 不恰当的命名

## 12. 代码审查（Code Review）

### 12.1 审查重点
- 代码质量：可读性、可维护性、可测试性
- 功能实现：是否符合需求，逻辑是否正确
- 性能问题：是否存在性能瓶颈
- 安全隐患：是否存在安全漏洞
- 规范遵循：是否符合编码规范

### 12.2 反馈方式
- 具体明确：指出具体问题和位置
- 建设性：提供改进建议而非仅指出问题
- 优先级：区分必须修改和建议修改的内容
- 尊重他人：保持专业和友善的语气

### 12.3 审查流程
- 自检：提交前自己先审查一遍
- 提交：PR描述清晰，关联相关任务
- 审查：至少一名同事进行审查
- 修改：根据反馈修改代码
- 再次审查：修改后再次确认
- 合并：通过审查后合并代码

## 13. 依赖管理（Dependency Management）

### 13.1 依赖原则
- **最小化依赖**：只引入必要的依赖
- **版本锁定**：明确指定依赖版本，避免使用范围版本
- **定期更新**：定期审查和更新依赖，修复安全漏洞
- **替代内置**：优先使用语言/框架内置功能，避免过度依赖第三方库

### 13.2 依赖引入流程
- 需求评估：确认是否真的需要引入新依赖
- 技术评估：评估依赖的质量、维护状态、安全风险
- 团队评审：重要依赖需团队评审通过
- 文档记录：记录依赖的用途和版本信息

### 13.3 依赖安全
- 使用依赖扫描工具定期检查安全漏洞
- 及时更新存在安全风险的依赖
- 避免使用已废弃或不再维护的依赖

## 14. 代码示例（Code Examples）

### 14.1 前端代码示例（Vue 3 + TypeScript）

```vue
<template>
  <div class="user-profile">
    <h2>{{ user.name }}</h2>
    <p v-if="isLoading">加载中...</p>
    <div v-else-if="error" class="error-message">
      {{ error }}
      <button @click="fetchUserProfile">重试</button>
    </div>
    <div v-else class="user-details">
      <p>邮箱: {{ user.email }}</p>
      <p>角色: {{ user.role }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { getUserInfo } from '@/api/user'

// 定义用户类型
interface User {
  id: string
  name: string
  email: string
  role: string
}

// 状态管理
const user = ref<User>({ id: '', name: '', email: '', role: '' })
const isLoading = ref(false)
const error = ref('')

// 获取用户信息
const fetchUserProfile = async () => {
  isLoading.value = true
  error.value = ''
  
  try {
    const userId = 'current-user-id' // 实际项目中应从认证系统获取
    const response = await getUserInfo(userId)
    user.value = response.data
  } catch (err) {
    console.error('获取用户信息失败:', err)
    error.value = '获取用户信息失败，请稍后重试'
  } finally {
    isLoading.value = false
  }
}

// 组件挂载时获取数据
onMounted(() => {
  fetchUserProfile()
})
</script>

<style scoped>
.user-profile {
  padding: 16px;
  border-radius: 8px;
  background-color: #f5f5f5;
}

.error-message {
  color: #e74c3c;
  padding: 8px;
  border-radius: 4px;
  background-color: #ffeaea;
}

.user-details {
  margin-top: 16px;
}
</style>
```

### 14.2 后端代码示例（Spring Boot）

```java
package com.example.service;

import com.example.dto.UserDTO;
import com.example.entity.User;
import com.example.exception.BusinessException;
import com.example.mapper.UserMapper;
import com.example.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

/**
 * 用户服务类 - 处理用户相关业务逻辑
 */
@Service
@RequiredArgsConstructor
public class UserService {
    
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    
    /**
     * 根据ID获取用户信息
     * 
     * @param userId 用户ID
     * @return 用户信息DTO
     * @throws BusinessException 当用户不存在时抛出
     */
    @Cacheable(value = "users", key = "#userId")
    public UserDTO getUserById(String userId) {
        if (userId == null || userId.trim().isEmpty()) {
            throw new BusinessException("用户ID不能为空");
        }
        
        return userRepository.findById(userId)
                .map(userMapper::toDTO)
                .orElseThrow(() -> new BusinessException("用户不存在: " + userId));
    }
    
    /**
     * 创建新用户
     * 
     * @param userDTO 用户信息DTO
     * @return 创建的用户信息DTO
     */
    @Transactional
    public UserDTO createUser(UserDTO userDTO) {
        // 验证用户邮箱是否已存在
        if (userRepository.existsByEmail(userDTO.getEmail())) {
            throw new BusinessException("邮箱已被注册: " + userDTO.getEmail());
        }
        
        // 转换DTO为实体
        User user = userMapper.toEntity(userDTO);
        
        // 保存用户信息
        User savedUser = userRepository.save(user);
        
        // 返回转换后的DTO
        return userMapper.toDTO(savedUser);
    }
    
    /**
     * 更新用户信息
     * 
     * @param userId 用户ID
     * @param userDTO 用户信息DTO
     * @return 更新后的用户信息DTO
     * @throws BusinessException 当用户不存在时抛出
     */
    @Transactional
    public UserDTO updateUser(String userId, UserDTO userDTO) {
        // 查找用户
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("用户不存在: " + userId));
        
        // 如果更新邮箱，检查是否已被其他用户使用
        if (!user.getEmail().equals(userDTO.getEmail()) && 
            userRepository.existsByEmail(userDTO.getEmail())) {
            throw new BusinessException("邮箱已被注册: " + userDTO.getEmail());
        }
        
        // 更新用户信息
        userMapper.updateEntity(userDTO, user);
        
        // 保存更新后的用户信息
        User updatedUser = userRepository.save(user);
        
        // 返回转换后的DTO
        return userMapper.toDTO(updatedUser);
    }
}


