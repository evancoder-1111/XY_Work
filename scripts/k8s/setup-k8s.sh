#!/bin/bash
# Kubernetes 单节点集群安装脚本
# 支持 minikube 和 k3s 两种方案

set -e

echo "=========================================="
echo "Kubernetes 单节点集群安装"
echo "=========================================="

# 检查是否为 root 用户（k3s 需要，minikube 不需要）
if [ "$EUID" -ne 0 ] && [ "$1" != "minikube" ]; then 
    echo "k3s 安装需要 root 权限，或使用 minikube 方案"
    exit 1
fi

# 选择安装方案
K8S_TYPE=${1:-minikube}

if [ "$K8S_TYPE" = "minikube" ]; then
    echo "使用 minikube 方案安装 Kubernetes..."
    
    # 检查 Docker 是否运行
    if ! systemctl is-active --quiet docker; then
        echo "Docker 未运行，请先运行 scripts/k8s/install-docker.sh"
        exit 1
    fi
    
    # 安装 kubectl
    echo "[1/4] 安装 kubectl..."
    if ! command -v kubectl &> /dev/null; then
        # 使用阿里云 Kubernetes 镜像源
        cat > /etc/yum.repos.d/kubernetes.repo <<'EOF'
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
        yum install -y kubectl
    else
        echo "kubectl 已安装: $(kubectl version --client --short)"
    fi
    
    # 安装 minikube
    echo "[2/4] 安装 minikube..."
    if ! command -v minikube &> /dev/null; then
        # 使用固定版本（避免网络问题）
        MINIKUBE_VERSION="v1.32.0"
        echo "使用固定版本: $MINIKUBE_VERSION"
        echo "下载 minikube（这可能需要一些时间，请耐心等待）..."
        
        # 尝试多个下载源，带超时和进度显示（优先使用阿里云镜像）
        DOWNLOAD_SUCCESS=false
        
        # 方法1：使用 GitHub 代理（ghproxy.com，国内镜像首选）
        echo "尝试从 GitHub 代理下载（国内镜像）..."
        if curl -L --connect-timeout 10 --max-time 300 --progress-bar \
           https://ghproxy.com/https://github.com/kubernetes/minikube/releases/download/${MINIKUBE_VERSION}/minikube-linux-amd64 \
           -o minikube 2>/dev/null && [ -f minikube ] && [ -s minikube ]; then
            DOWNLOAD_SUCCESS=true
            echo "✓ 从 GitHub 代理下载成功"
        fi
        
        # 方法2：使用其他国内镜像（如果方法1失败）
        if [ "$DOWNLOAD_SUCCESS" = false ]; then
            echo "尝试从其他国内镜像下载..."
            if curl -L --connect-timeout 10 --max-time 300 --progress-bar \
               https://mirror.ghproxy.com/https://github.com/kubernetes/minikube/releases/download/${MINIKUBE_VERSION}/minikube-linux-amd64 \
               -o minikube 2>/dev/null && [ -f minikube ] && [ -s minikube ]; then
                DOWNLOAD_SUCCESS=true
                echo "✓ 从国内镜像下载成功"
            fi
        fi
        
        # 方法3：使用其他国内镜像（如果前两个都失败）
        if [ "$DOWNLOAD_SUCCESS" = false ]; then
            echo "尝试从其他国内镜像下载..."
            if curl -L --connect-timeout 10 --max-time 300 --progress-bar \
               https://mirror.ghproxy.com/https://github.com/kubernetes/minikube/releases/download/${MINIKUBE_VERSION}/minikube-linux-amd64 \
               -o minikube 2>/dev/null && [ -f minikube ] && [ -s minikube ]; then
                DOWNLOAD_SUCCESS=true
                echo "✓ 从国内镜像下载成功"
            fi
        fi
        
        # 方法4：使用 GitHub 直接下载（备用）
        if [ "$DOWNLOAD_SUCCESS" = false ]; then
            echo "尝试从 GitHub 直接下载..."
            if curl -L --connect-timeout 10 --max-time 300 --progress-bar \
               https://github.com/kubernetes/minikube/releases/download/${MINIKUBE_VERSION}/minikube-linux-amd64 \
               -o minikube 2>/dev/null && [ -f minikube ] && [ -s minikube ]; then
                DOWNLOAD_SUCCESS=true
                echo "✓ 从 GitHub 下载成功"
            fi
        fi
        
        # 方法5：使用 Google Storage（最后备用）
        if [ "$DOWNLOAD_SUCCESS" = false ]; then
            echo "尝试从 Google Storage 下载..."
            if curl -L --connect-timeout 10 --max-time 300 --progress-bar \
               https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-linux-amd64 \
               -o minikube 2>/dev/null && [ -f minikube ] && [ -s minikube ]; then
                DOWNLOAD_SUCCESS=true
                echo "✓ 从 Google Storage 下载成功"
            fi
        fi
        
        # 检查下载是否成功
        if [ "$DOWNLOAD_SUCCESS" = false ] || [ ! -f minikube ] || [ ! -s minikube ]; then
            echo "✗ minikube 下载失败"
            echo ""
            echo "提示：如果网络无法访问，可以手动下载："
            echo "1. 访问: https://github.com/kubernetes/minikube/releases"
            echo "2. 下载 minikube-linux-amd64"
            echo "3. 复制到 /usr/local/bin/minikube"
            echo "4. 执行: chmod +x /usr/local/bin/minikube"
            echo ""
            echo "或使用 k3s 方案（更轻量，不需要下载 minikube）："
            echo "  sudo bash scripts/k8s/setup-k8s.sh k3s"
            exit 1
        fi
        
        # 设置执行权限并安装
        chmod +x minikube
        mv minikube /usr/local/bin/
        echo "✓ minikube 安装完成"
    else
        echo "minikube 已安装: $(minikube version --short)"
    fi
    
    # 启动 minikube（配置使用阿里云镜像加速）
    echo "[3/4] 启动 minikube（使用阿里云镜像加速）..."
    # 配置 minikube 使用阿里云镜像加速
    minikube config set image-repository registry.cn-hangzhou.aliyuncs.com/google_containers || true
    minikube start --driver=docker --force --image-mirror-country=cn
    
    # 配置 kubectl 上下文
    echo "[4/4] 配置 kubectl 上下文..."
    minikube kubectl -- get nodes
    
    echo ""
    echo "=========================================="
    echo "minikube 安装完成！"
    echo "=========================================="
    echo ""
    echo "使用以下命令验证："
    echo "  kubectl get nodes"
    echo "  kubectl get pods -A"
    echo ""
    echo "使用 minikube 时，使用以下命令："
    echo "  minikube kubectl -- <command>"
    echo "  或设置别名: alias kubectl='minikube kubectl --'"
    
elif [ "$K8S_TYPE" = "k3s" ]; then
    echo "使用 k3s 方案安装 Kubernetes..."
    
    # 安装 k3s（使用国内镜像加速）
    echo "[1/3] 安装 k3s（使用国内镜像）..."
    # 使用镜像加速安装 k3s
    curl -sfL https://get.k3s.io | INSTALL_K3S_MIRROR=cn sh -
    
    # 等待 k3s 启动
    echo "[2/3] 等待 k3s 启动..."
    sleep 10
    
    # 配置 kubectl
    echo "[3/3] 配置 kubectl..."
    mkdir -p ~/.kube
    cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    chmod 600 ~/.kube/config
    
    # 设置 KUBECONFIG 环境变量
    export KUBECONFIG=~/.kube/config
    
    echo ""
    echo "=========================================="
    echo "k3s 安装完成！"
    echo "=========================================="
    echo ""
    echo "使用以下命令验证："
    echo "  kubectl get nodes"
    echo "  kubectl get pods -A"
    echo ""
    echo "注意：请将以下内容添加到 ~/.bashrc 或 ~/.zshrc："
    echo "  export KUBECONFIG=~/.kube/config"
    
else
    echo "错误: 未知的 Kubernetes 类型: $K8S_TYPE"
    echo "用法: $0 [minikube|k3s]"
    exit 1
fi

# 验证集群
echo ""
echo "=========================================="
echo "验证 Kubernetes 集群..."
echo "=========================================="
kubectl get nodes
kubectl get pods -A

echo ""
echo "Kubernetes 集群已就绪！"

