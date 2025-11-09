# 数据库连接信息文档

本文档提供所有数据库服务的连接信息，包括集群内部和外部访问方式。

## 连接信息概览

| 数据库 | 服务名称 | ClusterIP | NodePort | 端口 | 用户名 | 密码 | 默认数据库 |
|--------|---------|-----------|----------|------|--------|------|-----------|
| MySQL 8 | mysql | mysql | <节点IP>:30306 | 3306 | root | root | xy_portal |
| PostgreSQL | postgresql | postgresql | <节点IP>:30432 | 5432 | postgres | postgres123 | postgres |
| Redis 主节点 | redis-master | redis-master | <节点IP>:30637 | 6379 | - | - | - |
| Redis 从节点 | redis-slave | redis-slave | <节点IP>:30638 | 6379 | - | - | - |

## MySQL 8 连接信息

### 集群内部访问

**服务名称**: `mysql`  
**端口**: `3306`  
**连接字符串**: `mysql://root:root@mysql:3306/xy_portal`

**JDBC URL**:
```
jdbc:mysql://mysql:3306/xy_portal?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
```

**连接示例**:

```bash
# 使用临时 Pod 连接
kubectl run -it --rm mysql-client --image=mysql:8.0 --restart=Never -- \
  mysql -h mysql -uroot -proot xy_portal

# 进入 MySQL Pod
kubectl exec -it $(kubectl get pod -l app=mysql -o jsonpath='{.items[0].metadata.name}') -- \
  mysql -uroot -proot
```

**Python 连接示例**:
```python
import mysql.connector

config = {
    'host': 'mysql',
    'port': 3306,
    'user': 'root',
    'password': 'root',
    'database': 'xy_portal'
}

conn = mysql.connector.connect(**config)
```

### 外部访问（NodePort）

**节点 IP**: 获取方式：`kubectl get nodes -o wide`  
**端口**: `30306`  
**连接字符串**: `mysql://root:root@<节点IP>:30306/xy_portal`

**JDBC URL**:
```
jdbc:mysql://<节点IP>:30306/xy_portal?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
```

**连接示例**:
```bash
# 从宿主机连接
mysql -h <节点IP> -P 30306 -uroot -proot xy_portal

# 使用 MySQL Workbench
# Host: <节点IP>
# Port: 30306
# Username: root
# Password: root
```

## PostgreSQL 连接信息

### 集群内部访问

**服务名称**: `postgresql`  
**端口**: `5432`  
**连接字符串**: `postgresql://postgres:postgres123@postgresql:5432/postgres`

**JDBC URL**:
```
jdbc:postgresql://postgresql:5432/postgres?user=postgres&password=postgres123
```

**连接示例**:

```bash
# 使用临时 Pod 连接
kubectl run -it --rm postgresql-client --image=postgres:15 --restart=Never -- \
  psql -h postgresql -U postgres

# 进入 PostgreSQL Pod
kubectl exec -it $(kubectl get pod -l app=postgresql -o jsonpath='{.items[0].metadata.name}') -- \
  psql -U postgres
```

**Python 连接示例**:
```python
import psycopg2

conn = psycopg2.connect(
    host='postgresql',
    port=5432,
    user='postgres',
    password='postgres123',
    database='postgres'
)
```

### 外部访问（NodePort）

**节点 IP**: 获取方式：`kubectl get nodes -o wide`  
**端口**: `30432`  
**连接字符串**: `postgresql://postgres:postgres123@<节点IP>:30432/postgres`

**JDBC URL**:
```
jdbc:postgresql://<节点IP>:30432/postgres?user=postgres&password=postgres123
```

**连接示例**:
```bash
# 从宿主机连接
psql -h <节点IP> -p 30432 -U postgres -d postgres

# 使用 pgAdmin
# Host: <节点IP>
# Port: 30432
# Username: postgres
# Password: postgres123
```

## Redis 连接信息

### 集群内部访问

#### Redis 主节点

**服务名称**: `redis-master`  
**端口**: `6379`  
**连接字符串**: `redis://redis-master:6379`

**连接示例**:

```bash
# 使用临时 Pod 连接
kubectl run -it --rm redis-client --image=redis:7-alpine --restart=Never -- \
  redis-cli -h redis-master

# 进入 Redis 主节点 Pod
kubectl exec -it $(kubectl get pod -l app=redis,role=master -o jsonpath='{.items[0].metadata.name}') -- \
  redis-cli
```

**Python 连接示例**:
```python
import redis

r = redis.Redis(host='redis-master', port=6379, db=0)
r.set('key', 'value')
value = r.get('key')
```

#### Redis 从节点

**服务名称**: `redis-slave`  
**端口**: `6379`  
**连接字符串**: `redis://redis-slave:6379`

**注意**: 从节点默认只读，用于读取操作。

**连接示例**:

```bash
# 使用临时 Pod 连接
kubectl run -it --rm redis-client --image=redis:7-alpine --restart=Never -- \
  redis-cli -h redis-slave

# 进入 Redis 从节点 Pod
kubectl exec -it $(kubectl get pod -l app=redis,role=slave -o jsonpath='{.items[0].metadata.name}') -- \
  redis-cli
```

### 外部访问（NodePort）

#### Redis 主节点

**节点 IP**: 获取方式：`kubectl get nodes -o wide`  
**端口**: `30637`  
**连接字符串**: `redis://<节点IP>:30637`

**连接示例**:
```bash
# 从宿主机连接
redis-cli -h <节点IP> -p 30637

# Python 连接
import redis
r = redis.Redis(host='<节点IP>', port=30637, db=0)
```

#### Redis 从节点

**节点 IP**: 获取方式：`kubectl get nodes -o wide`  
**端口**: `30638`  
**连接字符串**: `redis://<节点IP>:30638`

**连接示例**:
```bash
# 从宿主机连接
redis-cli -h <节点IP> -p 30638

# Python 连接
import redis
r = redis.Redis(host='<节点IP>', port=30638, db=0)
```

## 获取节点 IP

```bash
# 方法 1: 使用 kubectl
kubectl get nodes -o wide

# 方法 2: 查看 minikube IP（如果使用 minikube）
minikube ip

# 方法 3: 查看 k3s 节点 IP（如果使用 k3s）
kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}'
```

## 端口转发（本地调试）

如果无法使用 NodePort，可以使用端口转发：

```bash
# MySQL 端口转发
kubectl port-forward svc/mysql 3306:3306

# PostgreSQL 端口转发
kubectl port-forward svc/postgresql 5432:5432

# Redis 主节点端口转发
kubectl port-forward svc/redis-master 6379:6379

# Redis 从节点端口转发
kubectl port-forward svc/redis-slave 6380:6379
```

使用端口转发后，可以在本地使用 `localhost` 连接：
- MySQL: `localhost:3306`
- PostgreSQL: `localhost:5432`
- Redis 主节点: `localhost:6379`
- Redis 从节点: `localhost:6380`

## 应用配置示例

### Spring Boot 配置（application.yml）

```yaml
spring:
  datasource:
    url: jdbc:mysql://mysql:3306/xy_portal?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: root
    driver-class-name: com.mysql.cj.jdbc.Driver
  
  redis:
    host: redis-master
    port: 6379
    database: 0
```

### 环境变量配置

```bash
# MySQL
export MYSQL_HOST=mysql
export MYSQL_PORT=3306
export MYSQL_USER=root
export MYSQL_PASSWORD=root
export MYSQL_DATABASE=xy_portal

# PostgreSQL
export PG_HOST=postgresql
export PG_PORT=5432
export PG_USER=postgres
export PG_PASSWORD=postgres123
export PG_DATABASE=postgres

# Redis
export REDIS_HOST=redis-master
export REDIS_PORT=6379
```

## 安全注意事项

1. **密码安全**: 
   - 当前配置使用默认密码，仅适用于实验环境
   - 生产环境必须修改所有密码
   - 使用 Kubernetes Secrets 管理敏感信息

2. **网络访问**:
   - NodePort 暴露了数据库到外部网络
   - 生产环境应使用 Ingress 或 VPN 限制访问
   - 考虑使用网络策略（NetworkPolicy）限制访问

3. **SSL/TLS**:
   - 当前配置未启用 SSL/TLS
   - 生产环境应启用加密连接
   - 配置证书和密钥管理

4. **防火墙规则**:
   - 确保防火墙只开放必要的端口
   - 限制访问来源 IP

## 测试连接脚本

使用提供的测试脚本验证连接：

```bash
# 测试所有数据库连接
bash scripts/k8s/test-connections.sh

# 验证所有服务
bash scripts/k8s/verify-all.sh
```

## 故障排查

如果连接失败，请参考 [故障排查指南](troubleshooting.md)。

常见问题：
- 检查 Pod 是否运行：`kubectl get pods`
- 检查 Service 是否正常：`kubectl get svc`
- 检查网络连接：`kubectl exec <pod> -- ping <service-name>`
- 查看日志：`kubectl logs <pod-name>`

