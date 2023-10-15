
output "server_public_ip" {
  value = hcloud_server.docker_infra.ipv4_address
}
