# 数据库初始化状态

## 数据库配置信息

- **数据库名称**: `xy_portal`
- **数据库主机**: `localhost`
- **数据库端口**: `3306`
- **数据库用户**: `root`
- **数据库密码**: `root` (配置在 `application.yml` 中，生产环境需修改)

## 初始化步骤

### 方法一：使用 MySQL 命令行

1. **连接 MySQL**:
   ```bash
   mysql -u root -p
   ```

2. **创建数据库**:
   ```sql
   CREATE DATABASE IF NOT EXISTS `xy_portal` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

3. **执行表结构脚本**:
   ```bash
   mysql -u root -p xy_portal < backend/XY_Portal/src/main/resources/db/schema.sql
   ```

4. **执行初始数据脚本**:
   ```bash
   mysql -u root -p xy_portal < backend/XY_Portal/src/main/resources/db/data.sql
   ```

### 方法二：使用 MySQL Workbench 或 DBeaver

1. 打开 MySQL Workbench 或 DBeaver
2. 连接到本地 MySQL 服务器
3. 打开并执行 `backend/XY_Portal/src/main/resources/db/schema.sql`
4. 打开并执行 `backend/XY_Portal/src/main/resources/db/data.sql`

### 方法三：使用提供的脚本

运行以下脚本获取详细指南：
```powershell
powershell -ExecutionPolicy Bypass -File scripts\init-database.ps1
```

## 验证数据库初始化

运行验证脚本：
```powershell
powershell -ExecutionPolicy Bypass -File scripts\verify-database.ps1
```

或手动检查：
```sql
-- 检查数据库是否存在
SHOW DATABASES LIKE 'xy_portal';

-- 检查表是否存在
USE xy_portal;
SHOW TABLES;

-- 检查用户数据
SELECT COUNT(*) FROM users;
SELECT * FROM users;

-- 检查入口数据
SELECT COUNT(*) FROM portal_entries;
SELECT * FROM portal_entries;
```

## 预期结果

### 表结构
- `users` - 用户表
- `portal_entries` - 门户入口表
- `user_roles` - 用户角色表（预留）

### 初始数据
- **用户**: 2 个测试用户
  - `admin` / `admin123` (管理员)
  - `user1` / `admin123` (普通用户)
- **入口**: 6 个示例入口
  - OA系统、CRM系统、项目管理、知识库、财务系统、人事系统

## 注意事项

1. 确保 MySQL 服务正在运行
2. 确保数据库用户有足够的权限
3. 生产环境部署前，务必修改 `application.yml` 中的数据库密码
4. 如果使用不同的数据库名称或连接信息，需要同步更新 `application.yml`

