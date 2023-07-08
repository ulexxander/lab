.PHONY: *

WORKER = 1

gateway-public-ssh:
	ssh $(shell terraform output -raw gateway_public_ip)

gateway-private-ssh:
	ssh $(shell terraform output -raw gateway_private_ip)

kube-master-ssh:
	ssh $(shell terraform output -json kube_nodes_private_ips | jq -r '."kube-master-0"')

kube-worker-ssh:
	ssh $(shell terraform output -json kube_nodes_private_ips | jq -r '."kube-worker-${WORKER}"')

# Prior to running this command don't forget to copy kube config to your home on master node.
kube-config:
	scp $(shell terraform output -json kube_nodes_private_ips | jq -r '."kube-master-0"'):~/.kube/config ~/.kube/config
