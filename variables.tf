
variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type = string
}

variable "ssh_public_key" {
  description = "Public Key to be registred in hcloud"
  type = string
}

variable "ssh_private_key" {
  description = "Private Key to registered hcloud private key"
  type = string
}

variable "server_count" {
  description = "Count of apache VMs"
  type        = number
  default     = 2
}

variable "resource_location" {
  description = "Datacenter where servers and loadbalancer are placed (e.g. hel1, nbg1)"
  type = string
  default = "hel1"
}

variable "subdomain_name_cloudserver" {
  description = "Subdomain Name for Cloudserver"
  type = string
}

variable "cf_api_token" {
  description = "Cloudflare API Token"
  type = string
}

variable "cf_zone_id" {
  description = "Cloudflare Zone ID"
  type = string
}
variable "domain_name" {
  description = "domain name"
  type = string
}
variable "subdomain_name_load_balancer" {
  description = "Subdomain Name for loadbalancer"
  type = string
}
