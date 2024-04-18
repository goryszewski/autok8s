#VAR
CONF_domain=autok8s.xyz
HOSTS={\
	"master01" : { memoryMB: "4096" , "tags" : ["etcd","nodeK8S","controlplane","init"] },\
	"master02" : { memoryMB: "4096" , "tags" : ["etcd","nodeK8S","controlplane"] },\
	"master03" : { memoryMB: "4096" , "tags" : ["etcd","nodeK8S","controlplane"] },\
	"worker01" : { "tags" : ["nodeK8S","worker"]  , memoryMB: "8192"}, \
	"worker02" : { "tags" : ["nodeK8S","worker"]  , memoryMB: "8192"}, \
	"haproxy01" : { "tags" : ["bgp","haproxy","master"] , memoryMB: "2048"},\
	"haproxy02" : { "tags" : ["bgp","haproxy"] , memoryMB: "2048"}, \
	"syslog" : { "tags" : ["syslog"] , memoryMB: "2048"}, \
	"vault01" : { "tags" : ["vault"] , memoryMB: "2048"}, \
	"vault02" : { "tags" : ["vault"] , memoryMB: "2048"}, \
	"prometheus": {"tags" : ["monit"] , memoryMB: "2048"} \
	"lbexternal01" : { "tags" : ["lbexternal"] , memoryMB: "2048"},\
	"nfs01" : { "tags" : ["nfs"] , memoryMB: "2048"},\
 }

 HOSTS_s={\
	"master01" : { memoryMB: "8192" , "tags" : ["etcd","nodeK8S","controlplane","init"] },\
	"worker01" : { "tags" : ["nodeK8S","worker"]  , memoryMB: "8192"}, \
	"haproxy01" : { "tags" : ["bgp","haproxy","master"] , memoryMB: "2048"},\
 }

 HOSTS_test={\
	"master01" : { memoryMB: "8192" , "tags" : ["etcd","nodeK8S","controlplane","init"] },\
	"worker01" : { "tags" : ["nodeK8S","worker"]  , memoryMB: "8192"}, \
	"haproxy01" : { "tags" : ["bgp","haproxy","master"] , memoryMB: "2048"},\
	"lbexternal01" : { "tags" : ["lbexternal"] , memoryMB: "2048"},\
	"nfs01" : { "tags" : ["nfs"] , memoryMB: "2048"},\
 }

HOSTS_single={"master01" : { "template":"rh93", memoryMB: "8192" , "tags" : ["etcd","nodeK8S","controlplane","init","worker"] }}

Terraform_VARS= -var-file="debian12.tfvars"\
				-var 'domain=$(CONF_domain)' \
				-var 'hosts=$(HOSTS)'

Terraform_VARS_Mini=-var-file="debian12.tfvars" -var 'domain=$(CONF_domain)' -var 'hosts=$(HOSTS_test)'

Terraform_VARS_ubuntu=-var-file="ubuntu2204.tfvars" -var 'domain=$(CONF_domain)' -var 'hosts=$(HOSTS_test)'

Terraform_VARS_bsd=-var-file="freebsd14.tfvars" -var 'domain=$(CONF_domain)' -var 'hosts=$(HOSTS_s)'

Terraform_VARS_redhat=-var-file="rh93.tfvars" -var 'domain=$(CONF_domain)' -var 'hosts=$(HOSTS_single)'

inventory=-i ./scripts/libvirt_inventory.py

extra-vars="domain=$(CONF_domain) global_repo=repo.mgmt.autok8s.ext calico_version=3.26.0 calico_version_cni=3.20.6 k8s_version=1.29.1"

#end config

# BEGIN terraform

terraform_init:
	@echo "[MAKE] Terraform Init"
	cd ./terraform && terraform init $(Terraform_VARS)

terraform_plan: terraform_init
	@echo "[MAKE] Terraform Plan"
	cd ./terraform && terraform plan  $(Terraform_VARS)

terraform_apply: terraform_plan
	@echo "[MAKE] Terraform Apply"
	cd ./terraform && terraform apply --auto-approve $(Terraform_VARS)

terraform_mini:
	@echo "[MAKE] Terraform Apply"
	cd ./terraform && terraform apply --auto-approve $(Terraform_VARS_Mini)

terraform_bsd:
	@echo "[MAKE] Terraform Apply"
	cd ./terraform && terraform apply --auto-approve $(Terraform_VARS_bsd)

terraform_ubuntu: terraform_plan
	@echo "[MAKE] Terraform Apply"
	cd ./terraform && terraform apply --auto-approve $(Terraform_VARS_ubuntu)

terraform_redhat: terraform_plan
	@echo "[MAKE] Terraform Apply"
	cd ./terraform && terraform apply --auto-approve $(Terraform_VARS_redhat)

terraform_destroy: terraform_init
	@echo "[MAKE] Terraform Destroy"
	cd ./terraform && terraform destroy --auto-approve $(Terraform_VARS_Mini)

# END terraform

ansible_ping:
	@echo "[MAKE] Ansible All ping"
	cd ./ansible && ansible all -m ping $(inventory)


ansible_k8s:
	@echo "[MAKE] Ansible Kubernetes"
	cd ./ansible && ansible-playbook main.yml $(inventory) --extra-vars $(extra-vars) --extra-vars @secret.yaml  --skip-tags SKIP

ansible_k8s_kubeadm:
	@echo "[MAKE] Ansible Kubernetes"
	cd ./ansible && ansible-playbook k8s_kubeadm.yml $(inventory) --extra-vars $(extra-vars) --extra-vars @secret.yaml --skip-tags SKIP

ansible: ansible_k8s

ansible_mini:
	@echo "[MAKE] Ansible Kubernetes Mini"
	cd ./ansible && ansible-playbook main.yml $(inventory) --extra-vars $(extra-vars) --extra-vars @secret.yaml  --skip-tags SKIP,LOG,ArgoCD

cluster:
	@echo "[MAKE] Ansible Kubernetes"
	cd ./ansible && ansible-playbook main.yml $(inventory) --extra-vars $(extra-vars) --extra-vars @secret.yaml  --tags CLUSTER

vault:
	@echo "[MAKE] Vault"
	cd ./ansible && ansible-playbook vault.yaml $(inventory) --extra-vars $(extra-vars) --extra-vars @secret.yaml  --skip-tags SKIP

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
