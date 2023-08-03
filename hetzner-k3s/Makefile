.PHONY: *

SSH_OPTS = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null

SRV_1_IP = terraform output -raw k3s_server_1_public_ip

k3s-server-ssh:
	ssh ${SSH_OPTS} $(shell ${SRV_1_IP})

kube-config:
	scp ${SSH_OPTS} $(shell ${SRV_1_IP}):/etc/rancher/k3s/k3s.yaml ~/.kube/config
	sed -i 's|server: .*|server: https://$(shell ${SRV_1_IP}):6443|' ~/.kube/config
