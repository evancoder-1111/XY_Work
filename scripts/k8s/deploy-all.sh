#!/bin/bash
# 一键部署所有数据库服务脚本

set -e

echo "=========================================="
echo "一键部署所有数据库服务"
echo "=========================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查 kubectl 是否可用
if ! command -v kubectl &> /dev/null; then
    echo "错误: kubectl 未安装或不在 PATH 中"
    exit 1
fi

# 1. 准备存储
echo "[1/4] 准备存储..."
bash $SCRIPT_DIR/prepare-storage.sh

# 2. 部署 MySQL
echo ""
echo "[2/4] 部署 MySQL..."
bash $SCRIPT_DIR/deploy-mysql.sh

# 3. 部署 PostgreSQL
echo ""
echo "[3/4] 部署 PostgreSQL..."
bash $SCRIPT_DIR/deploy-postgresql.sh

# 4. 部署 Redis
echo ""
echo "[4/4] 部署 Redis..."
bash $SCRIPT_DIR/deploy-redis.sh

# 5. 验证所有服务
echo ""
echo "=========================================="
echo "验证所有服务..."
echo "=========================================="
bash $SCRIPT_DIR/verify-all.sh

echo ""
echo "=========================================="
echo "所有数据库服务部署完成！"
echo "=========================================="

