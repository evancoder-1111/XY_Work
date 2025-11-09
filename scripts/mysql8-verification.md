# MySQL 8 版本要求验证

## 配置确认

### 1. application.yml 配置
- ✅ **Hibernate 方言**: `org.hibernate.dialect.MySQL8Dialect` (MySQL 8 专用)
- ✅ **JDBC 驱动**: `com.mysql.cj.jdbc.Driver` (MySQL 8+ 驱动)
- ✅ **连接 URL**: `jdbc:mysql://localhost:3306/xy_portal`

### 2. pom.xml 依赖
- ✅ **MySQL 驱动**: `mysql-connector-j` (支持 MySQL 8.0+)

### 3. 数据库要求
- **最低版本**: MySQL 8.0
- **推荐版本**: MySQL 8.0 或更高版本
- **字符集**: utf8mb4
- **排序规则**: utf8mb4_unicode_ci

## 为什么需要 MySQL 8？

1. **Hibernate 方言**: 项目使用 `MySQL8Dialect`，专门为 MySQL 8+ 优化
2. **JDBC 驱动**: 使用 `mysql-connector-j`，针对 MySQL 8+ 设计
3. **新特性支持**: MySQL 8 提供了更好的性能和新特性
4. **兼容性**: Spring Boot 3.x 和 Spring Data JPA 3.x 推荐使用 MySQL 8+

## 验证 MySQL 版本

### 方法一：命令行
```bash
mysql --version
```

### 方法二：MySQL 客户端
```sql
SELECT VERSION();
```

### 方法三：使用脚本
```powershell
powershell -ExecutionPolicy Bypass -File scripts\mysql-version-check.ps1
```

## 升级指南

如果当前使用 MySQL 5.x，需要升级到 MySQL 8.0：

1. **备份数据**: 导出所有数据库和表
2. **下载 MySQL 8.0**: https://dev.mysql.com/downloads/mysql/
3. **安装 MySQL 8.0**: 按照官方文档安装
4. **导入数据**: 恢复备份的数据
5. **验证**: 运行版本检查脚本

## 相关文档

- MySQL 8.0 下载: https://dev.mysql.com/downloads/mysql/
- MySQL 8.0 文档: https://dev.mysql.com/doc/refman/8.0/en/
- 升级指南: https://dev.mysql.com/doc/refman/8.0/en/upgrading.html

