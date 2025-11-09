#!/bin/bash
# CentOS 7 环境准备脚本
# 功能：系统更新、工具安装、防火墙和SELinux配置

set -e

echo "=========================================="
echo "CentOS 7 环境准备开始"
echo "=========================================="

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echo "请使用 root 用户运行此脚本"
    exit 1
fi

# 1. 配置国内 yum 镜像源（阿里云）
echo "[1/7] 配置国内 yum 镜像源..."
if [ ! -f /etc/yum.repos.d/CentOS-Base.repo.backup ]; then
    # 备份原有源
    cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup 2>/dev/null || true
    
    # 使用阿里云镜像源
    cat > /etc/yum.repos.d/CentOS-Base.repo <<'EOF'
[base]
name=CentOS-$releasever - Base - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/$releasever/os/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7

[updates]
name=CentOS-$releasever - Updates - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/$releasever/updates/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7

[extras]
name=CentOS-$releasever - Extras - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos/$releasever/extras/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-7
EOF
    echo "✓ 已配置阿里云 yum 镜像源"
else
    echo "✓ yum 镜像源已配置，跳过"
fi

# 清理并更新 yum 缓存
yum clean all
yum makecache

# 2. 系统更新
echo "[2/7] 更新系统包..."
yum update -y

# 3. 安装必要工具
echo "[3/7] 安装必要工具..."
yum install -y vim wget curl net-tools git yum-utils device-mapper-persistent-data lvm2

# 4. 系统资源检查
echo "[4/7] 检查系统资源..."
echo "--- 内存信息 ---"
free -h
echo "--- 磁盘空间 ---"
df -h
echo "--- CPU 信息 ---"
lscpu | grep -E "^CPU\(s\)|^Thread|^Core"

# 检查资源是否足够
TOTAL_MEM=$(free -g | awk '/^Mem:/{print $2}')
AVAILABLE_DISK=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//')

if [ "$TOTAL_MEM" -lt 4 ]; then
    echo "警告: 内存不足 4GB，建议至少 4GB 内存"
fi

# 5. 配置防火墙
echo "[5/7] 配置防火墙..."
systemctl start firewalld
systemctl enable firewalld

# 开放必要端口
firewall-cmd --permanent --add-port=22/tcp      # SSH
firewall-cmd --permanent --add-port=6443/tcp    # Kubernetes API
firewall-cmd --permanent --add-port=10250/tcp   # Kubelet
firewall-cmd --permanent --add-port=30000-32767/tcp  # NodePort 范围
firewall-cmd --permanent --add-port=2379-2380/tcp   # etcd
firewall-cmd --permanent --add-port=10259/tcp    # kube-scheduler
firewall-cmd --permanent --add-port=10257/tcp    # kube-controller-manager
firewall-cmd --reload

echo "防火墙规则已配置"

# 6. 配置 SELinux
echo "[6/7] 配置 SELinux..."
# 设置为 permissive 模式（允许但记录违规）
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config

echo "SELinux 已设置为 permissive 模式"

# 7. 禁用 swap（Kubernetes 要求）
echo "[7/7] 禁用 swap..."
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "=========================================="
echo "CentOS 7 环境准备完成！"
echo "=========================================="
echo ""
echo "下一步："
echo "1. 运行 scripts/k8s/install-docker.sh 安装 Docker"
echo "2. 或运行 scripts/k8s/setup-k8s.sh 安装 Docker 和 K8s"

