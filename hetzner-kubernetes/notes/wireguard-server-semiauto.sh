#
# After Wireguard install is automatized with Cloud Init
# you need to only add each peer (client) manually.
#

ssh $(terraform output -raw gateway_public_ip)

# sudo systemctl status wg-quick@wg0.service
# sudo wg-quick up wg0
# sudo wg-quick down wg0

sudo wg set wg0 \
  peer sEXpkB3LPt7PSi+AKYXjhgZCZZmN+eFM8sNFc3tx4VI= \
  allowed-ips 10.112.32.2
# sudo wg

# sudo wg set wg0 \
#   peer b8ew1S0Z53kl0gWWeit4p73S9vigcHDZKAWaYW81aws= remove
