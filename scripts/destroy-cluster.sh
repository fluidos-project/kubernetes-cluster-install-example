sudo rm -f \
  /etc/cni/net.d/10-calico.conflist \
  /etc/cni/net.d/calico-kubeconfig \
  /etc/cni/net.d/10-flannel.conflist
sudo kubeadm reset --force