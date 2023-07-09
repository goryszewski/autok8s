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

variable "name_network" {
  type    = string
  default = "Local_ansible"

}

variable "mode_network" {
  type    = string
  default = "nat"
}

variable "template" {
  type    = string
}

variable "qemu_url" {
  type = string
  default = "qemu:///system"
}