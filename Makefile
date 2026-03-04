# Homeserver IaC – common tasks
# Usage: make <target> [ENV=home|sandbox|remote] [TAGS=traefik,pihole] [ARGS=...]

SHELL := /bin/bash
.DEFAULT_GOAL := help

# Defaults
ENV          ?= home
ANSIBLE_DIR  := ansible
TF_DIR       := terraform/envs
INVENTORY    := $(ANSIBLE_DIR)/inventories/$(ENV)/hosts.yml
PLAYBOOK     := $(ANSIBLE_DIR)/playbooks/site.yml
VAULT_ARGS   ?= --ask-vault-pass

# Pass extra ansible-playbook args (e.g. ARGS="--check --diff")
ARGS         ?=

# ──────────────────────────────────────────────
#  Help
# ──────────────────────────────────────────────
.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ──────────────────────────────────────────────
#  Ansible
# ──────────────────────────────────────────────
.PHONY: deps
deps: ## Install Ansible Galaxy requirements
	ansible-galaxy install -r $(ANSIBLE_DIR)/requirements.yml

.PHONY: lint
lint: ## Run ansible-lint
	ansible-lint $(ANSIBLE_DIR)/

.PHONY: deploy
deploy: ## Run full playbook (ENV=home ARGS="--check --diff")
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventories/$(ENV)/hosts.yml playbooks/site.yml $(VAULT_ARGS) $(ARGS)

.PHONY: deploy-tags
deploy-tags: ## Run playbook with tags (ENV=home TAGS=traefik,pihole)
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventories/$(ENV)/hosts.yml playbooks/site.yml --tags "$(TAGS)" $(VAULT_ARGS) $(ARGS)

.PHONY: deploy-check
deploy-check: ## Dry-run full playbook (--check --diff)
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventories/$(ENV)/hosts.yml playbooks/site.yml --check --diff $(VAULT_ARGS) $(ARGS)

.PHONY: vault-edit
vault-edit: ## Edit vault file for ENV
	ansible-vault edit $(ANSIBLE_DIR)/inventories/$(ENV)/group_vars/all/vault.yml

.PHONY: vault-encrypt
vault-encrypt: ## Encrypt vault file for ENV
	ansible-vault encrypt $(ANSIBLE_DIR)/inventories/$(ENV)/group_vars/all/vault.yml

.PHONY: vault-decrypt
vault-decrypt: ## Decrypt vault file for ENV
	ansible-vault decrypt $(ANSIBLE_DIR)/inventories/$(ENV)/group_vars/all/vault.yml

# ──────────────────────────────────────────────
#  Terraform
# ──────────────────────────────────────────────
.PHONY: tf-init
tf-init: ## Terraform init (ENV=home)
	terraform -chdir=$(TF_DIR)/$(ENV) init

.PHONY: tf-plan
tf-plan: ## Terraform plan (ENV=home)
	terraform -chdir=$(TF_DIR)/$(ENV) plan

.PHONY: tf-apply
tf-apply: ## Terraform apply (ENV=home)
	terraform -chdir=$(TF_DIR)/$(ENV) apply

.PHONY: tf-fmt
tf-fmt: ## Format all Terraform files
	terraform fmt -recursive terraform/

.PHONY: tf-validate
tf-validate: ## Validate Terraform for ENV
	terraform -chdir=$(TF_DIR)/$(ENV) validate

# ──────────────────────────────────────────────
#  Health Checks
# ──────────────────────────────────────────────
.PHONY: healthcheck
healthcheck: ## Run all health checks on target hosts (ENV=home)
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventories/$(ENV)/hosts.yml playbooks/healthcheck.yml $(VAULT_ARGS) $(ARGS)

.PHONY: check-system
check-system: ## Run system health check only (ENV=home)
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventories/$(ENV)/hosts.yml playbooks/healthcheck.yml --tags system $(VAULT_ARGS) $(ARGS)

.PHONY: check-docker
check-docker: ## Run Docker health check only (ENV=home)
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventories/$(ENV)/hosts.yml playbooks/healthcheck.yml --tags docker $(VAULT_ARGS) $(ARGS)

.PHONY: check-services
check-services: ## Run service reachability check only (ENV=home)
	cd $(ANSIBLE_DIR) && ansible-playbook -i inventories/$(ENV)/hosts.yml playbooks/healthcheck.yml --tags services $(VAULT_ARGS) $(ARGS)

# ──────────────────────────────────────────────
#  CI / Quality
# ──────────────────────────────────────────────
.PHONY: check
check: lint tf-fmt-check tf-validate-all ## Run all CI checks locally

.PHONY: tf-fmt-check
tf-fmt-check: ## Check Terraform formatting
	terraform fmt -check -recursive terraform/

.PHONY: tf-validate-all
tf-validate-all: ## Validate all Terraform environments
	@for env in home remote sandbox; do \
		echo "==> Validating $$env"; \
		terraform -chdir=$(TF_DIR)/$$env init -backend=false -input=false >/dev/null 2>&1; \
		terraform -chdir=$(TF_DIR)/$$env validate; \
	done
