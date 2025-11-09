# 应用部署指南

本指南介绍如何在 Kubernetes 集群中部署 XY Portal 应用（前端和后端）。

## 前置要求

- Kubernetes 集群已部署并运行
- 数据库服务已部署（参考 [数据库部署指南](./deployment-guide.md)）
- Docker 已安装并运行
- kubectl 已配置并可以访问集群

## 部署步骤

### 步骤 1: 部署本地 Docker Registry（可选）

如果使用本地镜像仓库：

```bash
bash scripts/cicd/setup-registry.sh
```

**注意**：如果使用 Docker Hub，可以跳过此步骤，但需要：
1. 在 Docker Hub 创建仓库
2. 修改 `k8s/app/backend/deployment.yaml` 和 `k8s/app/frontend/deployment.yaml` 中的镜像地址
3. 配置 Docker 登录凭据

### 步骤 2: 构建应用镜像

```bash
# 设置 Registry 地址（如果使用本地 Registry）
export REGISTRY=localhost:30500

# 构建并推送镜像
bash scripts/cicd/build-images.sh
```

**手动构建方式**：

```bash
# 构建后端镜像
cd backend/XY_Portal
docker build -t localhost:30500/xy-portal-backend:latest .
docker push localhost:30500/xy-portal-backend:latest

# 构建前端镜像
cd frontend/XY_Portal_Frontend
docker build -t localhost:30500/xy-portal-frontend:latest .
docker push localhost:30500/xy-portal-frontend:latest
```

### 步骤 3: 部署应用

```bash
bash scripts/cicd/deploy-app.sh
```

**手动部署方式**：

```bash
# 部署后端
kubectl apply -f k8s/app/backend/configmap.yaml
kubectl apply -f k8s/app/backend/secret.yaml
kubectl apply -f k8s/app/backend/deployment.yaml
kubectl apply -f k8s/app/backend/service.yaml

# 部署前端
kubectl apply -f k8s/app/frontend/configmap.yaml
kubectl apply -f k8s/app/frontend/deployment.yaml
kubectl apply -f k8s/app/frontend/service.yaml
```

### 步骤 4: 验证部署

```bash
# 查看 Pod 状态
kubectl get pods -l 'app in (xy-portal-backend,xy-portal-frontend)'

# 查看 Service
kubectl get svc -l 'app in (xy-portal-backend,xy-portal-frontend)'

# 查看日志
kubectl logs -l app=xy-portal-backend
kubectl logs -l app=xy-portal-frontend
```

## 配置说明

### 后端配置

后端配置通过 ConfigMap 和 Secret 管理：

- **ConfigMap** (`k8s/app/backend/configmap.yaml`)：
  - 数据库连接配置（使用 K8s Service 名称 `mysql:3306`）
  - 应用配置

- **Secret** (`k8s/app/backend/secret.yaml`)：
  - JWT Secret
  - JWT 过期时间

### 前端配置

前端配置通过 ConfigMap 管理：

- **ConfigMap** (`k8s/app/frontend/configmap.yaml`)：
  - Nginx 配置
  - API 代理配置（指向后端 Service）

## 访问应用

### 通过 NodePort 访问

- **后端 API**: `http://192.168.2.75:30080`
- **前端应用**: `http://192.168.2.75:30081`

**注意**: 如果服务器 IP 不同，请替换为实际的节点 IP 地址。

### 通过端口转发访问（本地调试）

```bash
# 后端端口转发
kubectl port-forward svc/xy-portal-backend 8080:8080

# 前端端口转发
kubectl port-forward svc/xy-portal-frontend 8081:80
```

访问：
- 后端: `http://localhost:8080`
- 前端: `http://localhost:8081`

## 更新应用

### 更新镜像

1. 构建新镜像：
```bash
bash scripts/cicd/build-images.sh
```

2. 重启 Deployment：
```bash
kubectl rollout restart deployment/xy-portal-backend
kubectl rollout restart deployment/xy-portal-frontend
```

### 更新配置

修改 ConfigMap 或 Secret 后：

```bash
# 应用配置更改
kubectl apply -f k8s/app/backend/configmap.yaml
kubectl apply -f k8s/app/backend/secret.yaml

# 重启 Pod 使配置生效
kubectl rollout restart deployment/xy-portal-backend
```

## 故障排查

### Pod 无法启动

```bash
# 查看 Pod 详细信息
kubectl describe pod <pod-name>

# 查看日志
kubectl logs <pod-name>
```

### 无法连接到数据库

1. 检查数据库服务是否运行：
```bash
kubectl get svc mysql
```

2. 检查后端配置中的数据库地址是否正确（应该是 `mysql:3306`）

3. 测试数据库连接：
```bash
kubectl run -it --rm mysql-client --image=mysql:8.0 --restart=Never -- \
  mysql -h mysql -uroot -proot
```

### 前端无法访问后端 API

1. 检查后端服务是否运行：
```bash
kubectl get svc xy-portal-backend
```

2. 检查前端 ConfigMap 中的 API 地址配置

3. 测试后端连接：
```bash
kubectl run -it --rm curl --image=curlimages/curl --restart=Never -- \
  curl http://xy-portal-backend:8080/actuator/health
```

## 资源限制

当前配置的资源限制：

- **后端**：
  - 请求：512Mi 内存，250m CPU
  - 限制：1Gi 内存，1000m CPU

- **前端**：
  - 请求：128Mi 内存，100m CPU
  - 限制：256Mi 内存，500m CPU

根据实际需求可以调整 `deployment.yaml` 中的资源限制。

## 生产环境建议

1. **使用 HTTPS**：配置 Ingress 和 TLS 证书
2. **增加副本数**：提高可用性
3. **配置资源限制**：根据实际负载调整
4. **使用持久化存储**：如果需要存储文件
5. **配置监控和日志**：使用 Prometheus、Grafana 等
6. **定期备份**：备份数据库和应用配置

## 相关文档

- [数据库部署指南](./deployment-guide.md)
- [连接信息文档](./connection-info.md)
- [故障排查指南](./troubleshooting.md)

