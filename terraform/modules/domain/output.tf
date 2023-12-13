output "id" {
  value = libvirt_domain.node.id
}

# output "all" {
#   value = libvirt_domain.node
# }

output "local_ip" {
  value = libvirt_domain.node.network_interface[0].addresses
}
output "public_ip" {
  value = libvirt_domain.node.network_interface[1].addresses
}
