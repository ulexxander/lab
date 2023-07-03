# K8S narodni

## Hetzner Cloud CLI

```sh
# Install Hetzner Cloud CLI.
# https://github.com/hetznercloud/cli
wget https://github.com/hetznercloud/cli/releases/download/v1.36.0/hcloud-linux-amd64.tar.gz
tar xvf hcloud-linux-amd64.tar.gz hcloud
chmod +x hcloud
sudo mv hcloud /usr/local/bin
rm hcloud-linux-amd64.tar.gz

# Configure Hetzner Cloud CLI.
hcloud version
# Replace "Lab" with your project name.
# It will ask you for API token.
# Create in Hetzner Cloud Console: your project / Security / API tokens
hcloud context create Lab
# Test configuration.
hcloud server-type list
# BTW, hcloud CLI stores token in $HOME/.config/hcloud/cli.toml
```

## Terraform

[Install Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
