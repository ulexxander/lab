
variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "ssh_public_key" {
  type = string
}

variable "ssh_password_hash" {
  type        = string
  description = "Generated with 'mkpasswd --method=SHA-512 --rounds=4096'"
}

variable "home_external_ip_cidr" {
  type        = string
  description = "Obtain with 'curl ifconfig.me'"
}
