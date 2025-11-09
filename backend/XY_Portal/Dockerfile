# 多阶段构建：后端应用 Dockerfile
# 阶段1：构建阶段
FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

# 复制 pom.xml 和源代码
COPY pom.xml .
COPY src ./src

# 构建应用（跳过测试，测试在 CI/CD 中执行）
RUN mvn clean package -DskipTests

# 阶段2：运行阶段
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# 创建非 root 用户
RUN addgroup -S spring && adduser -S spring -G spring

# 从构建阶段复制 JAR 文件
COPY --from=build /app/target/*.jar app.jar

# 更改文件所有者
RUN chown spring:spring app.jar

# 切换到非 root 用户
USER spring:spring

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# 启动应用
ENTRYPOINT ["java", "-jar", "app.jar"]

