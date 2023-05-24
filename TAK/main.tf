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

provider "zerotier" {
  zerotier_central_token = var.zerotier_central_token
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
variable "zerotier_central_token" {}

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

# FIREWALL
resource "digitalocean_firewall" "otak-firewall" {
  name = "otak-firewall"

  droplet_ids = [digitalocean_droplet.mainserver.id]

  inbound_rule {
    protocol = "icmp"
    source_addresses = ["10.147.19.0/24"]
  }
  
  inbound_rule {
    protocol = "tcp"
    port_range = "1-65535"
    source_addresses = ["10.147.19.0/24"]
  }
  
  inbound_rule {
    protocol = "udp"
    port_range = "1-65535"
    source_addresses = ["10.147.19.0/24"]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
}