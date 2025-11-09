#!/bin/bash
# 部署应用到 Kubernetes 脚本

set -e

echo "=========================================="
echo "部署应用到 Kubernetes"
echo "=========================================="

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 检查 kubectl 是否可用
if ! command -v kubectl &> /dev/null; then
    echo "错误: kubectl 未安装或不在 PATH 中"
    exit 1
fi

cd "$PROJECT_ROOT"

# 部署后端
echo ""
echo "[1/2] 部署后端应用..."
kubectl apply -f k8s/app/backend/configmap.yaml
kubectl apply -f k8s/app/backend/secret.yaml
kubectl apply -f k8s/app/backend/deployment.yaml
kubectl apply -f k8s/app/backend/service.yaml
echo "✓ 后端应用部署完成"

# 部署前端
echo ""
echo "[2/2] 部署前端应用..."
kubectl apply -f k8s/app/frontend/configmap.yaml
kubectl apply -f k8s/app/frontend/deployment.yaml
kubectl apply -f k8s/app/frontend/service.yaml
echo "✓ 前端应用部署完成"

# 等待部署完成
echo ""
echo "等待应用启动..."
kubectl wait --for=condition=available --timeout=300s deployment/xy-portal-backend
kubectl wait --for=condition=available --timeout=300s deployment/xy-portal-frontend

echo ""
echo "=========================================="
echo "应用部署完成！"
echo "=========================================="
echo ""
echo "查看服务状态："
echo "  kubectl get pods -l 'app in (xy-portal-backend,xy-portal-frontend)'"
echo ""
echo "访问应用："
echo "  后端: http://<节点IP>:30080"
echo "  前端: http://<节点IP>:30081"
echo ""

