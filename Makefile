#VAR 
CONF_domain=autok8s.xyz

# HOSTS='{ "master01" : { "tags" : ["controlplane","etcd","init"]},\
# 							  "master02" : { "tags" : ["controlplane","etcd"]},\
# 				   			  "worker01" : { "tags" : ["worker"] }, \
# 							  "worker02" : { "tags" : ["worker"] }, \
# 							  "exabgp01" : { "tags" : ["exabgp"]}, \
# 							  "exabgp02" : { "tags" : ["exabgp"]}, \
# 							  "haproxy01" : { "tags" : ["bgp","haproxy","master"]}, \
# 							  "haproxy02" : { "tags" : ["bgp","haproxy"]}, \
# 							  "prometheus": {"tags" : ["monit"] } \
# 							}'
HOSTS1={ "etcd01" : { "tags" : ["etcd"] , memoryMB: "2048" },\
	"etcd02" : { "tags" : ["etcd"]  , memoryMB: "2048"},\
	"master01" : { "tags" : ["controlplane","init"] , memoryMB: "2048"},\
	"master02" : { "tags" : ["controlplane"] , memoryMB: "2048"},\
	"worker01" : { "tags" : ["worker"]  , memoryMB: "8192"}, \
	"worker02" : { "tags" : ["worker"]  , memoryMB: "8192"}, \
	"haproxy01" : { "tags" : ["bgp","haproxy","master"] , memoryMB: "2048"}, \
	"haproxy02" : { "tags" : ["bgp","haproxy"] , memoryMB: "2048"} ,\
	"prometheus": {"tags" : ["monit"] , memoryMB: "2048"} \
		}
HOSTS2={"master01" : { memoryMB: "2048" , "tags" : ["controlplane","init"] },\
	"master02" : { memoryMB: "2048" , "tags" : ["controlplane"] },\
	"etcd01"   : { memoryMB: "2048" , "tags" : ["etcd"] },\
	"etcd02"   : { memoryMB: "2048" , "tags" : ["etcd"] },\
	"worker01" : { "tags" : ["worker"]  , memoryMB: "8192"}, \
	"worker02" : { "tags" : ["worker"]  , memoryMB: "8192"}, \
	"haproxy01" : { "tags" : ["bgp","haproxy","master"] , memoryMB: "2048"},\
	"haproxy02" : { "tags" : ["bgp","haproxy"] , memoryMB: "2048"}, \
	"prometheus": {"tags" : ["monit"] , memoryMB: "2048"} \
 }

Terraform_VARS= -var-file="debian11.tfvars"\
				-var 'domain=$(CONF_domain)' \
				-var 'hosts=$(HOSTS2)' 

inventory=-i ./scripts/libvirt_inventory.py

extra-vars="domain=$(CONF_domain) calico_version=3.26.0 calico_version_cni=3.20.6 k8s_version=1.27.3 ENCRYPTION_KEY=rfjKhlyYRN9WNr026VIKRaRrPZ2GEzqrU3ry2SvDIvs="

#end config

terraform_init:
	@echo "[MAKE] Terraform Init"
	cd ./terraform && terraform init $(Terraform_VARS)

terraform_plan: terraform_init
	@echo "[MAKE] Terraform Plan"
	cd ./terraform && terraform plan  $(Terraform_VARS)

terraform_apply: terraform_plan
	@echo "[MAKE] Terraform Apply"
	cd ./terraform && terraform apply --auto-approve $(Terraform_VARS)

terraform_destroy: terraform_init
	@echo "[MAKE] Terraform Destroy"
	cd ./terraform && terraform destroy --auto-approve $(Terraform_VARS)


ansible_ping: 
	@echo "[MAKE] Ansible All ping"
	cd ./ansible && ansible all -m ping $(inventory)


ansible_k8s: 
	@echo "[MAKE] Ansible Kubernetes"
	cd ./ansible && ansible-playbook main.yml $(inventory) --extra-vars $(extra-vars)  --skip-tags SKIP

ansible_k8s_kubeadm: 
	@echo "[MAKE] Ansible Kubernetes"
	cd ./ansible && ansible-playbook k8s_kubeadm.yml $(inventory) --extra-vars $(extra-vars) --skip-tags SKIP

ansible: ansible_k8s

ansible_buffer_clean:
	@echo "[MAKE] Ansible buffer clean"

backup:
	@echo "[MAKE] Backup"

all: terraform_apply ansible_k8s

clean: backup terraform_destroy ansible_buffer_clean

re: clean all

sudo:
	sudo ls > /dev/null

stop: sudo
	@echo " [KVM] STOP all vms"
	for i in `sudo virsh list --name ` ; do sudo virsh destroy	 --domain $$i --graceful ; done
	sudo virsh net-destroy --network Local_ansible

start: sudo
	sudo virsh net-start --network Local_ansible
	@echo " [KVM] START all vms"
	for i in `sudo virsh list --name --all | grep $(CONF_domain) ` ; do sudo virsh start --domain $$i ; done

snap: sudo
	@echo " [KVM] snap all vms"
	for i in `sudo virsh list --name --all | grep $(CONF_domain) ` ; do sudo virsh snapshot-create-as --domain $$i --name "makefile" --description "Snapshot via makefile" ; done

revert: sudo
	@echo " [KVM] revert all vms"
	for i in `sudo virsh list --name --all | grep $(CONF_domain) ` ; do sudo virsh snapshot-revert --domain $$i --snapshotname  "makefile" ; done

rv: sudo
	systemctl stop libvirtd
	systemctl start libvirtd

test:
	@echo "[MAKE] test pytest - inventory"
	pytest ./ansible/scripts/test.py