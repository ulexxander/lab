#
# What should be done on Wireguard client, say your laptop.
# When running Wireguard inside Kubernetes cluster.
#
# Source tutorial, including Kube manifests:
# https://www.perdian.de/blog/2022/02/21/setting-up-a-wireguard-vpn-using-kubernetes/

sudo apt install wireguard

wg genkey | sudo tee /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key
sudo chmod 600 /etc/wireguard/private.key /etc/wireguard/public.key

sudo cat /etc/wireguard/public.key # to add on server

sudo tee /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $(sudo cat /etc/wireguard/private.key)
Address = 10.112.32.2/20
PostUp = resolvectl dns %i 10.112.48.10
PostUp = resolvectl domain %i cluster.local

[Peer]
PublicKey = cDrT0WU0z9IqnzrAKMGfn4HSwfqD7InqZbEL0APS8BA=
AllowedIPs = 10.112.0.0/16
Endpoint = 167.235.76.220:51820
EOF

sudo wg-quick down wg0
sudo wg-quick up wg0
# sudo wg

# DNS alternative with systemd-resolved config file:

sudo mkdir -p /etc/systemd/resolved.conf.d

sudo tee /etc/systemd/resolved.conf.d/wireguard.conf <<EOF
[Resolve]
DNS=10.112.48.10
Domains=svc.cluster.local
EOF
sudo systemctl restart systemd-resolved.service
