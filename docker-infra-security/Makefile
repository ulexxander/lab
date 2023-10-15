.PHONY: *

SRV_IP = terraform output -raw server_public_ip

sh:
	ssh root@$(shell ${SRV_IP})

sync:
	rsync -r ./deploy/* root@$(shell ${SRV_IP}):/deploy

up: sync
	ssh root@$(shell ${SRV_IP}) "cd /deploy && docker compose up -d"
