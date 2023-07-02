#VAR 
CONF_domain=goryszewski.local

# TEMPLATE=debian12
TEMPLATE=debian11
LIBVIRT_PATH=template=/var/lib/libvirt/images
# config

Terraform_VARS=-var '$(LIBVIRT_PATH)/$(TEMPLATE).qcow2' \
		-var 'domain=$(CONF_domain)' \
		-var 'hosts={"master01" : { "tags" : ["controlplane","etcd","init"] },\
					 "master02" : { "tags" : ["controlplane","etcd"] }, \
					 "worker01" : { "tags" : ["worker"] }, \
					 "worker02" : { "tags" : ["worker"] }, \
					 "haproxy01" : { "tags" : ["haproxy"] }}' 

# Terraform_VARS=-var '$(LIBVIRT_PATH)/$(TEMPLATE).qcow2' \
# 		-var 'domain=$(CONF_domain)' \
# 		-var 'hosts={"master01" : { "tags" : ["controlplane","etcd","init"] },\
# 					 "worker01" : { "tags" : ["worker"] }, \
# 					 "worker02" : { "tags" : ["worker"] }}' 

inventory=-i ./scripts/libvirt_inventory.py

extra-vars="domain=$(CONF_domain) calico_version=3.26.0 calico_version_cni=3.20.6 k8s_version=1.27.1 ENCRYPTION_KEY=rfjKhlyYRN9WNr026VIKRaRrPZ2GEzqrU3ry2SvDIvs="

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
	cd ./ansible && ansible-playbook main.yml $(inventory) --extra-vars $(extra-vars)

ansible_k8s_kubeadmin: 
	@echo "[MAKE] Ansible Kubernetes"
	cd ./ansible && ansible-playbook k8s_kubeadmin.yml $(inventory) --extra-vars $(extra-vars)

ansible: ansible_k8s

ansible_buffer_clean:
	@echo "[MAKE] Ansible buffer clean"

backup:
	@echo "[MAKE] Backup"

all: terraform_apply ansible_k8s

clean: backup terraform_destroy ansible_buffer_clean

re: clean all

test:
	@echo "[MAKE] test pytest - inventory"
	pytest ./ansible/scripts/test.py