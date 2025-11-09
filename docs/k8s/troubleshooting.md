# Kubernetes 数据库部署故障排查指南

本文档提供常见问题的排查和解决方案。

## 目录

- [Pod 无法启动](#pod-无法启动)
- [数据库连接失败](#数据库连接失败)
- [存储问题](#存储问题)
- [网络问题](#网络问题)
- [Redis 主从复制问题](#redis-主从复制问题)
- [性能问题](#性能问题)
- [日志查看](#日志查看)

## Pod 无法启动

### 问题：Pod 一直处于 Pending 状态

**可能原因：**
- 节点资源不足（CPU/内存）
- PVC 无法绑定到 PV
- 节点选择器不匹配

**排查步骤：**

```bash
# 查看 Pod 详细信息
kubectl describe pod <pod-name>

# 查看事件
kubectl get events --sort-by='.lastTimestamp'

# 检查节点资源
kubectl top nodes

# 检查 PVC 状态
kubectl get pvc
kubectl describe pvc <pvc-name>
```

**解决方案：**
- 如果资源不足，增加节点资源或调整 Pod 的资源限制
- 如果 PVC 无法绑定，检查 PV 是否可用：`kubectl get pv`
- 确保存储目录存在且有正确权限：`ls -la /data/`

### 问题：Pod 一直处于 CrashLoopBackOff 状态

**可能原因：**
- 配置错误
- 镜像拉取失败
- 启动命令失败
- 健康检查失败

**排查步骤：**

```bash
# 查看 Pod 日志
kubectl logs <pod-name>

# 查看前一次运行的日志
kubectl logs <pod-name> --previous

# 查看 Pod 详细信息
kubectl describe pod <pod-name>

# 进入 Pod 调试
kubectl exec -it <pod-name> -- /bin/bash
```

**解决方案：**
- 检查 ConfigMap 和 Secret 是否正确创建
- 验证镜像是否存在：`docker pull <image-name>`
- 检查启动命令和参数是否正确
- 调整健康检查的超时时间和延迟时间

## 数据库连接失败

### 问题：无法连接到 MySQL

**排查步骤：**

```bash
# 检查 MySQL Pod 状态
kubectl get pods -l app=mysql

# 查看 MySQL 日志
kubectl logs -l app=mysql

# 测试 Pod 内部连接
kubectl exec -it <mysql-pod-name> -- mysql -uroot -proot

# 检查 Service
kubectl get svc mysql
kubectl describe svc mysql

# 测试 Service 连接
kubectl run -it --rm mysql-client --image=mysql:8.0 --restart=Never -- \
  mysql -h mysql -uroot -proot
```

**常见解决方案：**
- 确保 MySQL Pod 正在运行
- 检查密码是否正确（查看 Secret）
- 验证 Service 选择器是否匹配 Pod 标签
- 检查防火墙规则是否阻止连接

### 问题：无法连接到 PostgreSQL

**排查步骤：**

```bash
# 检查 PostgreSQL Pod 状态
kubectl get pods -l app=postgresql

# 查看 PostgreSQL 日志
kubectl logs -l app=postgresql

# 测试 Pod 内部连接
kubectl exec -it <postgresql-pod-name> -- psql -U postgres

# 检查 Service
kubectl get svc postgresql
```

**常见解决方案：**
- 确保 PostgreSQL Pod 正在运行
- 检查密码是否正确
- 验证数据库是否已初始化
- 检查 pg_hba.conf 配置

### 问题：无法连接到 Redis

**排查步骤：**

```bash
# 检查 Redis Pod 状态
kubectl get pods -l app=redis

# 查看 Redis 日志
kubectl logs -l app=redis,role=master
kubectl logs -l app=redis,role=slave

# 测试连接
kubectl exec -it <redis-pod-name> -- redis-cli ping
```

**常见解决方案：**
- 确保 Redis Pod 正在运行
- 如果配置了密码，检查密码是否正确
- 验证网络策略是否允许连接

## 存储问题

### 问题：PVC 无法绑定

**排查步骤：**

```bash
# 查看 PVC 状态
kubectl get pvc
kubectl describe pvc <pvc-name>

# 查看 PV 状态
kubectl get pv
kubectl describe pv <pv-name>

# 检查存储类
kubectl get storageclass
kubectl describe storageclass local-storage
```

**常见解决方案：**
- 确保 PV 已创建且状态为 Available
- 检查 PV 的 accessModes 是否与 PVC 匹配
- 验证存储类名称是否正确
- 检查存储路径是否存在：`ls -la /data/`

### 问题：数据丢失

**排查步骤：**

```bash
# 检查数据目录
ls -la /data/mysql/
ls -la /data/postgresql/
ls -la /data/redis/

# 检查 Pod 挂载
kubectl describe pod <pod-name> | grep -A 5 Mounts

# 验证数据持久化
kubectl exec <pod-name> -- ls -la /var/lib/mysql
```

**常见解决方案：**
- 确保使用 PersistentVolume 而不是 emptyDir
- 检查数据目录权限
- 验证 Pod 重启后数据是否保留
- 检查磁盘空间：`df -h /data`

## 网络问题

### 问题：Service 无法访问

**排查步骤：**

```bash
# 检查 Service
kubectl get svc
kubectl describe svc <service-name>

# 检查 Endpoints
kubectl get endpoints <service-name>

# 测试 DNS 解析
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup mysql

# 测试 Service 连接
kubectl run -it --rm debug --image=busybox --restart=Never -- \
  telnet mysql 3306
```

**常见解决方案：**
- 确保 Service 选择器匹配 Pod 标签
- 检查 Pod 是否在运行
- 验证端口配置是否正确
- 检查网络策略是否阻止连接

### 问题：NodePort 无法访问

**排查步骤：**

```bash
# 检查 NodePort Service
kubectl get svc -l app=mysql
kubectl describe svc mysql-nodeport

# 检查节点 IP
kubectl get nodes -o wide

# 测试本地连接
curl -v <node-ip>:<nodeport>

# 检查防火墙
sudo firewall-cmd --list-ports
sudo iptables -L -n | grep <nodeport>
```

**常见解决方案：**
- 确保防火墙开放了 NodePort 端口
- 检查 SELinux 设置
- 验证节点 IP 是否正确
- 检查网络路由配置

## Redis 主从复制问题

### 问题：从节点无法连接到主节点

**排查步骤：**

```bash
# 检查 Redis 主节点状态
kubectl get pods -l app=redis,role=master
kubectl logs -l app=redis,role=master

# 检查 Redis 从节点状态
kubectl get pods -l app=redis,role=slave
kubectl logs -l app=redis,role=slave

# 查看主节点复制信息
kubectl exec <redis-master-pod> -- redis-cli info replication

# 查看从节点复制信息
kubectl exec <redis-slave-pod> -- redis-cli info replication
```

**常见解决方案：**
- 确保主节点 Service 名称正确（redis-master）
- 检查从节点配置中的主节点地址
- 验证网络连接是否正常
- 检查主节点是否允许从节点连接

### 问题：数据未同步到从节点

**排查步骤：**

```bash
# 在主节点设置测试键
kubectl exec <redis-master-pod> -- redis-cli set test-key "test-value"

# 等待几秒后检查从节点
kubectl exec <redis-slave-pod> -- redis-cli get test-key

# 查看复制延迟
kubectl exec <redis-slave-pod> -- redis-cli info replication | grep master_repl_offset
```

**常见解决方案：**
- 检查主从连接状态
- 验证复制配置是否正确
- 检查网络延迟
- 查看是否有复制错误日志

## 性能问题

### 问题：数据库响应慢

**排查步骤：**

```bash
# 检查 Pod 资源使用
kubectl top pods

# 检查节点资源
kubectl top nodes

# 查看 Pod 资源限制
kubectl describe pod <pod-name> | grep -A 5 "Limits\|Requests"

# 检查数据库慢查询（MySQL）
kubectl exec <mysql-pod> -- mysql -uroot -proot -e "SHOW PROCESSLIST;"
```

**常见解决方案：**
- 增加 Pod 的 CPU 和内存限制
- 优化数据库配置参数
- 检查是否有慢查询
- 考虑使用更强大的节点

### 问题：磁盘 I/O 高

**排查步骤：**

```bash
# 检查磁盘使用
df -h
iostat -x 1

# 检查 Pod 磁盘使用
kubectl exec <pod-name> -- df -h

# 查看数据库日志大小
du -sh /data/mysql/
du -sh /data/postgresql/
```

**常见解决方案：**
- 清理旧的日志文件
- 优化数据库配置减少 I/O
- 使用 SSD 存储
- 考虑数据归档

## 日志查看

### 查看 Pod 日志

```bash
# 查看当前日志
kubectl logs <pod-name>

# 查看所有容器的日志
kubectl logs <pod-name> --all-containers=true

# 实时跟踪日志
kubectl logs -f <pod-name>

# 查看最近 N 行日志
kubectl logs <pod-name> --tail=100

# 查看指定时间范围的日志
kubectl logs <pod-name> --since=1h
```

### 查看系统日志

```bash
# 查看 kubelet 日志（如果使用 k3s）
sudo journalctl -u k3s -f

# 查看 Docker 日志
sudo journalctl -u docker -f

# 查看系统日志
sudo journalctl -f
```

## 常用调试命令

```bash
# 查看所有资源
kubectl get all

# 查看命名空间
kubectl get namespaces

# 查看事件（按时间排序）
kubectl get events --all-namespaces --sort-by='.lastTimestamp'

# 查看资源详细信息
kubectl describe <resource-type> <resource-name>

# 进入 Pod 调试
kubectl exec -it <pod-name> -- /bin/bash

# 临时运行调试容器
kubectl run -it --rm debug --image=busybox --restart=Never -- sh

# 端口转发（用于本地调试）
kubectl port-forward svc/mysql 3306:3306
```

## 获取帮助

如果以上方法无法解决问题，请：

1. 收集相关信息：
   - Pod 日志：`kubectl logs <pod-name> > pod.log`
   - Pod 描述：`kubectl describe pod <pod-name> > pod-describe.txt`
   - 事件：`kubectl get events > events.txt`

2. 检查 Kubernetes 版本兼容性

3. 查看官方文档和社区资源

4. 检查 GitHub Issues 是否有类似问题

