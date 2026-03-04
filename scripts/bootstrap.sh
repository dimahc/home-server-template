#!/usr/bin/env bash
set -euo pipefail

if [[ $(id -u) -ne 0 ]]; then
  echo "Run this script as root (sudo)."
  exit 1
fi

apt update
apt install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  python3 \
  python3-pip \
  software-properties-common

# Install Docker Engine (official instructions condensed).
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install Terraform
if ! command -v terraform >/dev/null 2>&1; then
  curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list
  apt update
  apt install -y terraform
fi

# Install Ansible via pipx to stay current.
# Use apt for pipx (PEP 668 blocks pip install on Debian 12+).
if ! command -v pipx >/dev/null 2>&1; then
  apt install -y pipx
fi
if ! command -v ansible-playbook >/dev/null 2>&1; then
  pipx install ansible
fi

echo "Bootstrap complete. Log out/in if PATH changes were applied."
