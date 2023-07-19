.PHONY: *

k3s-server-ssh:
	ssh $(shell terraform output -raw k3s_server_public_ip)

# Prior to running this command don't forget to copy kube config
# to your home directory on the server node, by SSH'ing there.
kube-config:
	scp $(shell terraform output -raw k3s_server_public_ip):~/.kube/config ~/.kube/config
	sed -i 's|server: .*|server: https://$(shell terraform output -raw k3s_server_public_ip):6443|' ~/.kube/config

kube-dashboard-token:
	kubectl -n kubernetes-dashboard create token admin-user
