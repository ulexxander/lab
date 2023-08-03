
# After server is initialized:
#   make kube-config
# 
resource "hcloud_server" "k3s_server_1" {
  name        = "k3s-server-1"
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
    groups: sudo
    shell: /bin/bash
    lock_passwd: false
    # mkpasswd --method=SHA-512 --rounds=4096
    passwd: "${var.ssh_password_hash}"
    ssh_authorized_keys:
      - ${var.ssh_public_key}

runcmd:
  - curl -sfL https://get.k3s.io > /usr/local/bin/k3s-install.sh
  - chmod +x /usr/local/bin/k3s-install.sh

  - k3s-install.sh
  - chmod 640 /etc/rancher/k3s/k3s.yaml
  - chown root:sudo /etc/rancher/k3s/k3s.yaml

YAML
}
