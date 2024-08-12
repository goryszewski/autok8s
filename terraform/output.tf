output "tmp" {
  value = module.node
}

output "k8sip" {
  value = resource.libvirtapi_loadbalancer.lbApi.ip

}
