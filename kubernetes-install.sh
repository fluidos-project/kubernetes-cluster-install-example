#!/bin/bash
sudo apt update
DEBIAN_FRONTEND=noninteractive sudo apt upgrade -y
sudo apt install -y \
    gnupg2 \
    apt-transport-https
curl -sS https://download.docker.com/linux/ubuntu/gpg |\
     gpg --dearmor | \
     sudo tee /usr/share/keyrings/docker.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/docker.gpg arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo sed -i 's#^/swap.img#\#/swap.img#' /etc/fstab
sudo swapoff -a
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

sudo apt update
export K8S_VERSION="1.26.3-00"
sudo apt install -y \
    containerd.io \
    kubeadm="${K8S_VERSION}" \
    kubelet="${K8S_VERSION}" \
    kubectl="${K8S_VERSION}"
sudo apt-mark hold kubelet kubeadm kubectl

sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

kubeadm completion bash | sudo tee /etc/bash_completion.d/kubeadm &>/dev/null
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl &>/dev/null
helm completion bash | sudo tee /etc/bash_completion.d/helm &>/dev/null
source <(kubeadm completion bash)
source <(kubectl completion bash)
source <(helm completion bash)