# Terraform Layout

- `modules/` – shared modules for networking, DNS, storage, etc.
- `envs/<name>/` – per-environment configurations combining modules (sandbox, home, remote).

## Usage

```bash
cd terraform/envs/home
terraform init
terraform plan -var="homelab_name=home"

cd ../remote
terraform init
terraform plan -var="homelab_name=remote-vps"
```

Swap directories (or add additional ones) as you grow. Update each `backend.tf` to use the appropriate remote state storage for that environment.
