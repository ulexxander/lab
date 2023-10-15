
variable "ssh_key_id" {
  type = string
}

variable "hcloud_token" {
  type      = string
  sensitive = true
}
