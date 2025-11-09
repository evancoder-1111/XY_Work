# 环境问题报告

## 检查时间
2025-01-15

## 发现的问题

### 1. Java 版本过低
- **当前版本**: Java 1.8.0_471
- **要求版本**: >= 21
- **影响**: 无法编译和运行 Spring Boot 3.2.0 项目（需要 Java 21+）
- **解决方案**: 
  - 下载并安装 Java 21 或更高版本
  - 访问: https://www.oracle.com/java/technologies/downloads/
  - 或使用 OpenJDK: https://adoptium.net/
  - 安装后更新 JAVA_HOME 环境变量

### 2. Maven 未安装
- **状态**: Maven 未安装或不在 PATH 中
- **影响**: 无法下载后端依赖和编译项目
- **解决方案**:
  - 下载 Maven: https://maven.apache.org/download.cgi
  - 解压到目录（如 C:\Program Files\Apache\maven）
  - 添加 Maven 的 bin 目录到 PATH 环境变量
  - 或使用 IDE（如 IntelliJ IDEA）内置的 Maven

## 已通过检查

### 1. Node.js
- **版本**: v24.11.0
- **状态**: ✓ 满足要求（>= 18.0.0）

### 2. MySQL 服务
- **状态**: ✓ 服务正在运行
- **要求**: MySQL 8.0 或更高版本（不支持 MySQL 5.x）

### 3. 端口可用性
- **端口 8080**: ✓ 可用（后端服务）
- **端口 8081**: ✓ 可用（前端服务）

### 4. 项目文件
- **前端项目**: ✓ 目录和 package.json 存在
- **后端项目**: ✓ 目录和 pom.xml 存在
- **数据库脚本**: ✓ schema.sql 和 data.sql 存在

### 5. 前端依赖
- **状态**: ✓ 已成功安装（379 packages）

## 下一步行动

1. **安装 Java 21+**
   - 下载并安装 Java 21 或更高版本
   - 配置 JAVA_HOME 环境变量
   - 验证: `java -version`

2. **安装 Maven**
   - 下载并安装 Maven
   - 配置 PATH 环境变量
   - 验证: `mvn --version`

3. **完成环境配置后**
   - 重新运行环境检查脚本: `.\scripts\check-environment.ps1`
   - 继续执行项目运行验证步骤

## 临时解决方案

如果暂时无法安装 Java 17 和 Maven，可以：
- 使用 IDE（如 IntelliJ IDEA）内置的 Java 和 Maven
- 或使用 Docker 容器运行后端服务

