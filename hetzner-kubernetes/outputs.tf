
output "kube_nodes_public_ips" {
  value = { for node in hcloud_server.kube_nodes : node.name => node.ipv4_address }
}
