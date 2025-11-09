#!/bin/bash
# Docker CE 安装脚本
# 功能：安装 Docker CE，配置镜像加速，验证安装

set -e

echo "=========================================="
echo "Docker CE 安装开始"
echo "=========================================="

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echo "请使用 root 用户运行此脚本"
    exit 1
fi

# 1. 卸载旧版本 Docker（如果存在）
echo "[1/5] 卸载旧版本 Docker..."
yum remove -y docker docker-client docker-client-latest docker-common \
    docker-latest docker-latest-logrotate docker-logrotate docker-engine 2>/dev/null || true

# 2. 添加 Docker 仓库（使用阿里云镜像）
echo "[2/5] 添加 Docker 仓库（阿里云镜像）..."
# 使用阿里云 Docker 仓库镜像
cat > /etc/yum.repos.d/docker-ce.repo <<'EOF'
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
EOF
yum makecache fast

# 3. 安装 Docker CE
echo "[3/5] 安装 Docker CE..."
yum install -y docker-ce docker-ce-cli containerd.io

# 4. 配置 Docker
echo "[4/5] 配置 Docker..."

# 创建 Docker 配置目录
mkdir -p /etc/docker

# 配置 Docker 镜像加速（使用阿里云镜像）
cat > /etc/docker/daemon.json <<EOF
{
  "registry-mirrors": [
    "https://registry.cn-hangzhou.aliyuncs.com",
    "https://docker.mirrors.ustc.edu.cn"
  ],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# 启动 Docker 并设置开机自启
systemctl daemon-reload
systemctl enable docker

# 如果 Docker 已经在运行，需要重启以使镜像加速器配置生效
if systemctl is-active --quiet docker; then
    echo "重启 Docker 以使镜像加速器配置生效..."
    systemctl restart docker
else
    systemctl start docker
fi

# 等待 Docker 启动完成
sleep 5

# 5. 配置用户权限
echo "[5/5] 配置用户权限..."
# 将当前用户（如果不是 root）加入 docker 组
if [ -n "$SUDO_USER" ]; then
    usermod -aG docker $SUDO_USER
    echo "用户 $SUDO_USER 已加入 docker 组"
elif [ "$USER" != "root" ]; then
    usermod -aG docker $USER
    echo "用户 $USER 已加入 docker 组"
fi

# 验证 Docker 安装
echo ""
echo "=========================================="
echo "验证 Docker 安装..."
echo "=========================================="
docker --version
docker info | head -20

# 测试 Docker 运行（可选，失败不影响安装）
echo ""
echo "测试 Docker 运行..."
if docker run --rm hello-world 2>/dev/null; then
    echo "✓ Docker 测试成功"
else
    echo "⚠ Docker 测试失败（可能是网络问题，不影响 Docker 安装）"
    echo "提示：如果无法访问 Docker Hub，请检查："
    echo "  1. 网络连接是否正常"
    echo "  2. 镜像加速器配置是否正确（已配置阿里云和 USTC 镜像）"
    echo "  3. 防火墙是否阻止了连接"
    echo ""
    echo "Docker 已成功安装，可以继续后续步骤"
fi

echo ""
echo "=========================================="
echo "Docker CE 安装完成！"
echo "=========================================="
echo ""
echo "注意：如果当前用户不是 root，请重新登录以使 docker 组权限生效"
echo "下一步：运行 scripts/k8s/setup-k8s.sh 安装 Kubernetes"

