
output "gateway_public_ip" {
  value = hcloud_server.gateway.ipv4_address
}

output "gateway_private_ip" {
  value = one(hcloud_server.gateway.network).ip
}

output "kube_nodes_private_ips" {
  value = { for node in hcloud_server.kube_nodes : node.name => one(node.network).ip }
}
