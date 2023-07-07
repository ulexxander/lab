#
# This is a manual Kubernetes install, it is now automatized with Cloud Init.
#

# Source tutorials:
# https://www.linuxtechi.com/install-kubernetes-on-ubuntu-22-04/
# https://computingforgeeks.com/install-kubernetes-cluster-ubuntu-jammy/?expand_article=1

tee /etc/modules-load.d/kubernetes.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sysctl --system

apt update
# Other packages are already installed.
# apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
apt install -y apt-transport-https

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
apt-add-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt install -y containerd.io

containerd config default | tee /etc/containerd/config.toml > /dev/null
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#systemd-cgroup-driver
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

systemctl restart containerd
# systemctl status containerd

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmour -o /etc/apt/trusted.gpg.d/kubernetes-xenial.gpg
apt-add-repository -y "deb http://apt.kubernetes.io/ kubernetes-xenial main"

apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

kubeadm config images pull

# FOR MASTER
kubeadm init \
  --service-cidr 10.114.0.0/16 \
  --pod-network-cidr 10.115.0.0/16 \
  --upload-certs

# FOR WORKER
kubeadm join 78.47.170.193:6443 --token ??? \
  --discovery-token-ca-cert-hash ???

# LOCALLY
scp root@78.47.170.193:/etc/kubernetes/admin.conf kubectl-admin.conf
export KUBECONFIG=kubectl-admin.conf

wget https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
sed -i 's|"Network": ".*"|"Network": "10.115.0.0/16"|' kube-flannel.yml
kubectl apply -f kube-flannel.yml
