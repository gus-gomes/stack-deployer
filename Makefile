ifndef INVENTORY
$(error # Env var INVENTORY not defined)
else
$(info # Using ${INVENTORY})
endif

# default vault password file
export ANSIBLE_VAULT_PASSWORD_FILE?=~/.vault

# default ansible config
ifneq ("$(wildcard ${INVENTORY}/ansible.cfg)", "")
export ANSIBLE_CONFIG?=${INVENTORY}/ansible.cfg
endif

# arbitraty commandline flags for ansible-playbook
OPTS?=

ANSIBLE_PLAYBOOK_TOOL?=ansible-playbook
ANS_COMMAND_LINE=${ANSIBLE_PLAYBOOK_TOOL} \
	-i ${INVENTORY}/hosts.yaml \
	-e @${INVENTORY}/globals.yaml

ANS_DIR = ./ansible 

bundle:
	$(ANS_COMMAND_LINE) ${ANS_DIR}/bundle.yaml $(OPTS)

install:
	$(ANS_COMMAND_LINE) ${ANS_DIR}/install.yaml $(OPTS)

uninstall:
	$(ANS_COMMAND_LINE) ${ANS_DIR}/uninstall.yaml $(OPTS)

install-%:
	$(ANS_COMMAND_LINE) ${ANS_DIR}/install.yaml --tags='$(subst install-,,$@)' $(OPTS)

uninstall-%:
	$(ANS_COMMAND_LINE) ${ANS_DIR}/uninstall.yaml --tags='$(subst uninstall-,,$@)' $(OPTS)

security-assessment:
	$(ANS_COMMAND_LINE) ${ANS_DIR}/sec-assessment.yaml $(OPTS)

ping:
	ansible -i ${INVENTORY}/hosts.yaml -m ping all

remote-cmd: 
	ansible -i ${INVENTORY}/hosts.yaml all -m shell -a "$(OPTS)"

copy-keys:
	ansible-playbook -i ${INVENTORY}/hosts.yaml ${ANS_DIR}/exchange-ssh-keys.yaml

install-k3d:
	ansible-playbook ${ANS_DIR}/install-k3d.yaml $(OPTS)

uninstall-k3d:
	ansible-playbook ${ANS_DIR}/uninstall-k3d.yaml $(OPTS)

install-k3d-%:
	ansible-playbook ${ANS_DIR}/install-k3d.yaml --tags='$(subst install-k3d-,,$@)' $(OPTS)

uninstall-k3d-%:
	ansible-playbook ${ANS_DIR}/uninstall-k3d.yaml --tags='$(subst uninstall-k3d-,,$@)' $(OPTS)

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
TF_DIR = ./terraform  # Directory containing your Terraform configuration
# Initialize Terraform
init:
	cd $(TF_DIR) && terraform init
# Plan the Terraform deployment
plan:
	cd $(TF_DIR) && terraform plan
# Apply the Terraform deployment
apply:
	cd $(TF_DIR) && terraform apply -auto-approve
# Destroy the Terraform deployment
destroy:
	cd $(TF_DIR) && terraform destroy -auto-approve

.PHONY: init plan apply destroy bundle install uninstall security-assessment ping remote-cmd copy-keys install-k3d uninstall-k3d generate-inventory