ifndef INVENTORY
$(error no environment variable INVENTORY defined)
else
$(info # using inventory ${INVENTORY})
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

bundle:
	$(ANS_COMMAND_LINE) bundle.yaml $(OPTS)

install:
	$(ANS_COMMAND_LINE) install.yaml $(OPTS)

uninstall:
	$(ANS_COMMAND_LINE) uninstall.yaml $(OPTS)

## Generate inventory

generate-inventory:
	@echo 'admin' -> ~/.vault
	$(ANSIBLE_PLAYBOOK_TOOL) generate-inventory.yaml $(OPTS)
	@echo #######################################################################################
	@echo
	@echo "   Generated new Inventory at ${INVENTORY} "
	@(cd ${INVENTORY} ; find . | sed 's/^/           /')
	@echo
	@echo #######################################################################################
