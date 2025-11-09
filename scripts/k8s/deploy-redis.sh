#!/bin/bash
# Redis 主从部署脚本

set -e

echo "=========================================="
echo "部署 Redis 主从集群"
echo "=========================================="

# 检查 kubectl 是否可用
if ! command -v kubectl &> /dev/null; then
    echo "错误: kubectl 未安装或不在 PATH 中"
    exit 1
fi

# 1. 部署 Redis 主节点
echo "[1/4] 部署 Redis 主节点..."
echo "  创建 ConfigMap..."
kubectl apply -f k8s/redis/master/configmap.yaml

echo "  创建 Secret..."
kubectl apply -f k8s/redis/master/secret.yaml

echo "  创建 PVC..."
kubectl apply -f k8s/redis/master/pvc.yaml

echo "  等待 PVC 绑定..."
kubectl wait --for=condition=Bound pvc/redis-master-pvc --timeout=60s || true

echo "  部署 StatefulSet..."
kubectl apply -f k8s/redis/master/statefulset.yaml

echo "  创建 Service..."
kubectl apply -f k8s/redis/master/service.yaml

# 等待主节点就绪
echo ""
echo "等待 Redis 主节点启动..."
kubectl wait --for=condition=ready pod -l app=redis,role=master --timeout=300s

# 2. 部署 Redis 从节点
echo ""
echo "[2/4] 部署 Redis 从节点..."
echo "  创建 ConfigMap..."
kubectl apply -f k8s/redis/slave/configmap.yaml

echo "  部署 StatefulSet..."
kubectl apply -f k8s/redis/slave/statefulset.yaml

echo "  创建 Service..."
kubectl apply -f k8s/redis/slave/service.yaml

# 等待从节点就绪
echo ""
echo "等待 Redis 从节点启动..."
kubectl wait --for=condition=ready pod -l app=redis,role=slave --timeout=300s

# 3. 验证主从复制
echo ""
echo "[3/4] 验证主从复制..."
sleep 10

MASTER_POD=$(kubectl get pod -l app=redis,role=master -o jsonpath='{.items[0].metadata.name}')
SLAVE_POD=$(kubectl get pod -l app=redis,role=slave -o jsonpath='{.items[0].metadata.name}')

echo "  在主节点设置测试键..."
kubectl exec $MASTER_POD -- redis-cli set test-key "test-value"

echo "  在从节点读取测试键..."
kubectl exec $SLAVE_POD -- redis-cli get test-key

# 4. 显示状态
echo ""
echo "[4/4] Redis 部署状态"
echo "=========================================="
kubectl get pods -l app=redis
kubectl get svc -l app=redis

echo ""
echo "=========================================="
echo "Redis 主从集群部署完成！"
echo "=========================================="
echo ""
echo "连接信息："
echo "  主节点 ClusterIP: redis-master:6379"
echo "  主节点 NodePort: <节点IP>:30637"
echo "  从节点 ClusterIP: redis-slave:6379"
echo "  从节点 NodePort: <节点IP>:30638"
echo ""
echo "测试连接："
echo "  kubectl run -it --rm redis-client --image=redis:7-alpine --restart=Never -- redis-cli -h redis-master"

