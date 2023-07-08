
variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "ssh_public_key" {
  type = string
}

variable "password_hash" {
  type        = string
  description = "Generated with 'mkpasswd --method=SHA-512 --rounds=4096'"
}

variable "kube_nodes_count" {
  type        = number
  description = <<TEXT
Desired count of master nodes.
If "kube_join_address", "kube_join_token" and "kube_join_ca_cert_hash" are empty, only one will be created.
To create the rest you first need to SSH to the first master node and obtain those values.
TEXT
}

variable "kube_workers_public" {
  type        = bool
  default     = false
  description = "Whether Kubernetes worker nodes have public IPs. But control plane will always stay in the private network."
}

variable "kube_join_address" {
  type    = string
  default = null
}

variable "kube_join_token" {
  type    = string
  default = null
}

variable "kube_join_ca_cert_hash" {
  type    = string
  default = null
}
