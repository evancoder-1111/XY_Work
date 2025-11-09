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
        cat > /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
        yum install -y kubectl
    else
        echo "kubectl 已安装: $(kubectl version --client --short)"
    fi
    
    # 安装 minikube
    echo "[2/4] 安装 minikube..."
    if ! command -v minikube &> /dev/null; then
        MINIKUBE_VERSION=$(curl -s https://api.github.com/repos/kubernetes/minikube/releases/latest | grep tag_name | cut -d '"' -f 4)
        curl -Lo minikube https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-linux-amd64
        chmod +x minikube
        mv minikube /usr/local/bin/
    else
        echo "minikube 已安装: $(minikube version --short)"
    fi
    
    # 启动 minikube
    echo "[3/4] 启动 minikube..."
    minikube start --driver=docker --force
    
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
    
    # 安装 k3s
    echo "[1/3] 安装 k3s..."
    curl -sfL https://get.k3s.io | sh -
    
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

