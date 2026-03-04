# Home Server Automation

Infrastructure-as-code repo for a small Debian-based homelab. The goal is to provision and configure services with Terraform (infrastructure), Ansible (configuration), and Docker (runtime services) while keeping everything reproducible.

## Stack Overview

## Getting Started

1. Clone this repo on your admin workstation.
2. Pick an environment (`sandbox`, `home`, or `remote`) under `ansible/inventories/`.
3. **Create your local overrides** (gitignored — never committed):
   ```bash
   cp ansible/inventories/<env>/group_vars/all/local.yml.example \
      ansible/inventories/<env>/group_vars/all/local.yml
   # Edit local.yml with your real IPs, domains, SSH keys
   ```
4. **Set your server IP** in `ansible/inventories/<env>/hosts.yml`, then prevent accidental commits:
   ```bash
   git update-index --assume-unchanged ansible/inventories/<env>/hosts.yml
   ```
5. **Create Ansible vault** for secrets:
   ```bash
   cp ansible/inventories/<env>/group_vars/vault.yml.example \
      ansible/inventories/<env>/group_vars/vault.yml
   ansible-vault encrypt ansible/inventories/<env>/group_vars/vault.yml
   ```
6. **Create Terraform variables** (for `remote` env):
   ```bash
   cp terraform/envs/<env>/terraform.tfvars.example terraform/envs/<env>/terraform.tfvars
   # Edit terraform.tfvars with your API tokens, IPs, etc.
   ```
7. Run `scripts/bootstrap.sh` on a fresh Debian node to install Docker, Terraform, and Ansible.
8. Apply Terraform, then run the Ansible playbooks.

### Local Override Pattern

Tracked files contain placeholder values (`example.com`, `192.168.0.10`, etc.) so the repo is safe to be public. Your real values go in the gitignored `local.yml`:

```
ansible/inventories/<env>/group_vars/all/
  vars.yml          ← tracked, placeholder values
  ssh.yml           ← tracked, placeholder keys
  vault.yml         ← gitignored, encrypted secrets
  local.yml         ← gitignored, your real overrides  ← you create this
```

Ansible merges all YAML files in `group_vars/all/` alphabetically, so `local.yml` silently overrides any placeholder without touching tracked files.

### Quick: Home Assistant on home env

```bash
cd ansible
ansible-galaxy install -r requirements.yml
ansible-playbook -i inventories/home/hosts.yml playbooks/site.yml
```

This will deploy Home Assistant via Docker Compose to the `docker_hosts` group on your home inventory. Config data persists under `/opt/homelab/homeassistant/config` on the target.

## Repository Layout

```plaintext
.
├── ansible/                # inventories, playbooks, and roles
├── docs/                   # architecture notes & operating procedures
├── scripts/                # helper scripts (bootstrap, etc.)
└── terraform/              # IaC for infrastructure provisioning
```

Each area has its own README or inline docs to guide further development.

### Environments

- `sandbox` – disposable experiments on local VMs or containers.
- `home` – the physical Debian homelab server(s).
- `remote` – cloud/VPS resources (e.g., OVH portfolio/Dokploy host).

Terraform and Ansible mirror these folders so you can target one tier at a time without duplicating logic.
