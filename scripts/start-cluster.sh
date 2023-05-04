#!/bin/bash
# Description:   cluster start script
# Company:       Robotnik Automation S.L.
# Creation Year: 2023
# Author:        Guillem Gari <ggari@robotnik.es>
#
#
# Copyright (c) 2023, Robotnik Automation S.L.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the Robotnik Automation S.L.L. nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Robotnik Automation S.L.L.
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

source ~/.cluster-init/environment

if [[ ${USE_VIP} == "true" ]]; then
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
else
  sudo kubeadm init \
  --pod-network-cidr=${CIDR_NET} \
  --apiserver-advertise-address=${MASTER_IP} \
  --control-plane-endpoint ${MASTER_IP}:6443 \
  --cri-socket unix:///var/run/containerd/containerd.sock \
  --upload-certs \
  --apiserver-cert-extra-sans=127.0.0.1,${MASTER_HOSTNAME},${MASTER_IP} || exit 1

fi

mkdir -p $HOME/.kube || exit 1
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config || exit 1
sudo chown $(id -u):$(id -g) $HOME/.kube/config || exit 1

#to allow the master to act as
kubectl taint nodes --all node-role.kubernetes.io/control-plane- || exit 1
if [[ ${CNI_FLAVOR} == "flannel" ]]; then
  kubectl create ns kube-flannel
  kubectl label --overwrite ns kube-flannel pod-security.kubernetes.io/enforce=privileged
  helm repo add flannel https://flannel-io.github.io/flannel/
  helm install flannel --set podCidr="${CIDR_NET}" --namespace kube-flannel flannel/flannel
  # wget \
  # https://raw.githubusercontent.com/flannel-io/flannel/v${FLANNEL_VERSION}/Documentation/kube-flannel.yml
  # sed -i "s#\"Network\": \"10.244.0.0/16\"#\"Network\": \"${CIDR_NET}\"#" kube-flannel.yml
  # kubectl apply -f kube-flannel.yml
fi
if [[ ${CNI_FLAVOR} == "calico" ]]; then
  curl https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/tigera-operator.yaml -O || exit 1
  kubectl create -f tigera-operator.yaml || exit 1
  curl https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/custom-resources.yaml -O

  sed -i "s#cidr: 192.168.0.0/16#cidr: ${CIDR_NET}#" custom-resources.yaml || exit 1
  yq 'select(document_index == 0) | .spec.calicoNetwork.nodeAddressAutodetectionV4.skipInterface = "liqo.*"' custom-resources.yaml> custom-resources.yaml.1
  yq -i '.spec.calicoNodeDaemonSet.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms += [{ "matchExpressions" : [{"key": "liqo.io/type", "operator" : "NotIn", "values": [ "virtual-node"]}] }]' custom-resources.yaml.1
  # yq -i '.spec.CSINodeDriverDaemonSet.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms += [{ "matchExpressions" : [{"key": "liqo.io/type", "operator" : "NotIn", "values": [ "virtual-node"]}] }]' custom-resources.yaml.1
  yq 'select(document_index == 1)' custom-resources.yaml> custom-resources.yaml.2
  rm custom-resources.yaml
  touch custom-resources.yaml
  cat custom-resources.yaml.1>>custom-resources.yaml
  echo "---" >>custom-resources.yaml
  cat custom-resources.yaml.2>>custom-resources.yaml
  rm custom-resources.yaml.1 custom-resources.yaml.2
  kubectl create -f custom-resources.yaml || exit 1
fi
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
echo "Waiting for metallb to start up"
while [ $metallb_replicas -lt 1 ]; do
	metallb_replicas=0
	replicas=$(kubectl get deployments.apps --namespace metallb-system metallb-controller -o json | jq -r ".status.readyReplicas")
	if [[ $replicas =~ [0-9]+ ]]; then
		metallb_replicas=$replicas
	fi
	if [ $metallb_replicas -ge 1 ]; then
		echo "\nMetallb is up"
		sleep 2
		echo "applying metallb configuration"
		if kubectl apply -f metallb-config.yaml; then
			break;
		else
			echo "retry metallb configuration apply"
		fi
	else
		echo -n "."
		sleep 5
	fi
done
liqoctl install kubeadm --cluster-name $CLUSTER_NAME || exit 1
liqoctl generate peer-command