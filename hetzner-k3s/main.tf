
resource "hcloud_ssh_key" "k3s" {
  name       = "k3s"
  public_key = var.ssh_public_key
}

# After server is initialized:
#   make kube-config
# 
resource "hcloud_server" "k3s_server_1" {
  name        = "k3s-server-1"
  location    = "nbg1" # Nuremberg, eu-central
  image       = "ubuntu-22.04"
  server_type = "cx31"
  ssh_keys    = [hcloud_ssh_key.k3s.id]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  user_data = <<YAML
#cloud-config

runcmd:
  - curl -sfL https://get.k3s.io > /usr/local/bin/k3s-install.sh
  - chmod +x /usr/local/bin/k3s-install.sh
  - k3s-install.sh

YAML
}
