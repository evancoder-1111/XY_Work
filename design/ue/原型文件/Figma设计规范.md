# XY Work - Figma 原型设计规范

本文档提供在 Figma 中创建 XY Work 原型的详细设计规范。

## 1. 颜色系统（Color Styles）

### 1.1 主色（Primary Colors）

在 Figma 中创建以下颜色样式：

| 颜色名称 | Hex | RGB | 用途 |
|---------|-----|-----|------|
| Primary | #409EFF | rgb(64, 158, 255) | 主要按钮、链接、高亮 |
| Primary-Hover | #66b1ff | rgb(102, 177, 255) | 按钮悬停状态 |
| Primary-Active | #3a8ee6 | rgb(58, 142, 230) | 按钮点击状态 |

**Figma 操作**：
1. 创建 Color Style：`Primary/Default`
2. 创建 Color Style：`Primary/Hover`
3. 创建 Color Style：`Primary/Active`

### 1.2 功能色（Functional Colors）

| 颜色名称 | Hex | RGB | 用途 |
|---------|-----|-----|------|
| Success | #67C23A | rgb(103, 194, 58) | 成功状态 |
| Warning | #E6A23C | rgb(230, 162, 60) | 警告状态 |
| Danger | #F56C6C | rgb(245, 108, 108) | 错误状态 |
| Info | #909399 | rgb(144, 147, 153) | 信息提示 |

### 1.3 中性色（Neutral Colors）

| 颜色名称 | Hex | RGB | 用途 |
|---------|-----|-----|------|
| Text-Primary | #303133 | rgb(48, 49, 51) | 主要文字 |
| Text-Regular | #606266 | rgb(96, 98, 102) | 常规文字 |
| Text-Secondary | #909399 | rgb(144, 147, 153) | 次要文字 |
| Text-Placeholder | #C0C4CC | rgb(192, 196, 204) | 占位文字 |
| Border-Base | #DCDFE6 | rgb(220, 223, 230) | 基础边框 |
| Border-Light | #E4E7ED | rgb(228, 231, 237) | 浅色边框 |
| Border-Lighter | #EBEEF5 | rgb(235, 238, 245) | 更浅边框 |
| Background | #F5F7FA | rgb(245, 247, 250) | 页面背景 |
| Background-White | #FFFFFF | rgb(255, 255, 255) | 白色背景 |

### 1.4 渐变（Gradients）

**登录页背景渐变**：
- 类型：Linear Gradient
- 角度：135deg
- 颜色1：`#667eea` (0%)
- 颜色2：`#764ba2` (100%)

## 2. 字体系统（Text Styles）

### 2.1 字体家族

- **中文**：PingFang SC, Microsoft YaHei, sans-serif
- **英文**：Helvetica Neue, Arial, sans-serif

### 2.2 字号体系

在 Figma 中创建以下文本样式：

| 样式名称 | 字号 | 字重 | 行高 | 用途 |
|---------|------|------|------|------|
| Heading-1 | 24px | 600 (SemiBold) | 32px | 页面主标题 |
| Heading-2 | 20px | 600 | 28px | 区块标题 |
| Heading-3 | 18px | 600 | 26px | 卡片标题 |
| Body-Large | 16px | 400 (Regular) | 24px | 正文大号 |
| Body-Regular | 14px | 400 | 20px | 正文常规 |
| Body-Small | 12px | 400 | 18px | 辅助文字 |
| Caption | 12px | 400 | 16px | 说明文字 |

**Figma 操作**：
1. 创建 Text Style：`Text/Heading-1`
2. 创建 Text Style：`Text/Body-Regular`
3. 以此类推...

## 3. 间距系统（Spacing）

### 3.1 基础间距单位

使用 **4px** 作为基础单位，创建以下间距：

| 名称 | 数值 | 用途 |
|------|------|------|
| XS | 4px | 最小间距 |
| SM | 8px | 小间距 |
| MD | 12px | 中等间距 |
| LG | 16px | 大间距 |
| XL | 20px | 超大间距 |
| XXL | 24px | 最大间距 |
| XXXL | 32px | 特大间距 |

### 3.2 常用间距组合

- **卡片内边距**：20px / 24px
- **表单元素间距**：20px
- **按钮高度**：40px (移动端 44px)
- **输入框高度**：40px (移动端 44px)
- **卡片间距**：16px / 24px

## 4. 圆角系统（Border Radius）

| 名称 | 数值 | 用途 |
|------|------|------|
| Small | 4px | 按钮、输入框 |
| Medium | 8px | 卡片、面板 |
| Large | 12px | 大卡片、模态框 |

## 5. 阴影系统（Effects）

### 5.1 卡片阴影

| 名称 | 参数 | 用途 |
|------|------|------|
| Shadow-Small | 0 2px 12px rgba(0,0,0,0.1) | 卡片基础阴影 |
| Shadow-Medium | 0 4px 16px rgba(0,0,0,0.15) | 卡片悬停阴影 |
| Shadow-Large | 0 10px 40px rgba(0,0,0,0.2) | 登录卡片阴影 |

**Figma 操作**：
1. 创建 Effect Style：`Shadow/Small`
2. 创建 Effect Style：`Shadow/Medium`
3. 创建 Effect Style：`Shadow/Large`

## 6. 组件规范

### 6.1 按钮（Button）

#### 主要按钮（Primary Button）
- **尺寸**：高度 40px，宽度自适应（最小 80px）
- **圆角**：4px
- **背景**：Primary (#409EFF)
- **文字**：白色，Body-Regular (14px)
- **状态**：
  - Default：Primary
  - Hover：Primary-Hover
  - Active：Primary-Active
  - Disabled：Background + Text-Placeholder

#### 次要按钮（Secondary Button）
- **尺寸**：高度 40px
- **圆角**：4px
- **背景**：Background-White
- **边框**：1px solid Border-Base
- **文字**：Text-Regular (#606266)
- **状态**：
  - Hover：背景 #ECF5FF，边框 Primary，文字 Primary

### 6.2 输入框（Input）

- **尺寸**：高度 40px（移动端 44px），宽度 100%
- **圆角**：4px
- **边框**：1px solid Border-Base
- **内边距**：0 12px
- **文字**：Body-Regular (14px)，移动端 16px（避免 iOS 自动缩放）
- **占位符**：Text-Placeholder
- **状态**：
  - Focus：边框 Primary (#409EFF)
  - Error：边框 Danger (#F56C6C)

### 6.3 卡片（Card）

- **背景**：Background-White
- **圆角**：4px（登录页 8px）
- **阴影**：Shadow-Small
- **内边距**：20px / 24px
- **悬停效果**：Shadow-Medium，向上移动 4px

### 6.4 系统入口卡片（Entry Card）

- **尺寸**：最小 180px × 120px
- **布局**：垂直居中，图标在上，文字在下
- **图标**：48px × 48px
- **标题**：Heading-3 (18px)
- **描述**：Body-Small (12px)
- **间距**：图标与标题 12px，标题与描述 6px

## 7. 页面布局规范

### 7.1 登录页（Login Page）

**画板尺寸**：
- Web：1440px × 900px
- Mobile：375px × 812px（iPhone X）

**布局结构**：
1. **背景层**：渐变背景（135deg, #667eea → #764ba2）
2. **登录容器**：
   - 宽度：400px（Web），100%（Mobile）
   - 背景：白色
   - 圆角：8px（Web），0（Mobile）
   - 内边距：40px（Web），30px 20px（Mobile）
   - 阴影：Shadow-Large
   - 居中显示

**元素布局**：
- Logo 区域：顶部居中，下边距 30px
- 表单区域：表单元素间距 20px
- 按钮区域：按钮间距 12px

### 7.2 工作台（Portal Page）

**画板尺寸**：
- Web：1440px × 900px
- Mobile：375px × 812px

**布局结构**：
1. **顶部导航栏**：
   - 高度：60px（Web），56px（Mobile）
   - 背景：白色
   - 阴影：0 2px 8px rgba(0,0,0,0.1)
   - 固定定位

2. **侧边栏**（仅 Web）：
   - 宽度：200px
   - 背景：白色
   - 阴影：2px 0 8px rgba(0,0,0,0.05)

3. **主内容区**：
   - 内边距：24px（Web），16px（Mobile）
   - 背景：Background (#F5F7FA)

**网格布局**：
- 系统入口网格：`repeat(auto-fill, minmax(180px, 1fr))`
- 网格间距：16px（Web），12px（Mobile）

### 7.3 入口管理页（Entry Management）

**画板尺寸**：
- Web：1440px × 900px

**布局结构**：
1. **页面头部**：
   - 背景：白色
   - 内边距：20px
   - 下边距：20px

2. **工具栏**：
   - 搜索框：最大宽度 300px
   - 按钮：高度 36px

3. **表格区域**：
   - 背景：白色
   - 表头背景：Background (#F5F7FA)
   - 行高：48px
   - 悬停效果：背景 Background

4. **编辑抽屉**（Drawer）：
   - 宽度：400px（Web），100%（Mobile）
   - 背景：白色
   - 阴影：-2px 0 8px rgba(0,0,0,0.1)
   - 从右侧滑入

## 8. 响应式断点

| 设备 | 宽度范围 | 说明 |
|------|---------|------|
| Mobile | < 768px | 移动端 |
| Tablet | 768px - 1024px | 平板 |
| Desktop | > 1024px | 桌面端 |

## 9. Figma 组件库建议

### 9.1 原子组件（Atoms）
- Button（Primary, Secondary, Text）
- Input
- Checkbox
- Radio
- Icon

### 9.2 分子组件（Molecules）
- Form Group（Label + Input）
- Search Box
- Card
- Entry Card

### 9.3 组织组件（Organisms）
- Navigation Bar
- Sidebar
- Table
- Drawer
- Login Form

### 9.4 页面模板（Templates）
- Login Page
- Portal Page
- Entry Management Page

## 10. 交互状态

### 10.1 按钮状态
- Default
- Hover
- Active
- Disabled
- Loading

### 10.2 输入框状态
- Default
- Focus
- Error
- Disabled

### 10.3 卡片状态
- Default
- Hover（阴影加深，向上移动 4px）

## 11. 图标规范

- **尺寸**：16px, 24px, 32px, 48px
- **风格**：线性图标（Line），描边宽度 1.5px
- **颜色**：使用 Text-Regular 或 Primary

## 12. 原型交互建议

在 Figma 中设置以下交互：

1. **登录表单提交**：
   - 按钮点击 → 显示加载状态 → 跳转到工作台

2. **系统入口卡片**：
   - 悬停 → 阴影加深，向上移动
   - 点击 → 跳转到目标系统（模拟）

3. **入口管理**：
   - 编辑按钮 → 打开右侧抽屉
   - 删除按钮 → 显示确认对话框

4. **表单验证**：
   - 输入框失焦 → 显示错误提示（如有）

## 13. 导出规范

### 13.1 图片导出
- **格式**：PNG（透明背景）或 JPG
- **分辨率**：1x, 2x, 3x
- **命名**：`页面名_组件名_状态@2x.png`

### 13.2 设计稿导出
- **格式**：PDF（用于评审）
- **尺寸**：按画板尺寸

## 14. 设计检查清单

在完成 Figma 原型后，请检查：

- [ ] 所有颜色已创建为 Color Style
- [ ] 所有文字已创建为 Text Style
- [ ] 所有阴影已创建为 Effect Style
- [ ] 组件已创建为 Component
- [ ] 响应式布局已适配移动端
- [ ] 交互状态已完整设置
- [ ] 设计规范文档已更新

---

**提示**：在 Figma 中创建原型时，建议先建立设计系统（颜色、字体、间距），再创建组件，最后组装页面。这样可以确保设计的一致性和可维护性。

