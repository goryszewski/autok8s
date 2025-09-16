#VAR
CONF_domain=autok8s.xyz

inventory=-i ./scripts/libvirt_inventory.py

#end config

# Template update
template:

#

# Begin aio

swift:
	@echo "[MAKE] Terraform Swift"
	cd ./terraform && terraform apply --auto-approve $(Terraform_Swift)

swift_destroy:
	@echo "[MAKE] Terraform Swift"
	cd ./terraform && terraform destroy --auto-approve $(Terraform_Swift)

swift_ansible:
	@echo "[MAKE] Ansible Kubernetes"
	cd ./ansible && ansible-playbook swift.yaml $(inventory) --skip-tags SKIP

# END aio

# Begin template

# DOTO
# turn on debian12
# ansible with update and preinstall soft
# turn off debian12
# Convert disk
## qemu-img convert -c -O qcow2 debian12.qcow2 deb12.qcow2

# End template


.PHONY: build
build: terraform ans
	@echo "[MAKE] Build ENV=${ENV}"

.PHONY: rebuild
rebuild: destroy terraform ans
	@echo "[MAKE] rebuild ENV=${ENV}"
# BEGIN terraform

.PHONY: terraform
terraform:
	@echo "[MAKE] TEST ${ENV}"
	sudo iptables -t nat -A POSTROUTING  -o eno1 -j MASQUERADE
	cd ./terraform && terraform apply --auto-approve  -var-file="../env/${ENV}.tfvars" -var-file="variable/debian12.tfvars" -var 'domain=$(CONF_domain)'

.PHONY: destroy
destroy:
	@echo "[MAKE] Terraform Destroy"
	cd ./terraform && terraform destroy --auto-approve  -var-file='../env/${ENV}.tfvars' -var-file="variable/debian12.tfvars"  -var 'domain=$(CONF_domain)'

# END terraform

inventory:
	@echo "[MAKE] Ansible Nodes Cluster"
	# cd ./ansible && ansible-galaxy install -r requirements.yml
	cd ./ansible && ansible-inventory $(inventory)  --list

ans:
	@echo "[MAKE] Ansible Nodes Cluster"
	# cd ./ansible && ansible-galaxy install -r requirements.yml
	cd ./ansible && ansible-playbook sandbox.nodes.yml $(inventory)  --extra-vars @variables.yml --extra-vars @secret.yaml  --tags ${ENV},ALL --skip-tags SKIP

ansible_ping:
	@echo "[MAKE] Ansible All ping"
	cd ./ansible && ansible all -m ping $(inventory)


ansible_k8s:
	@echo "[MAKE] Ansible Kubernetes"
	cd ./ansible && ansible-galaxy install -r requirements.yml
	cd ./ansible && ansible-playbook main.k8s.yaml $(inventory) --extra-vars @variables.yml --extra-vars @secret.yaml  --skip-tags SKIP

ansible: ansible_k8s

ansible_nodes:
	@echo "[MAKE] Ansible Nodes Cluster"
	# cd ./ansible && ansible-galaxy install -r requirements.yml
	cd ./ansible && ansible-playbook sandbox.nodes.yml $(inventory)  --extra-vars @variables.yml --extra-vars @secret.yaml  --skip-tags SKIP

ansible_mini:
	@echo "[MAKE] Ansible Kubernetes Mini"
	cd ./ansible && ansible-galaxy install -r requirements.yml
	cd ./ansible && ansible-playbook main.infra.yml $(inventory) --extra-vars @variables.yml --extra-vars @secret.yaml --vault-password-file .secret  --skip-tags SKIP,LOG,ArgoCD

cluster:
	@echo "[MAKE] Ansible Kubernetes"
	cd ./ansible && ansible-galaxy install -r requirements.yml
	cd ./ansible && ansible-playbook main.cluster.yaml $(inventory) --extra-vars @variables.yml --extra-vars @secret.yaml --vault-password-file .secret

vault:
	@echo "[MAKE] Vault"
	cd ./ansible && ansible-playbook vault.yaml $(inventory) --extra-vars @variables.yml --extra-vars @secret.yaml --vault-password-file .secret --skip-tags SKIP

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
