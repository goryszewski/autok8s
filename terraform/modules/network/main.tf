terraform {
  required_version = ">= 1.0.1"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"

    }
  }
}

resource "libvirt_network" "default" {
  name      = var.name
  mode      = var.mode
  domain    = var.domain
  addresses = var.addresses
  autostart = false
    dns {

    enabled = true
    }
}

