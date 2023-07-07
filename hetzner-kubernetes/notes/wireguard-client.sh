#
# What should be done on Wireguard client, say your laptop.
#

sudo apt install wireguard

wg genkey | sudo tee /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key
sudo chmod 600 /etc/wireguard/private.key /etc/wireguard/public.key

sudo tee /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $(sudo cat /etc/wireguard/private.key)
Address = 10.112.32.2/20

[Peer]
PublicKey = 0KydIx+KR9OVotDF2ccayNCDq2PJ0DKh/9tHI4bNgBw=
AllowedIPs = 10.112.0.0/16
Endpoint = $(terraform output -raw gateway_public_ip):51820
EOF

sudo cat /etc/wireguard/public.key # to add on server

sudo wg-quick up wg0
# sudo wg
# ip route get 10.113.1.2
# sudo wg-quick down wg0
