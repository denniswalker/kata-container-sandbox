#!/usr/bin/env bash
set -ex

echo " ################ PET ############# "

# TODO: Figure out why CRIO is taking precedence over containerd.
containerd config default > /etc/containerd/config.toml

cat <<EOF > /etc/containerd/config.toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.kata]
    runtime_type = "io.containerd.kata.v2"
    privileged_without_host_devices = true
    pod_annotations = ["io.katacontainers.*"]
    container_annotations = ["io.katacontainers.*"]
EOF

cat <<EOF > /etc/crio/crio.conf.d/50-kata.conf
[crio.runtime.runtimes.kata]
    runtime_path = "/usr/bin/containerd-shim-kata-v2"
    runtime_type = "vm"
    runtime_root = "/run/vc"
    privileged_without_host_devices = true
EOF

systemctl restart containerd
systemctl restart crio

/vagrant/stuff_we_have_2.sh # Installs k8s and weave.

# We can label nodes to guarantee scheduling on only certain nodes. This will be useful for UAIs or ARM builds in the future.
cat <<-EOF > /tmp/kata_runtime.yaml
kind: RuntimeClass
apiVersion: node.k8s.io/v1
metadata:
    name: kata
handler: kata
# scheduling:
#   nodeSelector:
#     katacontainers.io/kata-runtime: "true"
EOF

kubectl apply -f /tmp/kata_runtime.yaml

echo " ################ PET Runtime Tests ################## "
 
sleep 30 # Wait a little for the qemu environments and container to spin up.

# Test that kata is a registered runtime of containerd
if [[ $(crictl info | jq '.config.containerd.runtimes.kata' | grep kata) ]]; then
    echo "Kata is configured as a runtime for containerd."
else
    echo "ERROR: Kata is not configured as a runtime for containerd."
    # exit 1
fi

# Test that kata is a registered runtimeclass in k8s.
if [[ $(kubectl get runtimeclass kata) ]]; then
    echo "Kata is configured as a runtimeclass in kubernetes."
else
    echo "ERROR: Kata is not configured as a runtimeclass in kubernetes."
    # exit 1
fi

# Test that kubernetes can spin up kata containers
cat << EOF > /tmp/nginx-kata.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-kata
spec:
  runtimeClassName: kata
  containers:
  - name: nginx
    image: nginx
    
EOF

kubectl apply -f /tmp/nginx-kata.yaml

if [[ $(kubectl get pods nginx-kata | grep Running) ]]; then
    echo "K8s shows the kata container as running."
else
    echo "ERROR: K8s does not show the container as running."
    # exit 1
fi