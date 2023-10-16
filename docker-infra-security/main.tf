
data "hcloud_ssh_key" "this" {
  id = var.ssh_key_id
}

resource "hcloud_server" "docker_infra" {
  name        = "docker-infra"
  location    = "nbg1" # Nuremberg, eu-central
  image       = "ubuntu-22.04"
  server_type = "cx21"
  ssh_keys    = [data.hcloud_ssh_key.this.id]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  user_data = <<YAML
#cloud-config

runcmd:
  # Install Docker Engine.
  - mkdir -p /etc/apt/keyrings
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  - echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg]
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
  - apt update
  - apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
YAML
}

resource "hcloud_firewall" "docker_infra" {
  name = "docker-infra"

  # SSH is possible only via VPN (headscale / tailscale).
  # rule {
  #   description = "SSH"
  #   direction   = "in"
  #   protocol    = "tcp"
  #   port        = "22"
  #   source_ips  = ["0.0.0.0/0"]
  # }

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
}

resource "hcloud_firewall_attachment" "docker_infra" {
  firewall_id = hcloud_firewall.docker_infra.id
  server_ids  = [hcloud_server.docker_infra.id]
}
