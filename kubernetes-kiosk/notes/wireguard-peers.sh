
# On kube-master cloud init add:
# - apt-get update
# - apt-get install -y wireguard
# - wg genkey | tee /etc/wireguard/private.key | wg pubkey | tee /etc/wireguard/public.key
# - chmod 600 /etc/wireguard/private.key /etc/wireguard/public.key

# - |
#   tee /etc/wireguard/wg0.conf <<EOF
#   [Interface]
#   PrivateKey = $(cat /etc/wireguard/private.key)
#   Address = 10.112.32.${count.index + 1}/20
#   ListenPort = 51820
#   EOF

# - systemctl enable wg-quick@wg0.service
# - systemctl start wg-quick@wg0.service

# On kube-master after booted
wg set wg0 \
  peer +QU6s4UFmYbdExpYKgeLv6scLQVHpwQ+XWQS5jmFKVI= \
  allowed-ips 10.112.32.100

echo "KUBELET_EXTRA_ARGS=--node-ip=10.112.32.1 --resolv-conf=/etc/resolv.conf" | tee /etc/default/kubelet

# https://github.com/hobby-kube/guide#initializing-the-master-node

tee /etc/kubernetes/kubeadm.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 10.112.32.1
  bindPort: 6443

---
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
networking:
  serviceSubnet: 10.112.48.0/20
  podSubnet: 10.112.64.0/20
EOF

kubeadm init \
  --config /etc/kubernetes/kubeadm.yaml \
  --upload-certs

# On kube-kiosk
wg set wg0 \
  peer f9/JQh9AP4NBWOfeBR/rwOw1x5EHQJOMSOGU6RqiHEc= \
  allowed-ips 10.112.32.0/20 \
  endpoint 23.88.53.89:51820

echo "KUBELET_EXTRA_ARGS=--node-ip=10.112.32.100" | tee /etc/default/kubelet
# systemctl restart kubelet

kubeadm join 10.112.32.1:6443 --token ??? \
        --discovery-token-ca-cert-hash ???

# On your workstation
wg set wg0 \
  peer f9/JQh9AP4NBWOfeBR/rwOw1x5EHQJOMSOGU6RqiHEc= \
  allowed-ips 10.112.32.0/20 \
  endpoint 23.88.53.89:51820

# On each node to fix service routing.
# ip route add 10.112.48.0/20 dev wg0 src 10.112.32.100
# https://stackoverflow.com/questions/47845739/configuring-flannel-to-use-a-non-default-interface-in-kubernetes
# https://mayankshah.dev/blog/demystifying-kube-proxy/

# PROBLEM TO SOLVE ON KIOSKS:
# WRONG NET CONFIG INSIDE CONTAINER:
# bash-5.1# ip a
# 2: eth0@if10: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default 
#     link/ether ce:c0:30:ad:7e:16 brd ff:ff:ff:ff:ff:ff link-netnsid 0
#     inet 10.112.65.5/24 brd 10.112.65.255 scope global eth0
#        valid_lft forever preferred_lft forever
#     inet6 fe80::ccc0:30ff:fead:7e16/64 scope link 
#        valid_lft forever preferred_lft forever
# bash-5.1# ip route
# default via 10.112.65.1 dev eth0 
# 10.112.64.0/20 via 10.112.65.1 dev eth0 
# 10.112.65.0/24 dev eth0 proto kernel scope link src 10.112.65.5 
