.PHONY: *

# Before SSH over VPN is bootstrapped:
# SRV_ADDR = $(shell terraform output -raw server_public_ip)

# After SSH over VPN is possible:
SRV_ADDR = docker-infra.ulexxander.tailnet.local

sh:
	ssh root@${SRV_ADDR}

sync:
	rsync -r ./deploy/* root@${SRV_ADDR}:/deploy

up: sync
	ssh root@${SRV_ADDR} "cd /deploy && docker compose up -d"
