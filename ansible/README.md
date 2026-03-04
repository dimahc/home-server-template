# Ansible

## Layout

- `inventories/<env>/hosts.yml` – inventories for `sandbox`, `home`, and `remote` targets.
- `inventories/<env>/group_vars/` – defaults for the inventory that live beside each host file.
- `playbooks/` – reusable entry-point playbooks (e.g., `site.yml`).
- `roles/` – custom roles (start with `common`).

## Usage

```bash
cd ansible
ansible-galaxy install -r requirements.yml
ansible-playbook -i inventories/home/hosts.yml playbooks/site.yml

# Sandbox experiment
ansible-playbook -i inventories/sandbox/hosts.yml playbooks/site.yml

# Remote OVH VPS
ansible-playbook -i inventories/remote/hosts.yml playbooks/site.yml
```

**Selective execution with tags:**

```bash
# Only run base configuration
ansible-playbook -i inventories/home/hosts.yml playbooks/site.yml --tags base

# Only deploy Traefik
ansible-playbook -i inventories/home/hosts.yml playbooks/site.yml --tags traefik

# Deploy all Docker apps
ansible-playbook -i inventories/home/hosts.yml playbooks/site.yml --tags apps

# Dry run (check mode)
ansible-playbook -i inventories/home/hosts.yml playbooks/site.yml --check --diff
```

Customize variables per inventory and add roles as you build out services.

### Enable Traefik + TLS for Home Assistant

1. Set values in `inventories/home/group_vars/all.yml`:

   ```yaml
   traefik_email: "you@example.com"  # ACME email
   ha_enable_traefik: true
   ha_domain: "your-domain.example"  # e.g., homelab.example.com
   ha_subdomain: "ha"                 # ha.your-domain.example
   ```

2. Ensure ports 80/443 on your router forward to the homelab host running Traefik.

3. Run the playbook for the home inventory. Traefik will provision certificates via HTTP challenge and HA will be available at `https://ha.<domain>`.
