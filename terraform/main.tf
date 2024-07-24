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
  source = "github.com/goryszewski/terraform_module/libvirt/network"
  domain = var.domain
  addresses = var.node_addresses
  name = var.name_network
  mode = var.mode_network

}

module "node" {

  for_each = var.hosts
  source   = "github.com/goryszewski/terraform_module/libvirt/domain"
  domain   = var.domain
  hostname = each.key
  tags     = each.value["tags"]
  memoryMB = each.value["memoryMB"]
  network  = module.network.id
  public_network = var.public_network
  template = var.template
}
