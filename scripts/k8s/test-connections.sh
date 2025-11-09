#!/bin/bash
# 测试数据库连接脚本

set -e

echo "=========================================="
echo "测试数据库连接"
echo "=========================================="

# 检查 kubectl 是否可用
if ! command -v kubectl &> /dev/null; then
    echo "错误: kubectl 未安装或不在 PATH 中"
    exit 1
fi

# 1. 测试 MySQL
echo "[1/3] 测试 MySQL 连接..."
MYSQL_POD=$(kubectl get pod -l app=mysql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$MYSQL_POD" ]; then
    echo "使用 Pod: $MYSQL_POD"
    kubectl exec $MYSQL_POD -- mysql -uroot -proot -e "SELECT VERSION();"
    kubectl exec $MYSQL_POD -- mysql -uroot -proot -e "SHOW DATABASES;"
    echo "✓ MySQL 测试成功"
else
    echo "✗ MySQL Pod 未找到"
fi
echo ""

# 2. 测试 PostgreSQL
echo "[2/3] 测试 PostgreSQL 连接..."
PG_POD=$(kubectl get pod -l app=postgresql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$PG_POD" ]; then
    echo "使用 Pod: $PG_POD"
    kubectl exec $PG_POD -- psql -U postgres -c "SELECT version();"
    kubectl exec $PG_POD -- psql -U postgres -c "\l"
    echo "✓ PostgreSQL 测试成功"
else
    echo "✗ PostgreSQL Pod 未找到"
fi
echo ""

# 3. 测试 Redis
echo "[3/3] 测试 Redis 连接..."
REDIS_MASTER_POD=$(kubectl get pod -l app=redis,role=master -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$REDIS_MASTER_POD" ]; then
    echo "测试主节点: $REDIS_MASTER_POD"
    kubectl exec $REDIS_MASTER_POD -- redis-cli set test-key "test-value"
    kubectl exec $REDIS_MASTER_POD -- redis-cli get test-key
    kubectl exec $REDIS_MASTER_POD -- redis-cli info replication | head -10
    echo "✓ Redis 主节点测试成功"
else
    echo "✗ Redis 主节点 Pod 未找到"
fi

REDIS_SLAVE_POD=$(kubectl get pod -l app=redis,role=slave -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$REDIS_SLAVE_POD" ]; then
    echo "测试从节点: $REDIS_SLAVE_POD"
    kubectl exec $REDIS_SLAVE_POD -- redis-cli get test-key
    kubectl exec $REDIS_SLAVE_POD -- redis-cli info replication | head -10
    echo "✓ Redis 从节点测试成功"
else
    echo "✗ Redis 从节点 Pod 未找到"
fi

echo ""
echo "=========================================="
echo "连接测试完成！"
echo "=========================================="

