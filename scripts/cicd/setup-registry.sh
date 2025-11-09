#!/bin/bash
# 部署本地 Docker Registry 脚本

set -e

echo "=========================================="
echo "部署本地 Docker Registry"
echo "=========================================="

# 检查 kubectl 是否可用
if ! command -v kubectl &> /dev/null; then
    echo "错误: kubectl 未安装或不在 PATH 中"
    exit 1
fi

# 创建命名空间（如果不存在）
kubectl create namespace registry --dry-run=client -o yaml | kubectl apply -f -

# 创建 Registry Deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: docker-registry
  namespace: registry
spec:
  replicas: 1
  selector:
    matchLabels:
      app: docker-registry
  template:
    metadata:
      labels:
        app: docker-registry
    spec:
      containers:
      - name: registry
        image: registry:2
        ports:
        - containerPort: 5000
        volumeMounts:
        - name: registry-storage
          mountPath: /var/lib/registry
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
      volumes:
      - name: registry-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: docker-registry
  namespace: registry
spec:
  type: ClusterIP
  ports:
  - port: 5000
    targetPort: 5000
    protocol: TCP
    name: registry
  selector:
    app: docker-registry
---
apiVersion: v1
kind: Service
metadata:
  name: docker-registry-nodeport
  namespace: registry
spec:
  type: NodePort
  ports:
  - port: 5000
    targetPort: 5000
    nodePort: 30500
    protocol: TCP
    name: registry
  selector:
    app: docker-registry
EOF

echo ""
echo "等待 Registry 启动..."
kubectl wait --for=condition=available --timeout=300s deployment/docker-registry -n registry

echo ""
echo "=========================================="
echo "Registry 部署完成！"
echo "=========================================="
echo ""
echo "Registry 地址："
echo "  ClusterIP: docker-registry.registry.svc.cluster.local:5000"
echo "  NodePort: <节点IP>:30500"
echo ""
echo "配置 Docker 使用本地 Registry（在节点上执行）："
echo "  sudo mkdir -p /etc/docker"
echo "  echo '{\"insecure-registries\": [\"192.168.2.75:30500\"]}' | sudo tee /etc/docker/daemon.json"
echo "  sudo systemctl restart docker"
echo ""

