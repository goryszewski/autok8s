terraform {
  required_version = ">= 1.0.1"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"

    }
  }
}

resource "libvirt_volume" "image" {
  name   = "${var.hostname}-image"
  pool   = var.pool
  source = var.template
  format = "qcow2"
}



resource "libvirt_domain" "node" {
  name   = "${var.hostname}.${var.domain}"
  memory = var.memoryMB
  vcpu   = var.cpu
  description = join("_", var.tags)
  autostart = false
  disk {
    volume_id = libvirt_volume.image.id
  }
  network_interface {

    network_id     = var.network
    hostname       = var.hostname
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = "true"
  }

  connection {
    type     = "ssh"
    user     = var.user
    private_key = "${file("~/.ssh/id_rsa")}"
    timeout = "2m"
    host     = self.network_interface[0].addresses[0]
  }

  provisioner "file" {
    source      = "${path.module}/files/prep.sh"
    destination = "/tmp/prep.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod a+x /tmp/prep.sh",
      "sudo /tmp/prep.sh ${var.hostname}"
    ]
  }
  provisioner "local-exec" {
    command = "${path.module}/files/local.sh ${self.network_interface[0].addresses[0]} ${var.hostname}.${var.domain}"
    on_failure = continue
  }
}
