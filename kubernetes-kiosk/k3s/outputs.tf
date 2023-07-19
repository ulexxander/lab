
output "k3s_server_public_ip" {
  value = hcloud_server.k3s_server.ipv4_address
}
