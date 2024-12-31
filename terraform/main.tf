provider "libvirt" {
  uri = var.qemu_url
}

# provider "libvirtapi" {
#   hostname = "http://127.0.0.1:8050"
#   username = "test"
#   password = "test"
# }

terraform {
  required_version = ">= 1.0.1"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"

    }
    # libvirtapi = {
    #   source = "github.com/goryszewski/libvirtApi"
    # }
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
  pool     = var.pool
  tags     = each.value["tags"]
  memoryMB = each.value["memoryMB"]
  network  = module.network.id
  public_network = var.public_network
  template = var.template
}

# resource "libvirtapi_loadbalancer" "lbApi" {
#   name = "k8sapi"
# 	namespace= "terraform"
#   nodes = [{
#     name = "master01"
#     ip = module.node["master01"].external[0]
#   },
#   {
#     name = "master02"
#     ip = module.node["master02"].external[0]
#   }
#   ]
#   ports = [
#   {
#     name = "api"
#     protocol = "tcp"
#     port = "6443"
#     nodeport = "6443"
#   }
#   ]
# }
