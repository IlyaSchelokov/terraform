# Add rebrain_key

data "digitalocean_ssh_key" "rebrain-key" {
  name = "REBRAIN.SSH.PUB.KEY"
}

# Add my_ssh_key

resource "digitalocean_ssh_key" "my_key" {
  name       = "my_public_key"
  public_key = "${var.public_key}"
}


# Create VM

resource "digitalocean_droplet" "VM" {
  image  = "ubuntu-20-04-x64"
  name   = "VM"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
ssh_keys = [data.digitalocean_ssh_key.rebrain-key.fingerprint, digitalocean_ssh_key.my_key.fingerprint]
tags = [var.label, var.email]
}
