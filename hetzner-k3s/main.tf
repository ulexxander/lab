
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

resource "hcloud_firewall" "k3s_servers" {
  name = "k3s-servers"

  rule {
    description = "HTTP Ingress"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = ["0.0.0.0/0"]
  }
  rule {
    description = "HTTPS Ingress"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips  = ["0.0.0.0/0"]
  }
  rule {
    description = "Ping"
    direction   = "in"
    protocol    = "icmp"
    source_ips  = ["0.0.0.0/0"]
  }
  rule {
    description = "Kubernetes API from home"
    direction   = "in"
    protocol    = "tcp"
    port        = "6443"
    source_ips  = ["${var.home_external_ip_cidr}/32"]
  }
  rule {
    description = "SSH from home"
    direction   = "in"
    protocol    = "tcp"
    port        = 22
    source_ips  = ["${var.home_external_ip_cidr}/32"]
  }
}

resource "hcloud_firewall_attachment" "k3s_servers" {
  firewall_id = hcloud_firewall.k3s_servers.id
  server_ids  = [hcloud_server.k3s_server_1.id]
}
