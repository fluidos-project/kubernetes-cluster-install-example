# kubernetes install

kubernetes installation guideline

## Operative system installation

### Ubuntu 22.04 server

1. Update the installer

2. Select Openssh server and allow password

3. Upgrade packages
   
   ```bash
   sudo apt update
   DEBIAN_FRONTEND=noninteractive sudo apt upgrade -y
   sudo reboot
   ```

## System tune for Kubernetes

### Disable swap

```bash
sudo sed -i 's#^/swap.img#\#/swap.img#' /etc/fstab
sudo swapoff -a
```

### Configure required modules

First, load two modules in the current running environment and configure them to load on boot

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

### Configure required sysctl to persist across system reboots

```bash
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```

### Apply sysctl parameters without rebooting to current running environment

```bash
sudo sysctl --system
```

### Install containerd

```bash
sudo apt install -y \
    gnupg2 \
    apt-transport-https
```

```bash
curl -sS https://download.docker.com/linux/ubuntu/gpg |\
     gpg --dearmor | \
     sudo tee /usr/share/keyrings/docker.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/docker.gpg arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
sudo apt install containerd.io -y
```
