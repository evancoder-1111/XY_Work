# Kubernetes 数据库部署指南

本指南介绍如何在 CentOS 7 虚拟机上使用 Kubernetes + Docker 部署 MySQL 8、PostgreSQL 和 Redis（主从）。

## 前置要求

- CentOS 7 虚拟机
- 至少 4GB 内存
- 至少 50GB 磁盘空间
- root 权限或 sudo 权限
- 网络连接（用于下载镜像和包）

## 部署步骤

### 步骤 1: CentOS 7 环境准备

```bash
# 运行环境准备脚本
sudo bash scripts/k8s/setup-centos.sh
```

此脚本将：
- 更新系统包
- 安装必要工具（vim, wget, curl, net-tools, git）
- 配置防火墙规则
- 配置 SELinux（设置为 permissive）
- 禁用 swap（Kubernetes 要求）

### 步骤 2: 安装 Docker

```bash
# 运行 Docker 安装脚本
sudo bash scripts/k8s/install-docker.sh
```

此脚本将：
- 卸载旧版本 Docker（如果存在）
- 添加 Docker 官方仓库
- 安装 Docker CE
- 配置 Docker 镜像加速（阿里云镜像）
- 启动 Docker 并设置开机自启

**注意**: 如果当前用户不是 root，安装完成后需要重新登录以使 docker 组权限生效。

### 步骤 3: 安装 Kubernetes

选择以下两种方案之一：

#### 方案 A: minikube（推荐用于实验）

```bash
# 运行 K8s 安装脚本（minikube）
bash scripts/k8s/setup-k8s.sh minikube
```

#### 方案 B: k3s（轻量级，适合资源受限环境）

```bash
# 运行 K8s 安装脚本（k3s）
sudo bash scripts/k8s/setup-k8s.sh k3s
```

**注意**: k3s 需要 root 权限。

### 步骤 4: 准备存储

```bash
# 运行存储准备脚本
sudo bash scripts/k8s/prepare-storage.sh
```

此脚本将：
- 创建数据目录（/data/mysql, /data/postgresql, /data/redis）
- 设置目录权限
- 创建 StorageClass 和 PersistentVolume

### 步骤 5: 部署数据库服务

#### 方式一：一键部署所有服务

```bash
# 一键部署所有数据库服务
bash scripts/k8s/deploy-all.sh
```

#### 方式二：分别部署

```bash
# 部署 MySQL
bash scripts/k8s/deploy-mysql.sh

# 部署 PostgreSQL
bash scripts/k8s/deploy-postgresql.sh

# 部署 Redis
bash scripts/k8s/deploy-redis.sh
```

### 步骤 6: 验证部署

```bash
# 验证所有服务
bash scripts/k8s/verify-all.sh

# 测试数据库连接
bash scripts/k8s/test-connections.sh
```

## 连接信息

### MySQL 8

- **ClusterIP**: `mysql:3306`
- **NodePort**: `<节点IP>:30306`
- **用户名**: `root`
- **密码**: `root`
- **数据库**: `xy_portal`

### PostgreSQL

- **ClusterIP**: `postgresql:5432`
- **NodePort**: `<节点IP>:30432`
- **用户名**: `postgres`
- **密码**: `postgres123`
- **数据库**: `xy_portal`

### Redis

- **主节点 ClusterIP**: `redis-master:6379`
- **主节点 NodePort**: `<节点IP>:30637`
- **从节点 ClusterIP**: `redis-slave:6379`
- **从节点 NodePort**: `<节点IP>:30638`
- **密码**: 无（可选配置）

## 测试连接

### 测试 MySQL

```bash
# 使用临时 Pod 测试
kubectl run -it --rm mysql-client --image=mysql:8.0 --restart=Never -- \
  mysql -h mysql -uroot -proot

# 或进入 MySQL Pod
kubectl exec -it $(kubectl get pod -l app=mysql -o jsonpath='{.items[0].metadata.name}') -- \
  mysql -uroot -proot
```

### 测试 PostgreSQL

```bash
# 使用临时 Pod 测试
kubectl run -it --rm postgresql-client --image=postgres:15 --restart=Never -- \
  psql -h postgresql -U postgres

# 或进入 PostgreSQL Pod
kubectl exec -it $(kubectl get pod -l app=postgresql -o jsonpath='{.items[0].metadata.name}') -- \
  psql -U postgres
```

### 测试 Redis

```bash
# 测试主节点
kubectl run -it --rm redis-client --image=redis:7-alpine --restart=Never -- \
  redis-cli -h redis-master

# 测试从节点
kubectl run -it --rm redis-client --image=redis:7-alpine --restart=Never -- \
  redis-cli -h redis-slave
```

## 常用命令

### 查看 Pod 状态

```bash
# 查看所有数据库 Pod
kubectl get pods -l 'app in (mysql,postgresql,redis)'

# 查看 MySQL Pod
kubectl get pods -l app=mysql

# 查看 PostgreSQL Pod
kubectl get pods -l app=postgresql

# 查看 Redis Pod
kubectl get pods -l app=redis
```

### 查看 Service

```bash
# 查看所有数据库 Service
kubectl get svc -l 'app in (mysql,postgresql,redis)'
```

### 查看日志

```bash
# 查看 MySQL 日志
kubectl logs -l app=mysql

# 查看 PostgreSQL 日志
kubectl logs -l app=postgresql

# 查看 Redis 主节点日志
kubectl logs -l app=redis,role=master

# 查看 Redis 从节点日志
kubectl logs -l app=redis,role=slave
```

### 查看 PVC 状态

```bash
kubectl get pvc
```

## 故障排查

如果遇到问题，请参考 [故障排查指南](troubleshooting.md)。

## 连接信息

详细的连接信息、连接字符串和配置示例，请参考 [连接信息文档](connection-info.md)。

## 注意事项

1. **存储方案**: 本部署使用 hostPath 存储，适合单节点实验环境。生产环境应使用网络存储（NFS、Ceph 等）。

2. **密码安全**: 所有 Secret 中的密码使用 base64 编码。生产环境应使用更安全的密钥管理（如 Kubernetes Secrets、Vault 等）。

3. **资源限制**: 根据虚拟机资源设置合适的 CPU 和内存限制。当前配置：
   - MySQL: 512Mi-2Gi 内存，250m-1000m CPU
   - PostgreSQL: 512Mi-2Gi 内存，250m-1000m CPU
   - Redis: 256Mi-1Gi 内存，100m-500m CPU

4. **数据持久化**: 数据存储在 `/data` 目录下，确保有足够的磁盘空间。

5. **网络访问**: 配置了 NodePort 以便从宿主机访问数据库服务。

## 下一步

- 配置应用连接到数据库
- 设置监控和告警
- 配置备份策略
- 优化性能参数

