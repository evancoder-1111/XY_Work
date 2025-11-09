#!/bin/bash
# PostgreSQL 部署脚本

set -e

echo "=========================================="
echo "部署 PostgreSQL"
echo "=========================================="

# 检查 kubectl 是否可用
if ! command -v kubectl &> /dev/null; then
    echo "错误: kubectl 未安装或不在 PATH 中"
    exit 1
fi

# 1. 创建 ConfigMap
echo "[1/5] 创建 ConfigMap..."
kubectl apply -f k8s/postgresql/configmap.yaml

# 2. 创建 Secret
echo "[2/5] 创建 Secret..."
kubectl apply -f k8s/postgresql/secret.yaml

# 3. 创建 PVC
echo "[3/5] 创建 PersistentVolumeClaim..."
kubectl apply -f k8s/postgresql/pvc.yaml

# 等待 PVC 绑定
echo "等待 PVC 绑定..."
kubectl wait --for=condition=Bound pvc/postgresql-pvc --timeout=60s || true

# 4. 部署 StatefulSet
echo "[4/5] 部署 StatefulSet..."
kubectl apply -f k8s/postgresql/statefulset.yaml

# 5. 创建 Service
echo "[5/5] 创建 Service..."
kubectl apply -f k8s/postgresql/service.yaml

# 等待 Pod 就绪
echo ""
echo "等待 PostgreSQL Pod 启动..."
kubectl wait --for=condition=ready pod -l app=postgresql --timeout=300s

# 显示状态
echo ""
echo "=========================================="
echo "PostgreSQL 部署状态"
echo "=========================================="
kubectl get pods -l app=postgresql
kubectl get svc -l app=postgresql

echo ""
echo "=========================================="
echo "PostgreSQL 部署完成！"
echo "=========================================="
echo ""
echo "连接信息："
echo "  ClusterIP: postgresql:5432"
echo "  NodePort: <节点IP>:30432"
echo ""
echo "测试连接："
echo "  kubectl run -it --rm postgresql-client --image=postgres:15 --restart=Never -- psql -h postgresql -U postgres"

