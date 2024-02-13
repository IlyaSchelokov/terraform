locals {
resolv_ip = digitalocean_droplet.vm[*].ipv4_address
}
