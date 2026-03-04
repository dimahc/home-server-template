variable "homelab_name" {
  description = "Identifier for resources in the remote (cloud) environment."
  type        = string
  default     = "remote-vps"
}

# ── Cloudflare ──

variable "cloudflare_api_token" {
  description = "Cloudflare API token with DNS edit permissions for dimahc.dev zone."
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for dimahc.dev (found in domain Overview page)."
  type        = string
}

variable "vps_ipv4" {
  description = "OVH VPS public IPv4 address."
  type        = string
  # No default — must be set in terraform.tfvars (not committed)
}

variable "domain" {
  description = "Root domain."
  type        = string
  default     = "dimahc.dev"
}

variable "cloudflare_tunnel_id" {
  description = "Cloudflare Tunnel UUID for homelab (found in Zero Trust → Tunnels)."
  type        = string
  default     = ""
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID (found in Zero Trust dashboard or tunnel token)."
  type        = string
  default     = ""
}
