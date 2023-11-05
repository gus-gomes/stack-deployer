# default inventory in this repo
#INVENTORY?=hosts.yaml

# Path to inventory location aka user config
# Fail if not given
ifndef INVENTORY_DIR
$(error no environment variable INVENTORY_DIR defined)
else
$(info # using inventory ${INVENTORY_DIR})
endif

# default vault password file
export ANSIBLE_VAULT_PASSWORD_FILE?=~/.te-vault

# default ansible config
ifneq ("$(wildcard ${INVENTORY_DIR}/ansible.cfg)", "")
export ANSIBLE_CONFIG?=${INVENTORY_DIR}/ansible.cfg
endif

# arbitraty commandline flags for ansible-playbook
OPTS?=

ANSIBLE_PLAYBOOK_TOOL?=ansible-playbook
ANS_COMMAND_LINE=${ANSIBLE_PLAYBOOK_TOOL} \
	-i ${INVENTORY_DIR}/hosts.yaml \
	-e @${INVENTORY_DIR}/globals.yaml \
	-e @${INVENTORY_DIR}/secrets.yaml

bundle:
	$(ANS_COMMAND_LINE) bundle.yaml $(OPTS)

## Deployment Targets

all: pre-requisites install

pre-requisites:
	$(ANS_COMMAND_LINE) pre-requisites.yaml $(OPTS)

install:
	$(ANS_COMMAND_LINE) install.yaml $(OPTS)

uninstall:
	$(ANS_COMMAND_LINE) uninstall.yaml $(OPTS)

## Generate inventory

generate-inventory:
	$(ANSIBLE_PLAYBOOK_TOOL) generate-inventory.yaml $(OPTS)
	@echo #######################################################################################
	@echo
	@echo "   Generated new Inventory at ${INVENTORY_DIR} "
	@(cd ${INVENTORY_DIR} ; find . | sed 's/^/           /')
	@echo
	@echo "   Now, modify the templates and provide suitable confiuration values for your new"
	@echo "   cluster configuration"
	@echo
	@echo "   Also, remember to use Git for version control of your configuration."
	@echo
	@echo #######################################################################################