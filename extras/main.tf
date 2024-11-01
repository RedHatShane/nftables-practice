# Create new lab Droplet (lab-a) in SF03 region

variable "default" {}
variable "droplets" {}

data "digitalocean_ssh_key" "key" {
  name = var.default.ssh_key_name
}

resource "digitalocean_droplet" "droplets" {
  for_each = var.droplets
  image = var.default.image
  name = each.value
  region = var.default.region
  size = var.default.size
  ssh_keys = [data.digitalocean_ssh_key.key.id]
  user_data = file("${path.module}/cloud-init")
}

data "digitalocean_domain" "default" {
  name = "4cm3.lol"
}

resource "digitalocean_record" "record" {
  for_each = digitalocean_droplet.droplets
  domain = data.digitalocean_domain.default.id
  type = "A"
  name = digitalocean_droplet.droplets[each.key].name
  value = digitalocean_droplet.droplets[each.key].ipv4_address
}
