# Home Server Automation

Infrastructure-as-code repo for a small Debian-based homelab. The goal is to provision and configure services with Terraform (infrastructure), Ansible (configuration), and Docker (runtime services) while keeping everything reproducible.

## Stack Overview

## Getting Started

1. Clone this repo on your admin workstation.
2. Pick an environment (`sandbox`, `home`, or `remote`) under `ansible/inventories/` and adjust the inventory + group vars for your nodes.
3. **Add your SSH keys** to `ansible/inventories/<env>/group_vars/all/ssh.yml` (see [SSH Setup Guide](docs/ssh-setup.md)).
4. **Create Terraform variables** from the example file:
   ```bash
   cp terraform/envs/<env>/terraform.tfvars.example terraform/envs/<env>/terraform.tfvars
   # Edit terraform.tfvars with your actual values (API tokens, IPs, etc.)
   ```
5. **Create Ansible vault** for secrets:
   ```bash
   cp ansible/inventories/<env>/group_vars/vault.yml.example ansible/inventories/<env>/group_vars/vault.yml
   ansible-vault encrypt ansible/inventories/<env>/group_vars/vault.yml
   ```
6. Run `scripts/bootstrap.sh` on a fresh Debian node (or execute manually) to install base packages, Docker, Terraform, and Ansible.
7. Apply Terraform, then run the Ansible playbooks.

### Customization

Before deploying, review and update these files with your specific values:

| File                                                | What to customize               |
| --------------------------------------------------- | ------------------------------- |
| `ansible/inventories/<env>/hosts.yml`               | Server IP addresses             |
| `ansible/inventories/<env>/group_vars/all/vars.yml` | Domain, email, service configs  |
| `ansible/inventories/<env>/group_vars/all/ssh.yml`  | Your SSH public keys            |
| `ansible/inventories/<env>/group_vars/vault.yml`    | Secrets (passwords, API tokens) |
| `terraform/envs/<env>/terraform.tfvars`             | Cloud provider credentials      |

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
