# Add rebrain_key

data "digitalocean_ssh_key" "rebrain_key" {
  name = "REBRAIN.SSH.PUB.KEY"
}

# Add my_ssh_key

resource "digitalocean_ssh_key" "my_key" {
  name       = "my_public_key"
  public_key = var.public_key
}


# Create password

resource "random_password" "password" {
  count = "${length(var.devs)}"
  length           = 10
}

# Create VM

resource "digitalocean_droplet" "vm" {
  count = "${length(var.devs)}"
  image  = "ubuntu-20-04-x64"
  name   = "${element(var.devs, count.index)}"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
ssh_keys = [data.digitalocean_ssh_key.rebrain_key.fingerprint, digitalocean_ssh_key.my_key.fingerprint]
tags = [var.label, var.email]



connection {
    type     = "ssh"
    user     = var.login
    agent = false
    private_key = file(var.private_key)
    host     = self.ipv4_address
  }



provisioner "remote-exec" {
    inline = ["echo 'root:${random_password.password[count.index].result}' | chpasswd"]
  }
}


# Create DNS

data "aws_route53_zone" "primary" {
  name = "devops.rebrain.srwx.net"
}


resource "aws_route53_record" "training_zone" {
  count = "${length(var.devs)}"
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "${element(var.devs, count.index)}"
  type    = "A"
  ttl     = 300
  records = [local.resolv_ip[count.index]]
}

# Create template

resource "local_file" "template" {
  content  = templatefile("template.tftpl",
  
  {
  dns_name = aws_route53_record.training_zone[*].fqdn,
  ip_address = digitalocean_droplet.vm[*].ipv4_address,
  root_pass = random_password.password[*].result})
  
  filename = "${path.module}/localfile"
}


