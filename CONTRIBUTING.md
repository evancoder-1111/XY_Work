# 贡献指南（Contributing）

本仓库采用中文为主、英文术语对照的协作方式。请遵循以下规则以便团队高效协作。

## 1. 分支模型（Branching）
- main：稳定分支（受保护）
- develop：日常开发分支
- feature/*：功能分支（例：feature/sso-login）
- fix/*：缺陷修复（例：fix/portal-entry-crash）
- release/*：预发布分支

## 2. 提交规范（Commit Message）
- 格式：`type(scope): summary`，如：`feat(auth): add sso login endpoint`
- 常用 type：feat / fix / docs / style / refactor / perf / test / build / ci / chore / revert
- Body（可选）：使用中文描述背景、动机、影响范围

## 3. Pull Request（PR）
- 尺寸建议：< 400 行变更
- 必须通过 CI；至少 1 名 Reviewer 通过
- 描述应包含：需求链接、变更说明、影响范围、风险与回滚

## 4. 代码评审（Code Review）
- 原则：问题导向、可读性优先、可维护性优先
- Reviewer 关注：命名、边界条件、错误处理、安全、性能

## 5. Issue 与任务跟踪
- 模板包含：背景、复现步骤/期望、截图/日志、验收标准
- 以里程碑与标签组织（如：P0/P1、frontend/backend）

## 6. 开发环境（Environment）
- Node.js >= 18、Java >= 17、MySQL >= 8
- `.env` 管理环境变量；禁止将密钥提交到仓库

## 7. 合规与安全（Compliance & Security）
- 依照《安全与合规规范》进行鉴权、审计、隐私和数据保护

如需新增规范，请在 PR 中更新相应文档并通知团队。

