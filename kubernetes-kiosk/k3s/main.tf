
# After apply:
#   make k3s-server-ssh
#   sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
#   sudo chown alex:alex ~/.kube/config
# 
resource "hcloud_server" "k3s_server" {
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
    groups: sudo, docker
    shell: /bin/bash
    lock_passwd: false
    # mkpasswd --method=SHA-512 --rounds=4096
    passwd: "${var.password_hash}"
    ssh_authorized_keys:
      - ${var.ssh_public_key}
YAML

  lifecycle {
    ignore_changes = [user_data]
  }
}
