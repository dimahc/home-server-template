# Security Best Practices

## Secrets Management

- **Never commit secrets**: Use `.gitignore` for `*.tfvars`, `.env`, `acme.json`, and `*.vault` files
- **Ansible Vault**: Encrypt sensitive vars with `ansible-vault encrypt_string` or vault files
- **Environment variables**: Store API keys/tokens in `.env` files (gitignored) or CI/CD secret stores

## Access Control

- **SSH keys only**: Disable password auth, use SSH keys for all remote access
- **Sudo privileges**: Limit sudo to specific commands where possible
- **Firewall rules**: Use UFW/iptables; only expose 22, 80, 443 externally
- **Container user**: Run containers as non-root where feasible (HA/Traefik images handle this)

## Updates & Patching

- **Unattended upgrades**: Enable on all nodes for security patches
- **Image updates**: Use tagged versions (not `:latest`) and update explicitly via playbooks
- **Dependency scanning**: Run `ansible-lint`, `terraform validate`, and container vulnerability scans

## Network Segmentation

- **VLANs**: Separate IoT devices, servers, and workstations
- **Docker networks**: Isolate services with dedicated networks (e.g., `homelab` for proxied apps)
- **VPN access**: Use WireGuard/Tailscale for remote admin, avoid exposing SSH publicly

## Tailscale VPN — Zero-Trust Network Access

All admin services are accessed exclusively through the Tailscale mesh VPN.
Unauthorized users cannot even reach the service ports.

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Tailscale Tailnet (private mesh)                          │
│                                                             │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐              │
│  │ homelab  │    │ ovh-vps  │    │ laptop/  │              │
│  │ 100.x.a  │◄──►│ 100.x.b  │◄──►│ phone    │              │
│  │          │    │          │    │ 100.x.c  │              │
│  └──────────┘    └──────────┘    └──────────┘              │
│   HA :8123        Dokploy :3000   Accesses all              │
│   Pi-hole :8080   n8n :5678       services via              │
│   MA :8095        dimahc.dev      Tailscale IPs             │
│   Traefik :8081   (public only)                             │
└─────────────────────────────────────────────────────────────┘
                        │
           ┌────────────┴────────────┐
           │  Internet (public)      │
           │  dimahc.dev ← portfolio │
           │  /webhook/* ← Funnel   │
           │  Everything else CLOSED │
           └─────────────────────────┘
```

### DNS Migration Checklist

After deploying Tailscale on both homelab and VPS:

1. **Cloudflare DNS changes:**
   - `dimahc.dev` → A → <VPS_PUBLIC_IP> → **KEEP** (public portfolio)
   - `dokploy.dimahc.dev` → **DELETE** A record (access via Tailscale only)
   - `n8n.dimahc.dev` → **DELETE** A record (access via Tailscale only)
   - `ha.dimahc.dev` → **DELETE** tunnel route (access via Tailscale only)

2. **Access services via Tailscale MagicDNS:**
   - Dokploy: `https://ovh-vps.YOUR-TAILNET.ts.net/` (port 3000 via Serve)
   - n8n: `https://ovh-vps.YOUR-TAILNET.ts.net:5678/` (direct Tailscale IP)
   - Home Assistant: `http://homelab:8123` or `http://100.x.y.z:8123`
   - Pi-hole: `http://homelab:8080`

3. **n8n webhooks (external integrations):**
   - Public URL via Tailscale Funnel: `https://ovh-vps.YOUR-TAILNET.ts.net/webhook/*`
   - Only `/webhook/*` path is public — admin UI is Tailscale-only
   - Update webhook URLs in GitHub, Stripe, etc. to the Funnel URL

4. **Enable Funnel in Tailscale admin console:**
   - Go to [login.tailscale.com/admin/acls](https://login.tailscale.com/admin/acls)
   - Add `"nodeAttrs": [{"target": ["*"], "attr": ["funnel"]}]` to ACL policy

### Setup Commands

```bash
# 1. Generate a reusable auth key at https://login.tailscale.com/admin/settings/keys

# 2. Add to vault (both environments)
cd ansible
ansible-vault edit inventories/home/group_vars/all/vault.yml
# Add: vault_tailscale_auth_key: "tskey-auth-..."

cp inventories/remote/group_vars/all/vault.yml.example inventories/remote/group_vars/all/vault.yml
ansible-vault edit inventories/remote/group_vars/all/vault.yml
# Add: vault_tailscale_auth_key: "tskey-auth-..."
ansible-vault encrypt inventories/remote/group_vars/all/vault.yml

# 3. Deploy Tailscale
ansible-playbook -i inventories/home/hosts.yml playbooks/site.yml --tags tailscale --ask-vault-pass
ansible-playbook -i inventories/remote/hosts.yml playbooks/site.yml --tags tailscale --ask-vault-pass

# 4. Install Tailscale on phone/laptop
#    - Android: Play Store → Tailscale
#    - macOS/Windows/Linux: https://tailscale.com/download

# 5. Verify mesh connectivity
tailscale status   # shows all connected nodes
tailscale ping homelab
tailscale ping ovh-vps

# 6. Delete DNS records on Cloudflare (dokploy, n8n, ha subdomains)
# 7. Update n8n webhook URLs to Funnel URL
```

## Backup & Recovery

- **3-2-1 rule**: 3 copies, 2 media types, 1 offsite (OVH VPS)
- **Config backups**: `/opt/homelab/*/config` dirs → restic/borg daily
- **State backups**: Terraform state → remote backend; Ansible playbooks in git
- **Test restores**: Quarterly restore drills to sandbox environment

## Monitoring & Logging

- **Centralized logs**: Ship logs to remote syslog or Loki
- **Alerts**: Monitor cert expiry, disk usage, service health
- **Audit trail**: Enable `log_path` in `ansible.cfg`, track Terraform state changes
