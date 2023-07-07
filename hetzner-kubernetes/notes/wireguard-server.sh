# 
# Manual install of Wireguard on server (VM).
# Now automatized for the most part with Cloud init.
# 

ssh $(terraform output -raw gateway_public_ip)

# https://www.digitalocean.com/community/tutorials/how-to-set-up-wireguard-on-ubuntu-22-04

sudo tee /etc/sysctl.d/wireguard.conf <<EOF
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

sudo apt install wireguard

wg genkey | sudo tee /etc/wireguard/private.key
# sudo chmod go= /etc/wireguard/private.key
sudo chmod 600 /etc/wireguard/private.key

sudo cat /etc/wireguard/private.key | wg pubkey | sudo tee /etc/wireguard/public.key
# chmod?

sudo tee /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $(sudo cat /etc/wireguard/private.key)
Address = 10.113.1.1/24
ListenPort = 51820
SaveConfig = true
PostUp = iptables -t nat -I POSTROUTING -s 10.112.16.0/24 -o enp7s0 -j MASQUERADE
PreDown = iptables -t nat -D POSTROUTING -s 10.112.16.0/24 -o enp7s0 -j MASQUERADE
EOF

sudo tee /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $(sudo cat /etc/wireguard/private.key)
Address = 10.112.16.2/24
ListenPort = 51820
SaveConfig = true
EOF

# https://www.cyberciti.biz/faq/how-to-set-up-wireguard-firewall-rules-in-linux/

sudo systemctl enable wg-quick@wg0.service
sudo systemctl start wg-quick@wg0.service
# sudo systemctl status wg-quick@wg0.service
# sudo wg-quick down wg0
# sudo wg-quick up wg0

sudo wg set wg0 \
  peer sEXpkB3LPt7PSi+AKYXjhgZCZZmN+eFM8sNFc3tx4VI= \
  allowed-ips 10.112.16.3
# sudo wg

# sudo wg set wg0 \
#   peer b8ew1S0Z53kl0gWWeit4p73S9vigcHDZKAWaYW81aws= remove
