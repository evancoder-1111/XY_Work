# Kubernetes 数据库部署文档

本目录包含在 CentOS 7 虚拟机上使用 Kubernetes + Docker 部署 MySQL 8、PostgreSQL 和 Redis（主从）的完整文档。

## 文档索引

### 主要文档

1. **[服务器信息](server-info.md)** - 服务器 IP 和访问地址
   - 服务器配置信息
   - 所有服务的访问地址
   - 连接示例和配置

2. **[部署指南](deployment-guide.md)** - 数据库部署完整步骤
   - 环境准备
   - Docker 安装
   - Kubernetes 集群部署
   - 数据库服务部署（MySQL、PostgreSQL、Redis）
   - 验证和测试

2. **[应用部署指南](app-deployment-guide.md)** - 应用部署完整步骤
   - 镜像仓库配置
   - 应用镜像构建
   - 应用部署到 K8s
   - 配置说明
   - 更新和维护

3. **[连接信息文档](connection-info.md)** - 详细的连接信息
   - 集群内部访问方式
   - 外部访问方式（NodePort）
   - 连接字符串和 JDBC URL
   - 各种编程语言的连接示例
   - 应用配置示例

4. **[故障排查指南](troubleshooting.md)** - 常见问题解决方案
   - Pod 无法启动问题
   - 数据库连接失败
   - 应用部署问题
   - 存储问题
   - 网络问题
   - Redis 主从复制问题
   - 性能问题
   - 日志查看方法

## 服务器信息

- **IP 地址**: `192.168.2.75`
- 详细服务器信息和连接地址请参考 [服务器信息文档](./server-info.md)

## 快速开始

### 1. 环境准备

```bash
# 运行环境准备脚本
sudo bash scripts/k8s/setup-centos.sh
```

### 2. 安装 Docker

```bash
# 运行 Docker 安装脚本
sudo bash scripts/k8s/install-docker.sh
```

### 3. 安装 Kubernetes

**方案 A: minikube（推荐）**
```bash
bash scripts/k8s/setup-k8s.sh minikube
```

**方案 B: k3s（轻量级）**
```bash
sudo bash scripts/k8s/setup-k8s.sh k3s
```

### 4. 准备存储

```bash
# 运行存储准备脚本
sudo bash scripts/k8s/prepare-storage.sh
```

### 5. 部署数据库服务

**一键部署所有服务：**
```bash
bash scripts/k8s/deploy-all.sh
```

**或分别部署：**
```bash
bash scripts/k8s/deploy-mysql.sh
bash scripts/k8s/deploy-postgresql.sh
bash scripts/k8s/deploy-redis.sh
```

### 6. 部署应用服务

**部署本地镜像仓库（可选）：**
```bash
bash scripts/cicd/setup-registry.sh
```

**构建应用镜像：**
```bash
bash scripts/cicd/build-images.sh
```

**部署应用到 K8s：**
```bash
bash scripts/cicd/deploy-app.sh
```

### 7. 验证部署

```bash
# 验证所有数据库服务
bash scripts/k8s/verify-all.sh

# 测试数据库连接
bash scripts/k8s/test-connections.sh

# 查看应用状态
kubectl get pods -l 'app in (xy-portal-backend,xy-portal-frontend)'
```

## 部署架构

```
┌─────────────────────────────────────────┐
│         CentOS 7 虚拟机                 │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │    Kubernetes 集群                │  │
│  │  (minikube 或 k3s)                │  │
│  │                                   │  │
│  │  ┌──────────┐  ┌──────────────┐  │  │
│  │  │  MySQL   │  │  PostgreSQL  │  │  │
│  │  │  Stateful│  │  StatefulSet │  │  │
│  │  │  Set     │  │              │  │  │
│  │  └──────────┘  └──────────────┘  │  │
│  │                                   │  │
│  │  ┌──────────┐  ┌──────────────┐  │  │
│  │  │  Redis   │  │  Redis       │  │  │
│  │  │  Master  │  │  Slave (x2) │  │  │
│  │  └──────────┘  └──────────────┘  │  │
│  │                                   │  │
│  │  ┌────────────────────────────┐  │  │
│  │  │  PersistentVolume (hostPath)│  │  │
│  │  │  /data/mysql                │  │  │
│  │  │  /data/postgresql           │  │  │
│  │  │  /data/redis                │  │  │
│  │  └────────────────────────────┘  │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │         Docker Engine             │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

## 服务信息

### 数据库服务

| 服务 | 副本数 | 存储 | 端口 | 访问方式 |
|------|--------|------|------|----------|
| MySQL 8 | 1 | 20Gi | 3306 | ClusterIP + NodePort (30306) |
| PostgreSQL | 1 | 20Gi | 5432 | ClusterIP + NodePort (30432) |
| Redis Master | 1 | 10Gi | 6379 | ClusterIP + NodePort (30637) |
| Redis Slave | 2 | 10Gi | 6379 | ClusterIP + NodePort (30638) |

### 应用服务

| 服务 | 副本数 | 端口 | 访问方式 |
|------|--------|------|----------|
| 后端 API | 1 | 8080 | ClusterIP + NodePort (30080) |
| 前端应用 | 1 | 80 | ClusterIP + NodePort (30081) |
| Docker Registry | 1 | 5000 | ClusterIP + NodePort (30500) |

## 配置文件结构

```
k8s/
├── mysql/
│   ├── configmap.yaml      # MySQL 配置
│   ├── secret.yaml          # MySQL 密码
│   ├── pvc.yaml            # 存储声明
│   ├── statefulset.yaml    # MySQL 部署
│   └── service.yaml        # MySQL 服务
├── postgresql/
│   ├── configmap.yaml      # PostgreSQL 配置
│   ├── secret.yaml         # PostgreSQL 密码
│   ├── pvc.yaml            # 存储声明
│   ├── statefulset.yaml    # PostgreSQL 部署
│   └── service.yaml        # PostgreSQL 服务
├── redis/
│   ├── master/
│   │   ├── configmap.yaml  # Redis 主节点配置
│   │   ├── secret.yaml     # Redis 密码（可选）
│   │   ├── pvc.yaml        # 存储声明
│   │   ├── statefulset.yaml # Redis 主节点部署
│   │   └── service.yaml    # Redis 主节点服务
│   └── slave/
│       ├── configmap.yaml  # Redis 从节点配置
│       ├── statefulset.yaml # Redis 从节点部署
│       └── service.yaml    # Redis 从节点服务
└── storage/
    ├── storageclass.yaml   # 存储类定义
    └── pv.yaml             # 持久卷定义
```

## 脚本说明

所有部署脚本位于 `scripts/k8s/` 目录：

- `setup-centos.sh` - CentOS 7 环境准备
- `install-docker.sh` - Docker 安装
- `setup-k8s.sh` - Kubernetes 集群安装（支持 minikube 和 k3s）
- `prepare-storage.sh` - 存储准备
- `deploy-mysql.sh` - MySQL 部署
- `deploy-postgresql.sh` - PostgreSQL 部署
- `deploy-redis.sh` - Redis 部署
- `deploy-all.sh` - 一键部署所有服务
- `verify-all.sh` - 验证所有服务
- `test-connections.sh` - 测试数据库连接

## 常用命令

### 查看服务状态

```bash
# 查看所有 Pod
kubectl get pods -l 'app in (mysql,postgresql,redis)'

# 查看所有 Service
kubectl get svc -l 'app in (mysql,postgresql,redis)'

# 查看 PVC
kubectl get pvc
```

### 查看日志

```bash
# MySQL 日志
kubectl logs -l app=mysql

# PostgreSQL 日志
kubectl logs -l app=postgresql

# Redis 主节点日志
kubectl logs -l app=redis,role=master

# Redis 从节点日志
kubectl logs -l app=redis,role=slave
```

### 连接数据库

```bash
# MySQL
kubectl run -it --rm mysql-client --image=mysql:8.0 --restart=Never -- \
  mysql -h mysql -uroot -proot

# PostgreSQL
kubectl run -it --rm postgresql-client --image=postgres:15 --restart=Never -- \
  psql -h postgresql -U postgres

# Redis
kubectl run -it --rm redis-client --image=redis:7-alpine --restart=Never -- \
  redis-cli -h redis-master
```

## 注意事项

1. **实验环境**: 当前配置适用于单节点实验环境，使用 hostPath 存储
2. **生产环境**: 生产环境应使用网络存储（NFS、Ceph 等）和更安全的配置
3. **密码安全**: 所有默认密码仅用于实验，生产环境必须修改
4. **资源限制**: 根据实际资源调整 CPU 和内存限制
5. **数据备份**: 定期备份重要数据，配置备份策略

## 故障排查

遇到问题时，请参考 [故障排查指南](troubleshooting.md)。

常见问题：
- Pod 无法启动
- 数据库连接失败
- 存储问题
- 网络问题
- Redis 主从复制问题

## 下一步

- 配置应用连接到数据库
- 设置监控和告警
- 配置备份策略
- 优化性能参数
- 配置高可用（多节点集群）

## 相关资源

- [Kubernetes 官方文档](https://kubernetes.io/docs/)
- [Docker 官方文档](https://docs.docker.com/)
- [MySQL 8.0 文档](https://dev.mysql.com/doc/refman/8.0/en/)
- [PostgreSQL 文档](https://www.postgresql.org/docs/)
- [Redis 文档](https://redis.io/documentation)

