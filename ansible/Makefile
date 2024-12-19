ifndef INVENTORY
$(error # Env var INVENTORY not defined)
else
$(info # Using ${INVENTORY})

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

install-%:
	$(ANS_COMMAND_LINE) install.yaml --tags='$(subst install-,,$@)' $(OPTS)

uninstall-%:
	$(ANS_COMMAND_LINE) uninstall.yaml --tags='$(subst uninstall-,,$@)' $(OPTS)

security-assessment:
	$(ANS_COMMAND_LINE) sec-assessment.yaml $(OPTS)

ping:
	ansible -i ${INVENTORY}/hosts.yaml -m ping all

remote-cmd: 
	ansible -i ${INVENTORY}/hosts.yaml all -m shell -a "$(OPTS)"

copy-keys:
	ansible-playbook -i ${INVENTORY}/hosts.yaml exchange-ssh-keys.yaml

install-k3d:
	ansible-playbook install-k3d.yaml $(OPTS)

uninstall-k3d:
	ansible-playbook uninstall-k3d.yaml $(OPTS)

install-k3d-%:
	ansible-playbook install-k3d.yaml --tags='$(subst install-k3d-,,$@)' $(OPTS)

uninstall-k3d-%:
	ansible-playbook uninstall-k3d.yaml --tags='$(subst uninstall-k3d-,,$@)' $(OPTS)

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
