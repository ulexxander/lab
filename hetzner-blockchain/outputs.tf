
output "bitcoin_core_public_ip" {
  value = hcloud_server.bitcoin_core.ipv4_address
}

output "bitcoin_core_faster_public_ip" {
  value = hcloud_server.bitcoin_core_faster.ipv4_address
}
