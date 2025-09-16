variable "domain" {
  type    = string
}

variable "hosts" {
  type = map
}

variable "node_addresses" {
  type = list(string)
  default = ["10.17.3.0/24"]
}

variable "pool" {
  type    = string
  default = "default"
}

variable "name_network" {
  type    = string
  default = "Local_ansible"
}

variable "disks" {
  type = map(object({
    size= number
  }))
  default = { }
}

variable "public_network" {
  type    = string
  default = "public"
  description = "external DHCP start 192.168.100.128 - 192.168.10.254 | GW:192.168.100.1"
}

variable "mode_network" {
  type    = string
  default = "route"
}

variable "template" {
  type    = string
}

variable "qemu_url" {
  type = string
  default = "qemu:///system"
}
