#
# Private network are being used on Hetzner.
# Kubernetes nodes have private IP and they need some gateway with public IP
# so they can connect to the Internet.
# We are using other Hetzner VM that will serve as a NAT gateway.
#

# https://community.hetzner.com/tutorials/how-to-set-up-nat-for-cloud-networks

# ON NAT INSTANCE
sudo iptables -t nat -I POSTROUTING -s 10.112.1.0/24 -o eth0 -j MASQUERADE
# iptables -t nat -D POSTROUTING -s 10.112.1.0/24 -o eth0 -j MASQUERADE

# ON PRIVATE INSTANCE
ip route add default via 10.112.0.1

sudo tee /etc/systemd/resolved.conf <<EOF
[Resolve]
DNS=185.12.64.2 185.12.64.1
EOF

sudo systemctl restart systemd-resolved.service
# resolvectl status
