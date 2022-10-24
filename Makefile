install:
	terraform -chdir=tf/ init
	terraform -chdir=tf/ workspace select ${WORKSPACE}  || terraform -chdir=tf/ workspace new ${WORKSPACE} 
	terraform -chdir=tf/ apply -input=false -auto-approve -var="vsphere_password=$(VCENTER_PASSWORD)" -var="vsphere_user=$(VCENTER_USER)" -var="vm_password=$(VM_PASSWORD)"
	ansible-playbook -i ansible/hosts.ini ansible/05_loadbalancer.yml --vault-password-file vpass.txt -e lb=lb
	ansible-playbook -i ansible/hosts.ini ansible/01_rke.yml --vault-password-file vpass.txt
	ansible-playbook ansible/init_k8s.yml --vault-password-file vpass.txt -e workspace=$(WORKSPACE)
clean:
	terraform -chdir=tf/ destroy -input=false -auto-approve -var="vsphere_password=$(VCENTER_PASSWORD)" -var="vsphere_user=$(VCENTER_USER)" -var="vm_password=$(VM_PASSWORD)"

deps:
	pip install -r requirements.txt  || pip3 install -r requirements.txt --user
	ansible-galaxy install -r ansible/requirements.yml
