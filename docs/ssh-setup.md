# SSH Setup Guide

This project uses two SSH accounts for security separation:

1. **`admin`** - Your personal interactive account
2. **`ansible`** - Dedicated service account for automation only

## Generate SSH Keys

```bash
# Personal account key
ssh-keygen -t ed25519 -C "admin@homelab" -f ~/.ssh/id_ed25519_personal

# Ansible automation key (separate for security)
ssh-keygen -t ed25519 -C "ansible-automation" -f ~/.ssh/id_ed25519_ansible
```

## Add Keys to Inventory

Edit the environment's SSH config:

```bash
# Home environment
vim ansible/inventories/home/group_vars/all/ssh.yml

# Remote/VPS environment
vim ansible/inventories/remote/group_vars/all/ssh.yml
```

Add your public keys:

```yaml
ssh_authorized_keys:
  - user: admin
    keys:
      - "ssh-ed25519 AAAA... admin@homelab"
  - user: ansible
    keys:
      - "ssh-ed25519 AAAA... ansible-automation"
```

## Configure SSH Client

Add to `~/.ssh/config`:

```
Host homelab
  HostName 192.168.0.10
  User admin
  IdentityFile ~/.ssh/id_ed25519_personal

Host homelab-ansible
  HostName 192.168.0.10
  User ansible
  IdentityFile ~/.ssh/id_ed25519_ansible
```

## Deploy Keys

```bash
cd ansible
ansible-galaxy install -r requirements.yml
ansible-playbook -i inventories/home/hosts.yml playbooks/site.yml --tags common -k
```

This creates the `ansible` service account, deploys SSH keys, and hardens the SSH daemon.

## Ansible Service Account

The `ansible` user has passwordless sudo for automation tasks. After initial setup, update your inventory to use it:

```yaml
# inventories/home/hosts.yml
ansible_user: ansible
ansible_ssh_private_key_file: ~/.ssh/id_ed25519_ansible
```

## Test Connection

```bash
ssh homelab-ansible
ansible all -i inventories/home/hosts.yml -m ping
```
