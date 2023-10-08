.PHONY: *

SERVER := 78.47.78.121

sh:
	ssh root@${SERVER}

up:
	rsync -r . root@${SERVER}:/deploy
	ssh root@${SERVER} "cd /deploy && docker compose up -d"
