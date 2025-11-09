# 星元空间统一数字门户 - 后端项目

## 项目简介

星元空间统一数字门户后端项目，基于 Spring Boot 3.x + Spring Security + JPA 构建，提供 RESTful API 接口，支持 SSO 单点登录和门户入口管理。

## 技术栈

| 技术/框架 | 版本 | 用途 |
|---------|------|------|
| Java | 21 | 编程语言 |
| Spring Boot | 3.x | 后端框架 |
| Spring Security | 6.x | 安全框架 |
| Spring Data JPA | 3.x | ORM框架 |
| MySQL | 8.x | 关系型数据库 |
| JWT | - | 认证令牌 |
| Lombok | 1.18+ | 代码工具 |
| Maven | 3.8+ | 构建工具 |

## 项目结构

```
XY_Portal/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── xy/
│   │   │           └── portal/
│   │   │               ├── XYPortalApplication.java  # 启动类
│   │   │               ├── config/                 # 配置类
│   │   │               │   ├── SecurityConfig.java
│   │   │               │   ├── JwtConfig.java
│   │   │               │   └── CorsConfig.java
│   │   │               ├── controller/             # 控制器层
│   │   │               │   ├── AuthController.java
│   │   │               │   ├── PortalController.java
│   │   │               │   └── DashboardController.java
│   │   │               ├── service/                # 业务层
│   │   │               │   ├── AuthService.java
│   │   │               │   ├── PortalEntryService.java
│   │   │               │   └── DashboardService.java
│   │   │               ├── repository/             # 数据访问层
│   │   │               │   ├── UserRepository.java
│   │   │               │   └── PortalEntryRepository.java
│   │   │               ├── entity/                 # 实体类
│   │   │               │   ├── User.java
│   │   │               │   └── PortalEntry.java
│   │   │               ├── dto/                   # 数据传输对象
│   │   │               │   ├── request/
│   │   │               │   │   ├── SsoLoginRequest.java
│   │   │               │   │   └── PortalEntryRequest.java
│   │   │               │   └── response/
│   │   │               │       ├── SsoLoginResponse.java
│   │   │               │       └── ApiResponse.java
│   │   │               ├── util/                  # 工具类
│   │   │               │   ├── JwtUtil.java
│   │   │               │   └── ResponseUtil.java
│   │   │               └── exception/             # 异常处理
│   │   │                   ├── GlobalExceptionHandler.java
│   │   │                   └── BusinessException.java
│   │   └── resources/
│   │       ├── application.yml                    # 应用配置
│   │       ├── application-dev.yml                # 开发环境配置
│   │       ├── application-prod.yml               # 生产环境配置
│   │       └── db/
│   │           ├── migration/                     # 数据库迁移脚本
│   │           │   └── V1__init_schema.sql
│   │           └── data.sql                       # 初始化数据
│   └── test/                                      # 测试代码
│       └── java/
│           └── com/xy/portal/
│               ├── controller/
│               ├── service/
│               └── repository/
├── pom.xml                                        # Maven 配置
└── README.md                                      # 项目说明（本文件）
```

## 开发规范

### 代码风格

- 遵循 Java 编码规范
- 使用 Lombok 减少样板代码
- 使用 Spring Boot 最佳实践
- 遵循 RESTful API 设计规范

### 命名规范

- **类名**：PascalCase（如 `UserController`）
- **方法名**：camelCase（如 `getUserInfo`）
- **常量**：UPPER_SNAKE_CASE（如 `MAX_RETRY_COUNT`）
- **包名**：小写字母，点分隔（如 `com.xy.portal.controller`）

### Controller 开发

```java
@RestController
@RequestMapping("/api/v1/portal")
@RequiredArgsConstructor
public class PortalController {
    
    private final PortalEntryService portalEntryService;
    
    @GetMapping("/entries")
    public ApiResponse<List<PortalEntryResponse>> getEntries(
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String keyword) {
        List<PortalEntryResponse> entries = portalEntryService.getEntries(category, keyword);
        return ApiResponse.success(entries);
    }
    
    @PostMapping("/entries")
    public ApiResponse<PortalEntryResponse> createEntry(
            @Valid @RequestBody PortalEntryRequest request) {
        PortalEntryResponse entry = portalEntryService.createEntry(request);
        return ApiResponse.success(entry);
    }
}
```

### Service 开发

```java
@Service
@RequiredArgsConstructor
@Transactional
public class PortalEntryService {
    
    private final PortalEntryRepository portalEntryRepository;
    
    public List<PortalEntryResponse> getEntries(String category, String keyword) {
        Specification<PortalEntry> spec = buildSpecification(category, keyword);
        List<PortalEntry> entries = portalEntryRepository.findAll(spec);
        return entries.stream()
                .map(this::toResponse)
                .toList();
    }
    
    public PortalEntryResponse createEntry(PortalEntryRequest request) {
        PortalEntry entry = toEntity(request);
        PortalEntry saved = portalEntryRepository.save(entry);
        return toResponse(saved);
    }
}
```

### Entity 开发

```java
@Entity
@Table(name = "portal_entries")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PortalEntry {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 255)
    private String name;
    
    @Column(length = 512)
    private String description;
    
    @Column(length = 255)
    private String icon;
    
    @Column(nullable = false, length = 255)
    private String url;
    
    @Column(length = 50)
    private String category;
    
    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private EntryStatus status;
    
    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;
}
```

## API 接口

### 认证接口

- `POST /api/v1/auth/sso/login` - SSO 登录
- `GET /api/v1/auth/user` - 获取当前用户信息
- `POST /api/v1/auth/logout` - 退出登录

### 门户入口接口

- `GET /api/v1/portal/entries` - 获取入口列表
- `POST /api/v1/portal/entries` - 创建入口
- `PUT /api/v1/portal/entries/{id}` - 更新入口
- `DELETE /api/v1/portal/entries/{id}` - 删除入口

### 工作台接口

- `GET /api/v1/dashboard/stats` - 获取统计信息
- `GET /api/v1/dashboard/tasks` - 获取待办任务
- `GET /api/v1/dashboard/activities` - 获取最近活动

详细接口文档请参考：[API接口文档](../../docs/api/API接口文档.md)

## 配置说明

### application.yml

```yaml
spring:
  application:
    name: xy-portal
  datasource:
    url: jdbc:mysql://localhost:3306/xy_portal?useUnicode=true&characterEncoding=utf8&useSSL=false
    username: root
    password: password
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    hibernate:
      ddl-auto: validate
    show-sql: true
    properties:
      hibernate:
        format_sql: true

jwt:
  secret: your-secret-key-here
  expiration: 86400000  # 24小时

server:
  port: 8080
```

### 环境变量

- `SPRING_PROFILES_ACTIVE` - 激活的环境（dev/prod）
- `DB_URL` - 数据库连接地址
- `DB_USERNAME` - 数据库用户名
- `DB_PASSWORD` - 数据库密码
- `JWT_SECRET` - JWT 密钥

## 数据库设计

详细数据库设计请参考：[数据库设计文档](../../docs/database/数据库设计文档.md)

主要数据表：
- `users` - 用户表
- `portal_entries` - 门户入口表
- `user_roles` - 用户角色表

## 安全配置

### JWT 认证

- Token 存储在 HTTP-only Cookie 或 Authorization Header
- Token 过期时间：24小时
- 支持 Token 刷新机制

### Spring Security

- 配置 CORS 跨域支持
- 配置 JWT 过滤器
- 配置接口权限控制

## 开发环境

### 环境要求

- JDK 17+
- Maven 3.8+
- MySQL 8.0+

### 启动步骤

```bash
# 1. 创建数据库
mysql -u root -p
CREATE DATABASE xy_portal CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 2. 执行数据库脚本
mysql -u root -p xy_portal < src/main/resources/db/migration/V1__init_schema.sql
mysql -u root -p xy_portal < src/main/resources/db/data.sql

# 3. 配置 application.yml
# 修改数据库连接信息

# 4. 启动应用
mvn spring-boot:run

# 或使用 IDE 运行 XYPortalApplication.java
```

### 测试

```bash
# 运行所有测试
mvn test

# 运行特定测试类
mvn test -Dtest=PortalControllerTest
```

## 部署说明

### 构建

```bash
# 打包
mvn clean package

# 生成 jar 文件
# target/xy-portal-1.0.0.jar
```

### 运行

```bash
# 运行 jar 文件
java -jar target/xy-portal-1.0.0.jar

# 指定环境
java -jar target/xy-portal-1.0.0.jar --spring.profiles.active=prod
```

## 部署说明

### 开发环境
1. 确保 MySQL 服务运行
2. 执行数据库初始化脚本
3. 配置 `application.yml` 数据库连接
4. 运行 `mvn spring-boot:run`

### 生产环境
1. **打包应用**：
   ```bash
   mvn clean package -DskipTests
   ```

2. **运行 JAR 包**：
   ```bash
   java -jar target/xy-portal-1.0.0.jar
   ```

3. **配置生产环境变量**：
   - 创建 `application-prod.yml`
   - 配置生产数据库连接
   - 配置 JWT secret（使用强密码）
   - 配置日志级别

4. **使用外部配置文件**：
   ```bash
   java -jar target/xy-portal-1.0.0.jar --spring.config.location=classpath:/application-prod.yml
   ```

### Docker 部署（可选）
```dockerfile
FROM openjdk:17-jre-slim
COPY target/xy-portal-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

## 参考文档

- [Spring Boot 官方文档](https://spring.io/projects/spring-boot)
- [Spring Security 文档](https://spring.io/projects/spring-security)
- [Spring Data JPA 文档](https://spring.io/projects/spring-data-jpa)
- [API 接口文档](../../docs/api/API接口文档.md)
- [数据库设计文档](../../docs/database/数据库设计文档.md)

## 开发注意事项

1. 所有接口必须遵循 RESTful 规范
2. 使用统一响应格式 `ApiResponse`
3. 异常统一处理，使用 `GlobalExceptionHandler`
4. 数据库操作使用 JPA，避免直接写 SQL
5. 敏感信息加密存储
6. 接口必须进行权限验证
7. 使用 `@Valid` 进行请求参数校验

