
output "k3s_server_1_public_ip" {
  value = hcloud_server.k3s_server_1.ipv4_address
}
