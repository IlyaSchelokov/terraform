# Add rebrain_key

data "digitalocean_ssh_key" "rebrain_key" {
  name = "REBRAIN.SSH.PUB.KEY"
}

# Add my_ssh_key

resource "digitalocean_ssh_key" "my_key" {
  name       = "my_public_key"
  public_key = var.public_key
}


# Create VM

resource "digitalocean_droplet" "vm" {
  image  = "ubuntu-20-04-x64"
  name   = "VM"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
ssh_keys = [data.digitalocean_ssh_key.rebrain_key.fingerprint, digitalocean_ssh_key.my_key.fingerprint]
tags = [var.label, var.email]
}

locals {
resolv_ip = digitalocean_droplet.vm.ipv4_address
}


data "aws_route53_zone" "primary" {
  name = "devops.rebrain.srwx.net"
}


resource "aws_route53_record" "training_zone" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "shelokov_ilya.devops.rebrain.srwx.net"
  type    = "A"
  ttl     = 300
  records = [local.resolv_ip]
}


