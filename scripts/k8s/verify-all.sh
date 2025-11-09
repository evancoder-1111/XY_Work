#!/bin/bash
# 验证所有数据库服务脚本

set -e

echo "=========================================="
echo "验证所有数据库服务"
echo "=========================================="

# 检查 kubectl 是否可用
if ! command -v kubectl &> /dev/null; then
    echo "错误: kubectl 未安装或不在 PATH 中"
    exit 1
fi

# 1. 检查所有 Pod 状态
echo "[1/4] 检查 Pod 状态..."
echo ""
echo "--- MySQL Pods ---"
kubectl get pods -l app=mysql
echo ""
echo "--- PostgreSQL Pods ---"
kubectl get pods -l app=postgresql
echo ""
echo "--- Redis Pods ---"
kubectl get pods -l app=redis
echo ""

# 检查是否有失败的 Pod
FAILED_PODS=$(kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded --no-headers 2>/dev/null | wc -l)
if [ "$FAILED_PODS" -gt 0 ]; then
    echo "警告: 发现 $FAILED_PODS 个非运行状态的 Pod"
    kubectl get pods --all-namespaces --field-selector=status.phase!=Running,status.phase!=Succeeded
fi

# 2. 检查所有 Service
echo "[2/4] 检查 Service..."
echo ""
kubectl get svc -l 'app in (mysql,postgresql,redis)'
echo ""

# 3. 检查 PVC 状态
echo "[3/4] 检查 PersistentVolumeClaim 状态..."
echo ""
kubectl get pvc
echo ""

# 4. 测试连接
echo "[4/4] 测试数据库连接..."
echo ""

# 测试 MySQL
echo "--- 测试 MySQL 连接 ---"
MYSQL_POD=$(kubectl get pod -l app=mysql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$MYSQL_POD" ]; then
    if kubectl exec $MYSQL_POD -- mysqladmin ping -h localhost -uroot -proot > /dev/null 2>&1; then
        echo "✓ MySQL 连接成功"
    else
        echo "✗ MySQL 连接失败"
    fi
else
    echo "✗ MySQL Pod 未找到"
fi

# 测试 PostgreSQL
echo "--- 测试 PostgreSQL 连接 ---"
PG_POD=$(kubectl get pod -l app=postgresql -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$PG_POD" ]; then
    if kubectl exec $PG_POD -- pg_isready -U postgres > /dev/null 2>&1; then
        echo "✓ PostgreSQL 连接成功"
    else
        echo "✗ PostgreSQL 连接失败"
    fi
else
    echo "✗ PostgreSQL Pod 未找到"
fi

# 测试 Redis 主节点
echo "--- 测试 Redis 主节点连接 ---"
REDIS_MASTER_POD=$(kubectl get pod -l app=redis,role=master -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$REDIS_MASTER_POD" ]; then
    if kubectl exec $REDIS_MASTER_POD -- redis-cli ping > /dev/null 2>&1; then
        echo "✓ Redis 主节点连接成功"
    else
        echo "✗ Redis 主节点连接失败"
    fi
else
    echo "✗ Redis 主节点 Pod 未找到"
fi

# 测试 Redis 从节点
echo "--- 测试 Redis 从节点连接 ---"
REDIS_SLAVE_POD=$(kubectl get pod -l app=redis,role=slave -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$REDIS_SLAVE_POD" ]; then
    if kubectl exec $REDIS_SLAVE_POD -- redis-cli ping > /dev/null 2>&1; then
        echo "✓ Redis 从节点连接成功"
    else
        echo "✗ Redis 从节点连接失败"
    fi
else
    echo "✗ Redis 从节点 Pod 未找到"
fi

# 5. 验证数据库初始化
echo ""
echo "[5/6] 验证数据库初始化..."
echo ""

# 验证 MySQL 数据库
echo "--- 验证 MySQL 数据库 ---"
if [ -n "$MYSQL_POD" ]; then
    DB_EXISTS=$(kubectl exec $MYSQL_POD -- mysql -uroot -proot -e "SHOW DATABASES LIKE 'xy_portal';" 2>/dev/null | grep -c xy_portal || echo "0")
    if [ "$DB_EXISTS" -gt 0 ]; then
        echo "✓ MySQL 数据库 'xy_portal' 已创建"
        TABLE_COUNT=$(kubectl exec $MYSQL_POD -- mysql -uroot -proot xy_portal -e "SHOW TABLES;" 2>/dev/null | wc -l || echo "0")
        if [ "$TABLE_COUNT" -gt 1 ]; then
            echo "✓ MySQL 表已创建 ($((TABLE_COUNT-1)) 个表)"
        else
            echo "⚠ MySQL 表未创建或为空"
        fi
    else
        echo "⚠ MySQL 数据库 'xy_portal' 未创建"
    fi
else
    echo "✗ 无法验证 MySQL 数据库（Pod 未找到）"
fi

# 验证 PostgreSQL 数据库
echo "--- 验证 PostgreSQL 数据库 ---"
if [ -n "$PG_POD" ]; then
    DB_EXISTS=$(kubectl exec $PG_POD -- psql -U postgres -tAc "SELECT 1 FROM pg_database WHERE datname='xy_portal';" 2>/dev/null || echo "0")
    if [ "$DB_EXISTS" = "1" ]; then
        echo "✓ PostgreSQL 数据库 'xy_portal' 已创建"
    else
        echo "⚠ PostgreSQL 数据库 'xy_portal' 未创建"
    fi
else
    echo "✗ 无法验证 PostgreSQL 数据库（Pod 未找到）"
fi

# 6. 验证 Redis 主从复制
echo ""
echo "[6/6] 验证 Redis 主从复制..."
echo ""

if [ -n "$REDIS_MASTER_POD" ] && [ -n "$REDIS_SLAVE_POD" ]; then
    # 在主节点设置测试键
    kubectl exec $REDIS_MASTER_POD -- redis-cli set verify-replication "test-value-$(date +%s)" > /dev/null 2>&1
    
    # 等待复制
    sleep 2
    
    # 在从节点读取
    SLAVE_VALUE=$(kubectl exec $REDIS_SLAVE_POD -- redis-cli get verify-replication 2>/dev/null || echo "")
    if [ -n "$SLAVE_VALUE" ]; then
        echo "✓ Redis 主从复制正常"
        # 清理测试键
        kubectl exec $REDIS_MASTER_POD -- redis-cli del verify-replication > /dev/null 2>&1
    else
        echo "✗ Redis 主从复制异常（从节点未同步数据）"
    fi
    
    # 显示复制信息
    echo "--- Redis 主节点复制信息 ---"
    kubectl exec $REDIS_MASTER_POD -- redis-cli info replication | grep -E "role|connected_slaves" || true
    echo ""
    echo "--- Redis 从节点复制信息 ---"
    kubectl exec $REDIS_SLAVE_POD -- redis-cli info replication | grep -E "role|master_host|master_port|master_link_status" || true
else
    echo "✗ 无法验证 Redis 主从复制（Pod 未找到）"
fi

echo ""
echo "=========================================="
echo "验证完成！"
echo "=========================================="

