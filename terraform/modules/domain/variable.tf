
variable "hostname" {}
# variable "ip" {}
# variable "mac" {}
variable "domain" {}
variable "template" {}
variable "tags" {}

variable "pool" {
    default = "vm"
}
variable "memoryMB" { default = 4096 }
variable "cpu" { default = 2 }
variable "network" { default = ["internal"] }
variable "public_network" {}
variable "user" { default = "root" }
