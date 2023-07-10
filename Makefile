#VAR 
CONF_domain=autok8s.xyz

Terraform_VARS= -var-file="debian11.tfvars"\
				-var 'domain=$(CONF_domain)' \
				-var 'hosts={"master01" : { "tags" : ["controlplane","etcd","init"]},\
							 "master02" : { "tags" : ["controlplane","etcd"]},\
				   			 "worker01" : { "tags" : ["worker"] }, \
							 "worker02" : { "tags" : ["worker"] }, \
							 "haproxy01" : { "tags" : ["haproxy","master"]}, \
							 "haproxy02" : { "tags" : ["haproxy"]} \
							}' 

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

test:
	@echo "[MAKE] test pytest - inventory"
	pytest ./ansible/scripts/test.py