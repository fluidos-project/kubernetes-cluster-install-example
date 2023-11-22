sudo rm -f \
  /etc/cni/net.d/10-calico.conflist \
  /etc/cni/net.d/calico-kubeconfig \
  /etc/cni/net.d/10-flannel.conflist
sudo kubeadm reset --force
sudo ifconfig cni0 dow
sudo ip link delete cni0