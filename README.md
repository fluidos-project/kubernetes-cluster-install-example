# Kubernetes install

Installing kubernetes cluster (single node) with the following:
- ubuntu 22.04 server
- kubeadm
- kubectl
- kubelet
- helm
- k9s

Inside kubernetes:
- Kube-vip (for multimaster)
- Metric-server
- Flannel or (calico)
- Metallb
- liqo

## Cloud Init setup
```bash
git clone git@github.com:RobotnikAutomation/kubernetes-install.git
checkout devel
cd kubernetes-install
```

## Cloud init configuration server
- Start the http server on the remote machine
```bash
git clone git@github.com:RobotnikAutomation/kubernetes-install.git
checkout devel
cd kubernetes-install
cd www/
python3 -m http.server 3003
```

## Method 1: grub edit

### Installation
1. Burn the image on a pendrive
2. Run the cloud init http server on the remote machine
3. Ensure that machine you are going to install has ethernet connection with dhcp
4. Boot the machine with the pendrive
5. Press e when the grub enter
6. Change the line to `linux /casper/vmlinuz autoinstall ip=dhcp ds=nocloud-net\;s=http://192.168.20.165:3003/edge1/ -- net.ifnames=0 biosdevname=0`
7. Press F10
5. Wait thill the installation is over
6. Remove the pendrive
7. restart the machine
8. Wait till cloud init runs all the first boot commands

## Method 2: livefs-editor
### install livefs-editor
```bash
https://github.com/mwhudson/livefs-editor.git
cd livefs
livefs-editor
sudo su
python -m pip install .
exit
```
### Download ubuntu 22.04 server image
```bash
cd iso/
../scripts/download-ubuntu-iso.sh
```
### Patch image
```bash
#edit your url accordingly where your http will be
cloud_init_url=http://192.168.20.165:3003/edge/
sed -i "s#http://192.168.20.165:3003/edge/#${cloud_init_url}#" actions.yaml
sudo livefs-edit $(ls ubuntu-*-*.iso | tail -n1) rob-ci-$(ls ubuntu-*-*.iso | tail -n1) --action-yaml actions.yaml
```
### Installation
1. Burn the image on a pendrive
2. Run the cloud init http server on the remote machine
3. Ensure that machine you are going to install has ethernet connection with dhcp
4. Boot the machine with the pendrive
5. Wait thill the installation is over
6. Remove the pendrive
7. restart the machine
8. Wait till cloud init runs all the first boot commands


## Kubernetes cluster startup

- Log in to the machine
- edit the file `.cluster-init/environment` accordingly with your need and ip ranges
- execute the following command
```bash
.cluster-init/start-cluster.sh
```
## Kubernetes cluster destroy
- execute the following command
```bash
.cluster-init/destroy-cluster.sh
```