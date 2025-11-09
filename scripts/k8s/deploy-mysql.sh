#!/bin/bash
# MySQL 8 部署脚本

set -e

echo "=========================================="
echo "部署 MySQL 8"
echo "=========================================="

# 检查 kubectl 是否可用
if ! command -v kubectl &> /dev/null; then
    echo "错误: kubectl 未安装或不在 PATH 中"
    exit 1
fi

# 1. 创建 ConfigMap
echo "[1/5] 创建 ConfigMap..."
kubectl apply -f k8s/mysql/configmap.yaml

# 2. 创建 Secret
echo "[2/5] 创建 Secret..."
kubectl apply -f k8s/mysql/secret.yaml

# 3. 创建 PVC
echo "[3/5] 创建 PersistentVolumeClaim..."
kubectl apply -f k8s/mysql/pvc.yaml

# 等待 PVC 绑定
echo "等待 PVC 绑定..."
kubectl wait --for=condition=Bound pvc/mysql-pvc --timeout=60s || true

# 4. 部署 StatefulSet
echo "[4/5] 部署 StatefulSet..."
kubectl apply -f k8s/mysql/statefulset.yaml

# 5. 创建 Service
echo "[5/5] 创建 Service..."
kubectl apply -f k8s/mysql/service.yaml

# 等待 Pod 就绪
echo ""
echo "等待 MySQL Pod 启动..."
kubectl wait --for=condition=ready pod -l app=mysql --timeout=300s

# 显示状态
echo ""
echo "=========================================="
echo "MySQL 部署状态"
echo "=========================================="
kubectl get pods -l app=mysql
kubectl get svc -l app=mysql

echo ""
echo "=========================================="
echo "MySQL 部署完成！"
echo "=========================================="
echo ""
echo "连接信息："
echo "  ClusterIP: mysql:3306"
echo "  NodePort: <节点IP>:30306"
echo ""
echo "测试连接："
echo "  kubectl run -it --rm mysql-client --image=mysql:8.0 --restart=Never -- mysql -h mysql -uroot -proot"

