ifndef INVENTORY
$(error # Env var INVENTORY not defined)
else
$(info # Using ${INVENTORY})
endif

# default vault password file
export ANSIBLE_VAULT_PASSWORD_FILE?=~/.vault

# default ansible config
export ANSIBLE_CONFIG?=$(CURDIR)/ansible/ansible.cfg

# arbitraty commandline flags for ansible-playbook
OPTS?=

ANSIBLE_PLAYBOOK_TOOL?=ansible-playbook
ANS_COMMAND_LINE=${ANSIBLE_PLAYBOOK_TOOL} \
	-i ${INVENTORY}/hosts.yaml \
	-e @${INVENTORY}/globals.yaml 

bundle:
	$(ANS_COMMAND_LINE) ansible/bundle.yaml $(OPTS)

install:
	$(ANS_COMMAND_LINE) ansible/install.yaml $(OPTS)

uninstall:
	$(ANS_COMMAND_LINE) ansible/uninstall.yaml $(OPTS)

install-%:
	$(ANS_COMMAND_LINE) ansible/install.yaml --tags='$(subst install-,,$@)' $(OPTS)

uninstall-%:
	$(ANS_COMMAND_LINE) ansible/uninstall.yaml --tags='$(subst uninstall-,,$@)' $(OPTS)

ping:
	ansible -i ${INVENTORY}/hosts.yaml -m ping all

remote-cmd: 
	ansible -i ${INVENTORY}/hosts.yaml all -m shell -a "$(OPTS)"

copy-keys:
	ansible-playbook -i ${INVENTORY}/hosts.yaml ansible/copy-ssh-keys.yaml

## Generate inventory

generate-inventory:
	@echo 'admin' -> ~/.vault
	$(ANSIBLE_PLAYBOOK_TOOL) ${ANS_DIR}/generate-inventory.yaml $(OPTS)
	@echo #######################################################################################
	@echo
	@echo "   Generated new Inventory at ${INVENTORY} "
	@(cd ${INVENTORY} ; find . | sed 's/^/           /')
	@echo
	@echo #######################################################################################


## Terraform code
# Variables
TF_DIR=./terraform  # Directory containing your Terraform configuration
# Initialize Terraform
init:
	cd $(TF_DIR) && terraform init
# Plan the Terraform deployment
plan:
	cd $(TF_DIR) && terraform plan
# Apply the Terraform deployment
apply:
	cd $(TF_DIR) && terraform apply -auto-approve
	cd $(TF_DIR) && cp hosts.yaml $(INVENTORY)/hosts.yaml
	
# Destroy the Terraform deployment
destroy:
	cd $(TF_DIR) && terraform destroy -auto-approve

.PHONY: init plan apply destroy bundle install uninstall ping remote-cmd copy-keys generate-inventory