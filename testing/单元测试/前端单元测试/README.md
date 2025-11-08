# 前端单元测试

使用 Vitest 和 Vue Test Utils 进行前端单元测试。

## 测试框架

- **测试运行器**：Vitest
- **Vue测试工具**：@vue/test-utils
- **断言库**：Vitest内置（基于Chai）

## 测试范围

- 组件单元测试
- 工具函数测试
- API服务测试
- 状态管理测试（Pinia stores）

## 已创建的测试用例

- `src/stores/__tests__/auth.test.ts` - 认证状态管理测试
- `src/utils/__tests__/request.test.ts` - 请求工具测试

## 运行测试

```bash
cd frontend/XY_Portal_Frontend
npm install
npm run test          # 运行测试
npm run test:ui       # 运行测试（UI模式）
npm run test:coverage # 运行测试并生成覆盖率报告
```

## 测试配置

测试配置在 `vite.config.ts` 中，使用 jsdom 环境模拟浏览器环境。

