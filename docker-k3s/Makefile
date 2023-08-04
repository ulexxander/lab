.PHONY: *

k3s-server:
	docker run \
		--privileged \
		--name k3s-server-1 \
		--hostname k3s-server-1 \
		-p 80:80 -p 443:443 -p 6443:6443 \
		-d rancher/k3s:v1.24.10-k3s1 \
		server

kube-config:
	docker cp k3s-server-1:/etc/rancher/k3s/k3s.yaml ~/.kube/config

kube-dashboard-token:
	kubectl -n kube-dashboard create token admin-user
