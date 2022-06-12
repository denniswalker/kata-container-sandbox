#!/usr/bin/env bash
set -ex

zypper -n install \
    containerd \
    kubernetes1.20-kubeadm \
    cri-tools \
    containerd-ctr \
    tmux \
    jq

# Install Kubectl
if [[ ! $(which kubectl) ]]; then
    cd /tmp
    curl -LO curl -LO https://dl.k8s.io/release/v1.20.13/bin/linux/amd64/kubectl
    chmod +x kubectl
    chown vagrant kubectl
    mv kubectl /usr/bin
fi

mkdir -p /etc/systemd/system/kubelet.service.d
cat <<EOF > /etc/systemd/system/kubelet.service.d/0-cri-containerd.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=--container-runtime=remote --runtime-request-timeout=15m --container-runtime-endpoint=unix:///run/containerd/containerd.sock"
EOF

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF