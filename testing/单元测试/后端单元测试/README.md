# 后端单元测试

使用 JUnit 5 和 Mockito 进行后端单元测试。

## 测试框架

- **测试框架**：JUnit 5
- **Mock框架**：Mockito
- **断言库**：JUnit 5 内置断言

## 测试范围

- Service层单元测试
- Controller层单元测试
- Repository层单元测试
- 工具类测试

## 已创建的测试用例

- `src/test/java/com/xy/portal/service/AuthServiceTest.java` - 认证服务测试
- `src/test/java/com/xy/portal/service/PortalEntryServiceTest.java` - 门户入口服务测试

## 运行测试

```bash
cd backend/XY_Portal
mvn test                    # 运行所有测试
mvn test -Dtest=AuthServiceTest  # 运行指定测试类
```

## 测试配置

测试依赖已配置在 `pom.xml` 中，包括：
- spring-boot-starter-test
- spring-security-test

