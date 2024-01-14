$(info Setting by default INV=/home/ubuntu/platform-config)
export INV="/home/ubuntu/platform-config"

# default vault password file
export ANSIBLE_VAULT_PASSWORD_FILE?=~/.vault

# default ansible config
ifneq ("$(wildcard ${INV}/ansible.cfg)", "")
export ANSIBLE_CONFIG?=${INV}/ansible.cfg
endif

# arbitraty commandline flags for ansible-playbook
OPTS?=

ANSIBLE_PLAYBOOK_TOOL?=ansible-playbook
ANS_COMMAND_LINE=${ANSIBLE_PLAYBOOK_TOOL} \
	-i ${INV}/hosts.yaml \
	-e @${INV}/globals.yaml

bundle:
	$(ANS_COMMAND_LINE) bundle.yaml $(OPTS)

install:
	$(ANS_COMMAND_LINE) install.yaml $(OPTS)

uninstall:
	$(ANS_COMMAND_LINE) uninstall.yaml $(OPTS)

security-assessment:
	$(ANS_COMMAND_LINE) sec-assessment.yaml $(OPTS)

## Generate inventory

generate-inventory:
	@echo 'admin' -> ~/.vault
	$(ANSIBLE_PLAYBOOK_TOOL) generate-inventory.yaml $(OPTS)
	@echo #######################################################################################
	@echo
	@echo "   Generated new Inventory at ${INV} "
	@(cd ${INV} ; find . | sed 's/^/           /')
	@echo
	@echo #######################################################################################
