output "id" {
  value = libvirt_domain.node.id
}

# output "all" {
#   value = libvirt_domain.node
# }

output "ip" {
  value = libvirt_domain.node.network_interface[0].addresses
}
