provider "libvirt" {
  uri = var.qemu_url
}

terraform {
  required_version = ">= 1.0.1"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"

    }
  }
}

module "network" {
  source = "./modules/network"
  domain = var.domain
  addresses = var.node_addresses
  name = var.name_network
  mode = var.mode_network

}

module "node" {

  for_each = var.hosts
  source   = "./modules/domain"
  domain   = var.domain
  hostname = each.key
  tags     = each.value["tags"]
  network  = module.network.id
  template = each.value["template"]
}
