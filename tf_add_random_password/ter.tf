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

resource "random_password" "password" {
  count = var.number_of_servers
  length           = 10
}


resource "digitalocean_droplet" "vm" {
  count = var.number_of_servers
  image  = "ubuntu-20-04-x64"
  name   = "VM.${count.index}"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
ssh_keys = [data.digitalocean_ssh_key.rebrain_key.fingerprint, digitalocean_ssh_key.my_key.fingerprint]
tags = [var.label, var.email]



connection {
    type     = "ssh"
    user     = var.login
    agent = false
    private_key = file("${var.private_key}")
    host     = self.ipv4_address
  }



provisioner "remote-exec" {
    inline = ["echo 'root:${element(random_password.password[*].result, count.index)}' | chpasswd"]
  }
}


locals {
resolv_ip = digitalocean_droplet.vm[*].ipv4_address
}


data "aws_route53_zone" "primary" {
  name = "devops.rebrain.srwx.net"
}


resource "aws_route53_record" "training_zone" {
  count = var.number_of_servers
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "shelokov_ilya-${count.index}"
  type    = "A"
  ttl     = 300
  records = [element(local.resolv_ip, count.index)]

}


output "password" {
  value = [for s in random_password.password[*].result : nonsensitive(s)]
}


