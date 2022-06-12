#!/usr/bin/env bash
set -ex

systemctl enable kubelet.service

cat <<EOF > /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
EOF

cat <<EOF > /tmp/kubeadm_config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: pr49kd.b12sx5ulfhkdnct9
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
localAPIEndpoint:
  advertiseAddress: 10.0.2.15
  bindPort: 6443
nodeRegistration:
  criSocket: /run/containerd/containerd.sock
  name: localhost
  taints:
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
apiServer:
  timeoutForControlPlane: 4m0s
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kubernetesVersion: v1.20.13
networking:
  dnsDomain: cluster.local
  serviceSubnet: 10.96.0.0/12
scheduler: {}

EOF

if [[ ! $(kubectl get nodes) ]]; then
# Apply sysctl params without reboot
    sysctl --system
    kubeadm init --config /tmp/kubeadm_config.yaml
fi

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

echo "Wait for weave to come up."
timeout_dns=420

while [ "$timeout_dns" -gt 0 ]; do
  if sudo -E kubectl get pods --all-namespaces | grep dns | grep Running; then
    break
  fi
  sleep 1s
  ((timeout_dns--))
done

if [[ $(kubectl get nodes -o=custom-columns=NAME:.metadata.name,TAINTS:.spec.taints | grep master) ]]; then
  kubectl taint nodes --all node-role.kubernetes.io/master-
fi

echo "Setting up access to kubectl by the default user"
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/config
chown vagrant /home/vagrant/config