#!/bin/bash
# 存储准备脚本
# 功能：创建数据目录、StorageClass 和 PersistentVolume

set -e

echo "=========================================="
echo "准备 Kubernetes 存储"
echo "=========================================="

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echo "请使用 root 用户运行此脚本"
    exit 1
fi

# 1. 创建数据目录
echo "[1/3] 创建数据目录..."
mkdir -p /data/mysql
mkdir -p /data/postgresql
mkdir -p /data/redis/master
mkdir -p /data/redis/slave-0
mkdir -p /data/redis/slave-1

# 2. 设置目录权限
echo "[2/3] 设置目录权限..."
chmod -R 755 /data
chown -R 999:999 /data/mysql      # MySQL 容器用户
chown -R 999:999 /data/postgresql  # PostgreSQL 容器用户
chown -R 999:999 /data/redis        # Redis 容器用户

# 3. 创建 StorageClass 和 PV
echo "[3/3] 创建 StorageClass 和 PersistentVolume..."
kubectl apply -f k8s/storage/storageclass.yaml
kubectl apply -f k8s/storage/pv.yaml

# 验证
echo ""
echo "=========================================="
echo "验证存储配置..."
echo "=========================================="
kubectl get storageclass
kubectl get pv

echo ""
echo "=========================================="
echo "存储准备完成！"
echo "=========================================="

