# Alex Lab

No comments, just experiments.

![It works](./it-works.gif)

## Hetzner Kubernetes

Located in [hetzner-kubernetes](./hetzner-kubernetes/main.tf) directory.

- [Hetzner Cloud API Docs](https://docs.hetzner.cloud)
- [hetznercloud/cli | GitHub](https://github.com/hetznercloud/cli)
- [hetznercloud/hcloud | Terraform Registry](https://registry.terraform.io/providers/hetznercloud/hcloud/latest)
- [kubeadm init Docs](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/)
- [CIDR.xyz](https://cidr.xyz/)

### Hetzner Cloud CLI

```sh
# Install Hetzner Cloud CLI.
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
# BTW, hcloud CLI stores token in $HOME/.config/hcloud/cli.toml
hcloud server-type list
# Install autocompletion.
hcloud completion bash | sudo tee /etc/bash_completion.d/hcloud
```

### Terraform

[Install Terraform | HashiCorp Developer](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### Kubectl

```sh
# Install Kubectl.
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin
# Install autocompletion.
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl

# Test installation.
kubectl version
```

## Hetzner Blockchain

| Blockchain | Node         | Scheme    | CPU | RAM | Disk   | Download    | Upload       |
| ---------- | ------------ | --------- | --- | --- | ------ | ----------- | ------------ |
| Bitcoin    | Bitcoin Core | Full Node | 2 ? | 4 ? | 350 GB | 15 GB/month | 150 GB/month |

### Bitcoin Core setup

- [ruimarinho/bitcoin-core](https://hub.docker.com/r/ruimarinho/bitcoin-core)
- [Scaling Bitcoin Node with Kubernetes | Tigran.tech](https://tigran.tech/scaling-bitcoin-node-with-kubernetes/)
- [Requirements and Warnings - Bitcoin Core](https://bitcoin.org/en/bitcoin-core/features/requirements)
