
# 10.112.0.0/16 - EU CENTRAL
#   10.112.16.0/20 - SERVERS
#   10.112.32.0/20 - VPN
#   10.112.48.0/20 - KUBE SERVICES
#   10.112.64.0/20 - KUBE PODS

resource "hcloud_network" "eu_central" {
  name     = "eu-central"
  ip_range = "10.112.0.0/16"
}

resource "hcloud_network_subnet" "eu_central_servers" {
  network_id   = hcloud_network.eu_central.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.112.16.0/20"
}

resource "hcloud_server" "gateway" {
  name        = "gateway"
  location    = "nbg1" # Nuremberg, eu-central
  image       = "ubuntu-22.04"
  server_type = "cx21"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
  network {
    network_id = hcloud_network.eu_central.id
  }

  user_data = <<YAML
#cloud-config

users:
  - name: alex
    groups: sudo, docker
    shell: /bin/bash
    lock_passwd: false
    # mkpasswd --method=SHA-512 --rounds=4096
    passwd: "${var.password_hash}"
    ssh_authorized_keys:
      - ${var.ssh_public_key}

runcmd:
  - apt-get update
  - apt-get install -y wireguard

  - |
    tee /etc/sysctl.d/wireguard.conf <<EOF
    net.ipv4.ip_forward = 1
    EOF
  
  - sysctl --system
  
  - wg genkey | tee /etc/wireguard/private.key | wg pubkey | tee /etc/wireguard/public.key
  - chmod 600 /etc/wireguard/private.key /etc/wireguard/public.key
  
  - |
    tee /etc/wireguard/wg0.conf <<EOF
    [Interface]
    PrivateKey = $(cat /etc/wireguard/private.key)
    Address = 10.112.32.1/20
    ListenPort = 51820
    SaveConfig = true
    PostUp = iptables -t nat -I POSTROUTING -s 10.112.16.0/20 -o eth0 -j MASQUERADE
    PostUp = iptables -t nat -I POSTROUTING -s 10.112.32.0/20 -o enp7s0 -j MASQUERADE
    PreDown = iptables -t nat -D POSTROUTING -s 10.112.16.0/20 -o eth0 -j MASQUERADE
    PreDown = iptables -t nat -D POSTROUTING -s 10.112.32.0/20 -o enp7s0 -j MASQUERADE
    EOF

  - systemctl enable wg-quick@wg0.service
  - systemctl start wg-quick@wg0.service
YAML

  lifecycle {
    ignore_changes = [network]
  }
  depends_on = [hcloud_network_subnet.eu_central_servers]
}

# TODO: "-s 10.112.16.0/20 -o eth0" (internet NAT) should be enabled separately by other systemd service.
# Don't abuse wg PostUp :)

resource "hcloud_network_route" "gateway" {
  network_id  = hcloud_network.eu_central.id
  destination = "0.0.0.0/0"
  gateway     = one(hcloud_server.gateway.network).ip
}

# First Kubernetes node is going to be master, others are workers. HA control plane not yet implemented.
# 
# After launching master, SSH to it using its private IP (assuming your VPN is up) and:
#   ssh $(terraform output -json kube_nodes_private_ips | jq -r '."kube-master-0"')
#   sudo tail /var/log/cloud-init-output.log -n 30
# 
# If initialization succeeded, it should coutain something like this:
#   Your Kubernetes control-plane has initialized successfully!
# 
# Follow those instructions in output:
#   To start using your cluster, you need to run the following as a regular user:
#     mkdir -p $HOME/.kube
#     sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#     sudo chown $(id -u):$(id -g) $HOME/.kube/config
# 
# Verify by running on the node:
#   kubectl get nodes
#
# Transfer kubeconfig to your workstation:
#   scp $(terraform output -json kube_nodes_private_ips | jq -r '."kube-master-0"'):~/.kube/config ~/.kube/config
# And verify again, for your workstation:
#   kubectl get nodes
# 
# Set Terraform variables kube_join_address, kube_join_token, kube_join_ca_cert_hash
# to the values found in /var/log/cloud-init-output.log
# 
# You can now apply your favourite CNI, say Flannel and launch the rest of nodes by increasing kube_nodes_count variable.
resource "hcloud_server" "kube_nodes" {
  count = var.kube_join_address != null && var.kube_join_token != null && var.kube_join_ca_cert_hash != null ? var.kube_nodes_count : 1

  name        = "kube-${count.index == 0 ? "master" : "worker"}-${count.index}"
  location    = "nbg1" # Nuremberg, eu-central
  image       = "ubuntu-22.04"
  server_type = "cx21"
  public_net {
    ipv4_enabled = count.index != 0 && var.kube_workers_public
    ipv6_enabled = false
  }
  network {
    network_id = hcloud_network.eu_central.id
  }

  user_data = <<YAML
#cloud-config

users:
  - name: alex
    groups: sudo, docker
    shell: /bin/bash
    lock_passwd: false
    # mkpasswd --method=SHA-512 --rounds=4096
    passwd: "${var.password_hash}"
    ssh_authorized_keys:
      - ${var.ssh_public_key}

write_files:
  - path: /etc/systemd/system/ip-route-default-private-gateway.service
    content: |
      [Unit]
      Description=IP Route to Default Gateway
      After=network.target
      [Service]
      ExecStart=ip route add default via 10.112.0.1
      [Install]
      WantedBy=multi-user.target
  - path: /etc/systemd/resolved.conf
    content: |
      [Resolve]
      DNS=185.12.64.2 185.12.64.1

runcmd:
  %{~if count.index == 0 || !var.kube_workers_public~}
  - systemctl start ip-route-default-private-gateway
  - systemctl enable ip-route-default-private-gateway
  %{~endif~}

  - systemctl restart systemd-resolved.service

  - |
    tee /etc/modules-load.d/kubernetes.conf <<EOF
    overlay
    br_netfilter
    EOF

  - modprobe overlay
  - modprobe br_netfilter

  - |
    tee /etc/sysctl.d/kubernetes.conf <<EOF
    net.bridge.bridge-nf-call-ip6tables = 1
    net.bridge.bridge-nf-call-iptables = 1
    net.ipv4.ip_forward = 1
    EOF

  - sysctl --system

  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  - |
    tee /etc/apt/sources.list.d/docker.list <<EOF
    deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
    EOF
  - apt-get update
  - apt-get install -y containerd.io

  - containerd config default | tee /etc/containerd/config.toml > /dev/null
  - sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
  - systemctl restart containerd

  - curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
  - |
    tee /etc/apt/sources.list.d/kubernetes.list <<EOF
    deb [arch=amd64 signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main
    EOF
  - apt-get update
  - apt-get install -y kubelet kubeadm kubectl
  - apt-mark hold kubelet kubeadm kubectl

  - kubeadm config images pull

  - >-
    %{~if count.index == 0~}
    kubeadm init
    --service-cidr 10.112.48.0/20
    --pod-network-cidr 10.112.64.0/20
    --upload-certs
    %{else}
    kubeadm join "${coalesce(var.kube_join_address, "N/A")}"
    --token "${coalesce(var.kube_join_token, "N/A")}"
    --discovery-token-ca-cert-hash "${coalesce(var.kube_join_ca_cert_hash, "N/A")}"
    %{~endif~}
YAML

  lifecycle {
    ignore_changes = [network]
  }
  depends_on = [hcloud_network_route.gateway]
}
