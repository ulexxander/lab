.PHONY: *

IMAGE = lab-firefox

build:
	docker build -t "${IMAGE}" .

xhost-allow:
	xhost +local:root

xhost-deny:
	xhost -

run:
	docker run -it --rm \
		--volume /tmp/.X11-unix:/tmp/.X11-unix \
		--env DISPLAY \
		"${IMAGE}"

save:
	docker save "${IMAGE}" -o "${IMAGE}.tar"

# Need to be run with sudo on node.
import:
	ctr -n k8s.io images import --base-name ${IMAGE} "${IMAGE}.tar"

debian-kde-iso:
	wget https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/debian-live-12.0.0-amd64-kde.iso

