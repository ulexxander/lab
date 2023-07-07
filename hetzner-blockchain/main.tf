
# Sync docker-compose.yaml to server:
#   scp docker-compose.yaml $(terraform output -raw bitcoin_core_public_ip):/deploy
# 
# SSH to server:
#   ssh $(terraform output -raw bitcoin_core_public_ip)
#   cd /deploys
#   docker compose up -d
resource "hcloud_server" "bitcoin_core" {
  name        = "bitcoin-core"
  location    = "nbg1" # Nuremberg, eu-central
  image       = "ubuntu-22.04"
  server_type = "cpx11"
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

write_files:
  - path: /etc/systemd/system/node-exporter.service
    content: |
      [Unit]
      Description=Node Exporter
      After=network.target
      [Service]
      ExecStart=/usr/local/bin/node_exporter
      [Install]
      WantedBy=multi-user.target

runcmd:
  # Install Docker Engine.
  - mkdir -p /etc/apt/keyrings
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  - echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg]
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
  - apt update
  - apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

  # Install Node Exporter.
  - wget -O node_exporter.tar.gz
    "https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz"
  - mkdir node_exporter
  - tar xvf node_exporter.tar.gz -C node_exporter --strip-components=1
  - mv node_exporter/node_exporter /usr/local/bin
  - rm -rf node_exporter node_exporter.tar.gz
  - systemctl enable node-exporter
  - systemctl start node-exporter

  # Create standard directory for deploys.
  - mkdir /deploy
  - chown -R alex:sudo /deploy
  - chmod -R 770 /deploy
  - chmod g+s /deploy
YAML
}
