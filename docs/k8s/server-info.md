# 服务器信息

## 服务器配置

- **IP 地址**: `192.168.2.75`
- **操作系统**: CentOS 7
- **Kubernetes**: minikube 或 k3s（单节点集群）

## 服务访问地址

### 数据库服务

| 服务 | 内部地址 | 外部访问（NodePort） |
|------|---------|---------------------|
| MySQL 8 | `mysql:3306` | `192.168.2.75:30306` |
| PostgreSQL | `postgresql:5432` | `192.168.2.75:30432` |
| Redis 主节点 | `redis-master:6379` | `192.168.2.75:30637` |
| Redis 从节点 | `redis-slave:6379` | `192.168.2.75:30638` |

### 应用服务

| 服务 | 内部地址 | 外部访问（NodePort） |
|------|---------|---------------------|
| 后端 API | `xy-portal-backend:8080` | `192.168.2.75:30080` |
| 前端应用 | `xy-portal-frontend:80` | `192.168.2.75:30081` |
| Docker Registry | `docker-registry.registry.svc.cluster.local:5000` | `192.168.2.75:30500` |

## 连接示例

### 从本地 Windows 连接数据库

```bash
# MySQL
mysql -h 192.168.2.75 -P 30306 -uroot -proot

# PostgreSQL
psql -h 192.168.2.75 -p 30432 -U postgres

# Redis
redis-cli -h 192.168.2.75 -p 30637
```

### 应用配置

#### 后端 application.yml（本地开发）

```yaml
spring:
  datasource:
    url: jdbc:mysql://192.168.2.75:30306/xy_portal?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=Asia/Shanghai
    username: root
    password: root
```

#### 前端 API 配置（本地开发）

如果前端在本地运行，需要配置 API 地址：

```typescript
// src/utils/request.ts 或环境变量
const API_BASE_URL = 'http://192.168.2.75:30080'
```

### 访问应用

- **前端应用**: http://192.168.2.75:30081
- **后端 API**: http://192.168.2.75:30080

## Docker Registry 配置

如果使用本地 Docker Registry，需要在节点上配置：

```bash
# 在服务器上执行
sudo mkdir -p /etc/docker
echo '{"insecure-registries": ["192.168.2.75:30500"]}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
```

## 防火墙配置

确保以下端口已开放：

```bash
# 在服务器上执行
sudo firewall-cmd --permanent --add-port=30306/tcp  # MySQL
sudo firewall-cmd --permanent --add-port=30432/tcp  # PostgreSQL
sudo firewall-cmd --permanent --add-port=30637/tcp  # Redis Master
sudo firewall-cmd --permanent --add-port=30638/tcp  # Redis Slave
sudo firewall-cmd --permanent --add-port=30080/tcp   # Backend
sudo firewall-cmd --permanent --add-port=30081/tcp   # Frontend
sudo firewall-cmd --permanent --add-port=30500/tcp   # Registry
sudo firewall-cmd --reload
```

## 快速连接命令

### 数据库初始化（从本地执行）

```bash
# MySQL 初始化
mysql -h 192.168.2.75 -P 30306 -uroot -proot < backend/XY_Portal/src/main/resources/db/schema.sql
mysql -h 192.168.2.75 -P 30306 -uroot -proot xy_portal < backend/XY_Portal/src/main/resources/db/data.sql
```

### 测试连接

```bash
# 测试 MySQL
mysql -h 192.168.2.75 -P 30306 -uroot -proot -e "SELECT VERSION();"

# 测试后端 API
curl http://192.168.2.75:30080/

# 测试前端
curl http://192.168.2.75:30081/
```

