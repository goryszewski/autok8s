# auto_k8s - Learn terraform + ansible + k8s
Inspiration <a rel="license" href="https://github.com/kelseyhightower/kubernetes-the-hard-way">kelseyhightower kubernetes-the-hard-way</a> and  <a rel="license" href="https://docs.tigera.io/calico/latest/getting-started/kubernetes/hardway/">Calico Hard way</a>

vm requires:
 * qemu-guest-agent
 * disabled cloud-init
 * enable dhcp ens1-4

DOTO:
* use Jenkins to deploy autok8s
* ! create swift -> https://docs.openstack.org/swift/latest/development_saio.html
* new ca - acme free
* prometheus monitoring sd kubernetes apiserver argocd calico
* Description
* BGP + calico
* hardening nftable ebpf
* falco
* apparmor
* nfs + VDO?
* router core/edge
* dynamic + route do external-loadbalancer
* csi by libvirt (/)
* csi by iscsi/nfs
* trivy / Admisssion controller - test image
* testunit / testinfo / sonarqube?
* update template
* external-loadbalancer for kubernetes api ...
