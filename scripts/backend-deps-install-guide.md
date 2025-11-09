# 后端 Maven 依赖安装指南

## 当前状态

❌ **Maven 未安装或不在 PATH 中**

## 问题影响

- 无法执行 `mvn dependency:resolve` 下载依赖
- 无法执行 `mvn compile` 编译项目
- 无法执行 `mvn spring-boot:run` 启动后端服务
- 无法执行 `mvn test` 运行后端测试

## 解决方案

### 方案一：安装 Maven（推荐）

1. **下载 Maven**
   - 访问：https://maven.apache.org/download.cgi
   - 下载 `apache-maven-3.9.x-bin.zip`（最新稳定版）

2. **解压并配置**
   ```powershell
   # 假设解压到 C:\Program Files\Apache\maven
   # 1. 解压到目标目录
   # 2. 配置环境变量
   ```

3. **配置环境变量**
   - 新建系统环境变量 `MAVEN_HOME` = `C:\Program Files\Apache\maven`
   - 在 `Path` 环境变量中添加：`%MAVEN_HOME%\bin`
   - 重启终端或重新加载环境变量

4. **验证安装**
   ```powershell
   mvn --version
   ```

5. **配置 Maven 镜像（可选，加速下载）**
   编辑 `%MAVEN_HOME%\conf\settings.xml`，在 `<mirrors>` 标签内添加：
   ```xml
   <mirror>
     <id>aliyunmaven</id>
     <mirrorOf>*</mirrorOf>
     <name>阿里云公共仓库</name>
     <url>https://maven.aliyun.com/repository/public</url>
   </mirror>
   ```

### 方案二：使用 Maven Wrapper（如果项目包含）

如果项目根目录有 `mvnw` 或 `mvnw.cmd` 文件，可以直接使用：

```powershell
# Windows
.\mvnw.cmd dependency:resolve
.\mvnw.cmd compile
```

### 方案三：使用 IDE（IntelliJ IDEA / Eclipse）

- IntelliJ IDEA：自动下载 Maven 并管理依赖
- Eclipse：需要手动配置 Maven

## 安装完成后执行

```powershell
cd backend\XY_Portal

# 1. 下载依赖
mvn dependency:resolve

# 2. 编译项目
mvn compile

# 3. 运行测试
mvn test

# 4. 启动服务
mvn spring-boot:run
```

## 注意事项

1. **Java 版本要求**：Maven 需要 Java 21+（当前系统 Java 版本为 1.8，需要先升级）
2. **网络问题**：如果下载依赖慢，建议配置国内镜像
3. **代理设置**：如果使用代理，需要在 `settings.xml` 中配置

## 相关文件

- Maven 配置文件：`backend/XY_Portal/pom.xml`
- 项目依赖列表：查看 `pom.xml` 中的 `<dependencies>` 部分

