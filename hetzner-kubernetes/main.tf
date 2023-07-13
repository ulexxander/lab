
# First Kubernetes node is going to be master, others are workers. HA control plane not yet implemented.
# 
# After launching master:
#   make kube-master-ssh
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
#   make kube-config
# And verify again, for your workstation:
#   kubectl get nodes
# 
# Set Terraform variables kube_join_address, kube_join_token, kube_join_ca_cert_hash
# to the values found in /var/log/cloud-init-output.log
# 
# You can now apply your favourite CNI, say Flannel and launch the rest of nodes by increasing kube_nodes_count variable.
resource "hcloud_server" "kube_nodes" {
  count = coalesce(
    var.kube_join_address,
    var.kube_join_token,
    var.kube_join_ca_cert_hash,
    "N/A"
  ) != "N/A" ? var.kube_nodes_count : 1

  name        = "kube-${count.index == 0 ? "master" : "worker"}-${count.index}"
  location    = "nbg1" # Nuremberg, eu-central
  image       = "ubuntu-22.04"
  server_type = "cx21"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
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
    --token-ttl 0
    %{~else~}
    kubeadm join "${coalesce(var.kube_join_address, "N/A")}"
    --token "${coalesce(var.kube_join_token, "N/A")}"
    --discovery-token-ca-cert-hash "${coalesce(var.kube_join_ca_cert_hash, "N/A")}"
    %{~endif~}
YAML

  lifecycle {
    ignore_changes = [user_data]
  }
}

# TODO: optimize if possible easily:
# On master:
#   Cloud-init v. 23.1.2-0ubuntu0~22.04.1 finished at Sun, 09 Jul 2023 14:32:59 +0000. Datasource DataSourceHetzner.
#   Up 86.07 seconds

locals {
  kube_worker_nodes = slice(hcloud_server.kube_nodes, 1, length(hcloud_server.kube_nodes))
}

resource "hcloud_rdns" "kube_workers" {
  for_each = var.kube_workers_public ? { for node in local.kube_worker_nodes : node.name => node } : {}

  server_id  = each.value.id
  ip_address = each.value.ipv4_address
  dns_ptr    = "${each.key}.lab.ulexxander.github.com"
}
