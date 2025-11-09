#!/bin/bash
# 构建应用镜像脚本

set -e

echo "=========================================="
echo "构建应用镜像"
echo "=========================================="

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 配置
# 默认使用本地 Registry，如果服务器 IP 不同，请修改此处
REGISTRY="${REGISTRY:-192.168.2.75:30500}"
BACKEND_IMAGE="${REGISTRY}/xy-portal-backend:latest"
FRONTEND_IMAGE="${REGISTRY}/xy-portal-frontend:latest"

cd "$PROJECT_ROOT"

# 构建后端镜像
echo ""
echo "[1/2] 构建后端镜像..."
cd backend/XY_Portal
docker build -t "$BACKEND_IMAGE" .
echo "✓ 后端镜像构建完成: $BACKEND_IMAGE"

# 构建前端镜像
echo ""
echo "[2/2] 构建前端镜像..."
cd "$PROJECT_ROOT/frontend/XY_Portal_Frontend"
docker build -t "$FRONTEND_IMAGE" .
echo "✓ 前端镜像构建完成: $FRONTEND_IMAGE"

# 推送镜像
echo ""
echo "推送镜像到 Registry..."
docker push "$BACKEND_IMAGE"
docker push "$FRONTEND_IMAGE"
echo "✓ 镜像推送完成"

echo ""
echo "=========================================="
echo "镜像构建完成！"
echo "=========================================="
echo ""
echo "后端镜像: $BACKEND_IMAGE"
echo "前端镜像: $FRONTEND_IMAGE"
echo ""

