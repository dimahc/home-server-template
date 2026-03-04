# Homelab Architecture Notes

## Goals

- Keep everything reproducible with code checked into this repo.
- Prefer idempotent tooling (Terraform + Ansible) for day-one and day-two operations.
- Minimize resource usage (Intel i3-6006U w/ 4 GiB RAM) by using lightweight services and containers.

## Layers

1. **Base OS** – Debian 13, configured via `scripts/bootstrap.sh` and hardened with Ansible roles.
2. **Infrastructure** – Terraform definitions for any external dependencies (e.g., DNS records, cloud backups, tunnels).
3. **Configuration Management** – Ansible roles playbooks configure host services, firewall rules, and Docker runtime.
4. **Service Runtime** – Docker Compose files that describe long-running services (monitoring, media, networking helpers).

## Environments

- **Sandbox** – throwaway VMs/containers used to test roles and Terraform modules.
- **Home** – the physical Debian host(s) in the apartment rack.
- **Remote** – OVH VPS (portfolio + Dokploy) and any other cloud resources backing up the lab.

Each layer above should explicitly state which environment it targets so drift between home and remote stays visible.

## Next Steps

- Document actual services and data flows once they are chosen.
- Capture network topology (VLANs, subnets) and secrets management approach.
