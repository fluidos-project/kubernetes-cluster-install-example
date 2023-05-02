source ~/.cluster-init/environment

export KVVERSION=$(curl -sL https://api.github.com/repos/kube-vip/kube-vip/releases | jq -r ".[0].name")

sudo ctr image pull ghcr.io/kube-vip/kube-vip:$KVVERSION || exit 1
sudo ctr run --rm --net-host ghcr.io/kube-vip/kube-vip:$KVVERSION vip /kube-vip \
manifest pod \
    --interface $INTERFACE \
    --address $VIP \
    --controlplane \
    --services \
    --arp \
    --leaderElection | sudo tee /etc/kubernetes/manifests/kube-vip.yaml || exit 1
sudo kubeadm init \
--pod-network-cidr=${CIDR_NET} \
--apiserver-advertise-address=${MASTER_IP} \
--control-plane-endpoint ${VIP}:6443 \
--cri-socket unix:///var/run/containerd/containerd.sock \
--upload-certs \
--apiserver-cert-extra-sans=127.0.0.1,${MASTER_HOSTNAME},${MASTER_IP} || exit 1

mkdir -p $HOME/.kube || exit 1
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config || exit 1
sudo chown $(id -u):$(id -g) $HOME/.kube/config || exit 1

#to allow the master to act as
kubectl taint nodes --all node-role.kubernetes.io/control-plane- || exit 1

curl https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/tigera-operator.yaml -O || exit 1
kubectl create -f tigera-operator.yaml || exit 1
curl https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/custom-resources.yaml -O
sed -i "s#cidr: 192.168.0.0/16#cidr: ${CIDR_NET}#" custom-resources.yaml || exit 1
yq 'select(document_index == 0) | .spec.calicoNetwork.nodeAddressAutodetectionV4.skipInterface = "liqo.*"' custom-resources.yaml> custom-resources.yaml.1
yq 'select(document_index == 1)' custom-resources.yaml> custom-resources.yaml.2
echo "---" >custom-resources.yaml
cat custom-resources.yaml.1>>custom-resources.yaml
echo "---" >>custom-resources.yaml
cat custom-resources.yaml.2>>custom-resources.yaml
rm custom-resources.yaml.1 custom-resources.yaml.2
kubectl create -f custom-resources.yaml || exit 1
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ || exit 1
helm install --set 'args={--kubelet-insecure-tls}' --namespace kube-system metrics metrics-server/metrics-server || exit 1
helm repo add metallb https://metallb.github.io/metallb || exit 1
helm install --create-namespace --namespace metallb-system metallb metallb/metallb || exit 1


cat <<EOF > metallb-config.yaml
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
    - ${METALLB_IP_POD}
  autoAssign: true
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool

EOF
metallb_replicas=0
while [ $metallb_replicas -lt 1 ]; do

	metallb_replicas=0
	replicas=$(kubectl get deployments.apps --namespace metallb-system metallb-controller -o json | jq -r ".status.readyReplicas")
	if [[ $replicas =~ [0-9]+ ]]; then
		metallb_replicas=$replicas
	fi
	if [ $metallb_replicas -ge 1 ]; then
		echo "Metallb is up"
		sleep 5
		echo "applying metallb configuration"
		if kubectl apply -f metallb-config.yaml; then
			break;
		else
			echo "retry metallb configuration apply"
		fi
	else
		echo "Waiting for metallb to start up"
		sleep 5
	fi
done
liqoctl install kubeadm --cluster-name $CLUSTER_NAME || exit 1
liqoctl generate peer-command