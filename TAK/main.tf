# PROVIDER INFORMATION
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    zerotier = {
      source = "zerotier/zerotier"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

resource "zerotier_network" "otak-network" {
  name        = "OTAK"
  description = "OTAK VPN"
  assignment_pool {
    start = "10.147.19.1"
    end   = "10.147.19.254"
  }
  route {
    target = "10.147.19.0/24"
  }
  flow_rules = <<EOF
  drop
    not ethertype ipv4
    and not ethertype arp
    and not ethertype ipv6
  ;
  accept;
  EOF
}

# KEYS/TOKENS
data "digitalocean_ssh_keys" "keys" {}
variable "digitalocean_token" {}
variable "private_key_path" {
  description = "Absolute path to private key. For example: /home/user/.ssh/id_rsa"
  type        = string
}

# DROPLETS
resource "digitalocean_droplet" "mainserver" {
  name     = "mainserver"
  image    = "ubuntu-22-04-x64"
  size     = "s-4vcpu-8gb"
  region   = "nyc3"
  ssh_keys = data.digitalocean_ssh_keys.keys.ssh_keys.*.id
  tags     = ["droplet", "mainserver", ]
  user_data = file("post-terraform.yml")
}